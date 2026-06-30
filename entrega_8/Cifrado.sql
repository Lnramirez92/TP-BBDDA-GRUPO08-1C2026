/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: Script 13 - Cifrado de datos sensibles mediante Always Encrypted / columnas
--   cifradas con claves simétricas. Se aplica cifrado a: DNI de Guia y Guardaparque, CUIT y
--   contacto de Empresa_Concesionaria. Se crean columnas cifradas, se migran los datos y se
--   adaptan los SPs afectados para operar sobre las columnas cifradas.
--
--   ESTRATEGIA: SQL Server Symmetric Key + Certificate (cifrado a nivel de celda).
--   Esto permite cifrar/descifrar en T-SQL sin depender de drivers externos ni CLR.
--   El cifrado se aplica como modificación sobre tablas y SPs existentes.
================================================================================================= */

USE ParquesNacionales;
GO

-- ================================================================================================
-- 1. MASTER KEY de la base de datos (requerida para crear certificados)
-- ================================================================================================
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'P@rquesN@c10nales_MK!2026';
    PRINT 'Master Key creada.';
END
ELSE
    PRINT 'Master Key ya existia.';
GO

-- ================================================================================================
-- 2. CERTIFICADO para proteger la clave simétrica
-- ================================================================================================
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'Cert_DatosSensibles')
BEGIN
    CREATE CERTIFICATE Cert_DatosSensibles
        WITH SUBJECT = 'Certificado para cifrado de datos sensibles - Parques Nacionales';
    PRINT 'Certificado Cert_DatosSensibles creado.';
END
ELSE
    PRINT 'Certificado Cert_DatosSensibles ya existia.';
GO

-- ================================================================================================
-- 3. CLAVE SIMÉTRICA AES-256
-- ================================================================================================
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'SK_DatosSensibles')
BEGIN
    CREATE SYMMETRIC KEY SK_DatosSensibles
        WITH ALGORITHM = AES_256
        ENCRYPTION BY CERTIFICATE Cert_DatosSensibles;
    PRINT 'Clave simetrica SK_DatosSensibles creada.';
END
ELSE
    PRINT 'Clave simetrica SK_DatosSensibles ya existia.';
GO

-- ================================================================================================
-- 4. TABLA Personal.Guia — agregar columnas cifradas para DNI
--    Columna original: dni CHAR(10)
--    Columna cifrada:  dni_cifrado VARBINARY(MAX)
-- ================================================================================================

-- 4.1 Agregar columna cifrada si no existe
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Personal.Guia') AND name = 'dni_cifrado'
)
BEGIN
    ALTER TABLE Personal.Guia ADD dni_cifrado VARBINARY(MAX) NULL;
    PRINT 'Columna dni_cifrado agregada a Personal.Guia.';
END
GO

-- 4.2 Migrar datos existentes: cifrar DNI actual y guardarlo en dni_cifrado
OPEN SYMMETRIC KEY SK_DatosSensibles
    DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

UPDATE Personal.Guia
SET dni_cifrado = ENCRYPTBYKEY(KEY_GUID('SK_DatosSensibles'), CONVERT(NVARCHAR(10), dni))
WHERE dni IS NOT NULL AND dni_cifrado IS NULL;

CLOSE SYMMETRIC KEY SK_DatosSensibles;
PRINT 'DNI de Guias migrados a columna cifrada.';
GO

-- 4.3 Una vez migrados, nullificar la columna original (o eliminarla en producción)
--     Por seguridad borramos el dato en claro. En un entorno real esto iría luego de validar.
UPDATE Personal.Guia SET dni = REPLICATE('*', 10) WHERE dni_cifrado IS NOT NULL;
PRINT 'Columna dni original anonimizada en Personal.Guia.';
GO


-- ================================================================================================
-- 5. TABLA Personal.Guardaparque — agregar columnas cifradas para DNI
-- ================================================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Personal.Guardaparque') AND name = 'dni_cifrado'
)
BEGIN
    ALTER TABLE Personal.Guardaparque ADD dni_cifrado VARBINARY(MAX) NULL;
    PRINT 'Columna dni_cifrado agregada a Personal.Guardaparque.';
END
GO

OPEN SYMMETRIC KEY SK_DatosSensibles
    DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

UPDATE Personal.Guardaparque
SET dni_cifrado = ENCRYPTBYKEY(KEY_GUID('SK_DatosSensibles'), CONVERT(NVARCHAR(10), dni))
WHERE dni IS NOT NULL AND dni_cifrado IS NULL;

CLOSE SYMMETRIC KEY SK_DatosSensibles;
PRINT 'DNI de Guardaparques migrados a columna cifrada.';
GO

UPDATE Personal.Guardaparque SET dni = REPLICATE('*', 10) WHERE dni_cifrado IS NOT NULL;
PRINT 'Columna dni original anonimizada en Personal.Guardaparque.';
GO


-- ================================================================================================
-- 6. TABLA Concesiones.Empresa_Concesionaria — cifrar CUIT y contacto
-- ================================================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Concesiones.Empresa_Concesionaria') AND name = 'cuit_cifrado'
)
BEGIN
    ALTER TABLE Concesiones.Empresa_Concesionaria ADD cuit_cifrado VARBINARY(MAX) NULL;
    PRINT 'Columna cuit_cifrado agregada.';
END

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Concesiones.Empresa_Concesionaria') AND name = 'contacto_cifrado'
)
BEGIN
    ALTER TABLE Concesiones.Empresa_Concesionaria ADD contacto_cifrado VARBINARY(MAX) NULL;
    PRINT 'Columna contacto_cifrado agregada.';
END
GO

OPEN SYMMETRIC KEY SK_DatosSensibles
    DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

UPDATE Concesiones.Empresa_Concesionaria
SET
    cuit_cifrado    = ENCRYPTBYKEY(KEY_GUID('SK_DatosSensibles'), CONVERT(NVARCHAR(15), cuit)),
    contacto_cifrado = ENCRYPTBYKEY(KEY_GUID('SK_DatosSensibles'), CONVERT(NVARCHAR(30), contacto))
WHERE cuit_cifrado IS NULL;

CLOSE SYMMETRIC KEY SK_DatosSensibles;
PRINT 'CUIT y contacto de empresas migrados a columnas cifradas.';
GO

UPDATE Concesiones.Empresa_Concesionaria
SET
    cuit     = REPLICATE('*', 15),
    contacto = REPLICATE('*', 30)
WHERE cuit_cifrado IS NOT NULL;
PRINT 'Columnas cuit y contacto originales anonimizadas.';
GO


-- ================================================================================================
-- 7. SP PARA LEER DATOS DESCIFRADOS (reemplaza SELECT directo a las tablas)
--    Solo usuarios con permiso de CONTROL sobre la clave pueden descifrar.
-- ================================================================================================

CREATE OR ALTER PROCEDURE Personal.Guia_ObtenerDNI
    @id_guia INT
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY SK_DatosSensibles
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    SELECT
        id_guia,
        nombre,
        apellido,
        CONVERT(NVARCHAR(10), DECRYPTBYKEY(dni_cifrado)) AS dni,
        especialidad,
        id_titulo,
        activo
    FROM Personal.Guia
    WHERE id_guia = @id_guia;

    CLOSE SYMMETRIC KEY SK_DatosSensibles;
END;
GO

CREATE OR ALTER PROCEDURE Personal.Guardaparque_ObtenerDNI
    @id_guardaparque INT
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY SK_DatosSensibles
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    SELECT
        id_guardaparque,
        nombre,
        apellido,
        CONVERT(NVARCHAR(10), DECRYPTBYKEY(dni_cifrado)) AS dni,
        fecha_nacimiento,
        activo
    FROM Personal.Guardaparque
    WHERE id_guardaparque = @id_guardaparque;

    CLOSE SYMMETRIC KEY SK_DatosSensibles;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.Empresa_ObtenerDatosCompletos
    @id_empresa INT
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY SK_DatosSensibles
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    SELECT
        id_empresa,
        razon_social,
        CONVERT(NVARCHAR(15), DECRYPTBYKEY(cuit_cifrado))     AS cuit,
        CONVERT(NVARCHAR(30), DECRYPTBYKEY(contacto_cifrado)) AS contacto,
        activo
    FROM Concesiones.Empresa_Concesionaria
    WHERE id_empresa = @id_empresa;

    CLOSE SYMMETRIC KEY SK_DatosSensibles;
END;
GO


-- ================================================================================================
-- 8. ADAPTAR SPs DE ALTA/MODIFICACION para que también cifren el DNI / CUIT entrante
--    (se muestran como CREATE OR ALTER para no romper nada existente)
-- ================================================================================================

-- 8.1 Guia_Alta: guarda DNI cifrado en lugar de en claro
CREATE OR ALTER PROCEDURE Personal.Guia_Alta
    @nombre           VARCHAR(50),
    @apellido         VARCHAR(50),
    @fecha_nacimiento DATE,
    @dni              CHAR(10),
    @especialidad     VARCHAR(50),
    @id_titulo        INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @mensaje += 'El nombre es obligatorio.' + CHAR(13);

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @mensaje += 'El apellido es obligatorio.' + CHAR(13);

    IF @fecha_nacimiento IS NULL
        SET @mensaje += 'La fecha de nacimiento es obligatoria.' + CHAR(13);

    IF @dni IS NULL OR LTRIM(RTRIM(@dni)) = ''
        SET @mensaje += 'El DNI es obligatorio.' + CHAR(13);

    IF @especialidad IS NULL OR LTRIM(RTRIM(@especialidad)) = ''
        SET @mensaje += 'La especialidad es obligatoria.' + CHAR(13);

    IF @id_titulo IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM Personal.Titulo WHERE id_titulo = @id_titulo
    )
        SET @mensaje += 'El titulo indicado no existe.' + CHAR(13);

    -- Verificar duplicado de DNI: comparamos descifrado vs. nuevo valor
    -- (apertura de clave necesaria para la búsqueda)
    OPEN SYMMETRIC KEY SK_DatosSensibles
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    IF EXISTS (
        SELECT 1 FROM Personal.Guia
        WHERE CONVERT(NVARCHAR(10), DECRYPTBYKEY(dni_cifrado)) = @dni
    )
        SET @mensaje += 'Ya existe un guia con ese DNI.' + CHAR(13);

    IF @mensaje <> ''
    BEGIN
        CLOSE SYMMETRIC KEY SK_DatosSensibles;
        THROW 50100, @mensaje, 1;
    END

    INSERT INTO Personal.Guia
        (nombre, apellido, fecha_nacimiento, dni, especialidad, id_titulo, dni_cifrado)
    VALUES
        (@nombre, @apellido, @fecha_nacimiento,
         REPLICATE('*', 10),   -- placeholder en columna original
         @especialidad, @id_titulo,
         ENCRYPTBYKEY(KEY_GUID('SK_DatosSensibles'), CONVERT(NVARCHAR(10), @dni))
        );

    CLOSE SYMMETRIC KEY SK_DatosSensibles;
END;
GO

-- 8.2 Guardaparque_Alta: mismo enfoque
CREATE OR ALTER PROCEDURE Personal.Guardaparque_Alta
    @nombre           VARCHAR(50),
    @apellido         VARCHAR(50),
    @dni              CHAR(10),
    @fecha_nacimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @mensaje += 'El nombre es obligatorio.' + CHAR(13);

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @mensaje += 'El apellido es obligatorio.' + CHAR(13);

    IF @dni IS NULL OR LTRIM(RTRIM(@dni)) = ''
        SET @mensaje += 'El DNI es obligatorio.' + CHAR(13);

    IF @fecha_nacimiento IS NULL
        SET @mensaje += 'La fecha de nacimiento es obligatoria.' + CHAR(13);

    OPEN SYMMETRIC KEY SK_DatosSensibles
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    IF EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE CONVERT(NVARCHAR(10), DECRYPTBYKEY(dni_cifrado)) = @dni
    )
        SET @mensaje += 'Ya existe un guardaparque con ese DNI.' + CHAR(13);

    IF @mensaje <> ''
    BEGIN
        CLOSE SYMMETRIC KEY SK_DatosSensibles;
        THROW 50200, @mensaje, 1;
    END

    INSERT INTO Personal.Guardaparque
        (nombre, apellido, dni, fecha_nacimiento, dni_cifrado)
    VALUES
        (@nombre, @apellido,
         REPLICATE('*', 10),
         @fecha_nacimiento,
         ENCRYPTBYKEY(KEY_GUID('SK_DatosSensibles'), CONVERT(NVARCHAR(10), @dni))
        );

    CLOSE SYMMETRIC KEY SK_DatosSensibles;
END;
GO

-- 8.3 Empresa_Concesionaria_Alta: cifra CUIT y contacto
CREATE OR ALTER PROCEDURE Concesiones.Empresa_Concesionaria_Alta
    @razon_social VARCHAR(30),
    @cuit         VARCHAR(15),
    @contacto     VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @razon_social IS NULL OR LTRIM(RTRIM(@razon_social)) = ''
        SET @mensaje += 'La razon social es obligatoria.' + CHAR(13);

    IF @cuit IS NULL OR LTRIM(RTRIM(@cuit)) = ''
        SET @mensaje += 'El CUIT es obligatorio.' + CHAR(13);

    IF @contacto IS NULL OR LTRIM(RTRIM(@contacto)) = ''
        SET @mensaje += 'El contacto es obligatorio.' + CHAR(13);

    OPEN SYMMETRIC KEY SK_DatosSensibles
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    IF EXISTS (
        SELECT 1 FROM Concesiones.Empresa_Concesionaria
        WHERE CONVERT(NVARCHAR(15), DECRYPTBYKEY(cuit_cifrado)) = @cuit
    )
        SET @mensaje += 'Ya existe una empresa con ese CUIT.' + CHAR(13);

    IF @mensaje <> ''
    BEGIN
        CLOSE SYMMETRIC KEY SK_DatosSensibles;
        THROW 50500, @mensaje, 1;
    END

    INSERT INTO Concesiones.Empresa_Concesionaria
        (razon_social, cuit, contacto, cuit_cifrado, contacto_cifrado)
    VALUES
        (@razon_social,
         REPLICATE('*', 15),
         REPLICATE('*', 30),
         ENCRYPTBYKEY(KEY_GUID('SK_DatosSensibles'), CONVERT(NVARCHAR(15), @cuit)),
         ENCRYPTBYKEY(KEY_GUID('SK_DatosSensibles'), CONVERT(NVARCHAR(30), @contacto))
        );

    CLOSE SYMMETRIC KEY SK_DatosSensibles;
END;
GO

PRINT 'Script de cifrado aplicado exitosamente.';
GO
