/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: Seguridad: Cifrado de datos sensibles.
--
--   Se identificaron como datos sensibles:
--     - DNI de Guia y Guardaparque
--     - CUIT de Empresa_Concesionaria
--
--   ESTRATEGIA:
--     1. Se crea infraestructura de cifrado (Master Key, Certificado, Clave Simetrica AES-256).
--     2. Se agregan columnas cifradas (_cifrado) y de hash SHA2_256 (_hash) a las tablas afectadas.
--     3. Se migran los datos existentes: se cifran y hashean en una unica transaccion.
--     4. Se reemplazan los UNIQUE constraints de las columnas en claro por UNIQUE sobre el hash.
--     5. Se anonimiza la columna original (el dato en claro se sobreescribe con asteriscos).
--     6. Se adaptan los SPs de Alta para cifrar y hashear al insertar.
--     7. Se crean SPs de lectura que descifran bajo demanda.
================================================================================================= */

USE ParquesNacionales;
GO

-- ================================================================================================
-- 1. MASTER KEY
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
-- 2. CERTIFICADO
-- ================================================================================================
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'Cert_DatosSensibles')
BEGIN
    CREATE CERTIFICATE Cert_DatosSensibles
        WITH SUBJECT = 'Certificado para cifrado de datos sensibles - Parques Nacionales';
    PRINT 'Certificado creado.';
END
ELSE
    PRINT 'Certificado ya existia.';
GO

-- ================================================================================================
-- 3. CLAVE SIMETRICA AES-256
-- ================================================================================================
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'Clave_simetrica')
BEGIN
    CREATE SYMMETRIC KEY Clave_simetrica
        WITH ALGORITHM = AES_256
        ENCRYPTION BY CERTIFICATE Cert_DatosSensibles;
    PRINT 'Clave simetrica creada.';
END
ELSE
    PRINT 'Clave simetrica ya existia.';
GO

-- ================================================================================================
-- 4. MIGRACION DE Personal.Guia
-- ================================================================================================

-- 4.1 Agregar columnas si no existen
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Personal.Guia') AND name = 'dni_cifrado')
    ALTER TABLE Personal.Guia ADD dni_cifrado VARBINARY(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Personal.Guia') AND name = 'dni_hash')
    ALTER TABLE Personal.Guia ADD dni_hash VARBINARY(32) NULL;
GO

-- 4.2 Cifrar y hashear datos existentes en una sola apertura de clave
BEGIN TRY
    OPEN SYMMETRIC KEY Clave_simetrica
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    -- Cifrar y hashear solo los registros que aun no fueron migrados
    -- y cuyo dni no es ya un placeholder de asteriscos
    UPDATE Personal.Guia
    SET
        dni_cifrado = ENCRYPTBYKEY(KEY_GUID('Clave_simetrica'), CONVERT(NVARCHAR(10), dni)),
        dni_hash    = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(10), dni))
    WHERE dni_cifrado IS NULL
      AND dni NOT LIKE '%*%';

    CLOSE SYMMETRIC KEY Clave_simetrica;
    PRINT 'Personal.Guia: datos cifrados y hasheados.';
END TRY
BEGIN CATCH
    IF (SELECT COUNT(*) FROM sys.openkeys WHERE key_name = 'Clave_simetrica') > 0
        CLOSE SYMMETRIC KEY Clave_simetrica;
    THROW;
END CATCH
GO

-- 4.3 Reemplazar UNIQUE de dni por UNIQUE sobre dni_hash
DECLARE @uc NVARCHAR(200);
SELECT @uc = name FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID('Personal.Guia') AND type = 'UQ';

IF @uc IS NOT NULL
    EXEC ('ALTER TABLE Personal.Guia DROP CONSTRAINT ' + @uc);

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('Personal.Guia') AND name = 'UQ_Guia_dni_hash')
    ALTER TABLE Personal.Guia ADD CONSTRAINT UQ_Guia_dni_hash UNIQUE (dni_hash);
GO

-- 4.4 Anonimizar columna original
UPDATE Personal.Guia
SET dni = '**********'
WHERE dni_cifrado IS NOT NULL
  AND dni NOT LIKE '%*%';

PRINT 'Personal.Guia: dni original anonimizado.';
GO

-- ================================================================================================
-- 5. MIGRACION DE Personal.Guardaparque
-- ================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Personal.Guardaparque') AND name = 'dni_cifrado')
    ALTER TABLE Personal.Guardaparque ADD dni_cifrado VARBINARY(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Personal.Guardaparque') AND name = 'dni_hash')
    ALTER TABLE Personal.Guardaparque ADD dni_hash VARBINARY(32) NULL;
GO

BEGIN TRY
    OPEN SYMMETRIC KEY Clave_simetrica
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    UPDATE Personal.Guardaparque
    SET
        dni_cifrado = ENCRYPTBYKEY(KEY_GUID('Clave_simetrica'), CONVERT(NVARCHAR(10), dni)),
        dni_hash    = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(10), dni))
    WHERE dni_cifrado IS NULL
      AND dni NOT LIKE '%*%';

    CLOSE SYMMETRIC KEY Clave_simetrica;
    PRINT 'Personal.Guardaparque: datos cifrados y hasheados.';
END TRY
BEGIN CATCH
    IF (SELECT COUNT(*) FROM sys.openkeys WHERE key_name = 'Clave_simetrica') > 0
        CLOSE SYMMETRIC KEY Clave_simetrica;
    THROW;
END CATCH
GO

DECLARE @uc2 NVARCHAR(200);
SELECT @uc2 = name FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID('Personal.Guardaparque') AND type = 'UQ';

IF @uc2 IS NOT NULL
    EXEC ('ALTER TABLE Personal.Guardaparque DROP CONSTRAINT ' + @uc2);

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('Personal.Guardaparque') AND name = 'UQ_Guardaparque_dni_hash')
    ALTER TABLE Personal.Guardaparque ADD CONSTRAINT UQ_Guardaparque_dni_hash UNIQUE (dni_hash);
GO

UPDATE Personal.Guardaparque
SET dni = '**********'
WHERE dni_cifrado IS NOT NULL
  AND dni NOT LIKE '%*%';

PRINT 'Personal.Guardaparque: dni original anonimizado.';
GO

-- ================================================================================================
-- 6. MIGRACION DE Concesiones.Empresa_Concesionaria
-- ================================================================================================

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Concesiones.Empresa_Concesionaria') AND name = 'cuit_cifrado')
    ALTER TABLE Concesiones.Empresa_Concesionaria ADD cuit_cifrado VARBINARY(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Concesiones.Empresa_Concesionaria') AND name = 'cuit_hash')
    ALTER TABLE Concesiones.Empresa_Concesionaria ADD cuit_hash VARBINARY(32) NULL;
GO

BEGIN TRY
    OPEN SYMMETRIC KEY Clave_simetrica
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    UPDATE Concesiones.Empresa_Concesionaria
    SET
        cuit_cifrado = ENCRYPTBYKEY(KEY_GUID('Clave_simetrica'), CONVERT(NVARCHAR(15), cuit)),
        cuit_hash    = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(15), cuit))
    WHERE cuit_cifrado IS NULL
      AND cuit NOT LIKE '%*%';

    CLOSE SYMMETRIC KEY Clave_simetrica;
    PRINT 'Empresa_Concesionaria: datos cifrados y hasheados.';
END TRY
BEGIN CATCH
    IF (SELECT COUNT(*) FROM sys.openkeys WHERE key_name = 'Clave_simetrica') > 0
        CLOSE SYMMETRIC KEY Clave_simetrica;
    THROW;
END CATCH
GO

DECLARE @uc3 NVARCHAR(200);
SELECT @uc3 = name FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID('Concesiones.Empresa_Concesionaria') AND type = 'UQ';

IF @uc3 IS NOT NULL
    EXEC ('ALTER TABLE Concesiones.Empresa_Concesionaria DROP CONSTRAINT ' + @uc3);

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('Concesiones.Empresa_Concesionaria') AND name = 'UQ_Empresa_cuit_hash')
    ALTER TABLE Concesiones.Empresa_Concesionaria ADD CONSTRAINT UQ_Empresa_cuit_hash UNIQUE (cuit_hash);
GO

UPDATE Concesiones.Empresa_Concesionaria
SET cuit = '***************'
WHERE cuit_cifrado IS NOT NULL
  AND cuit NOT LIKE '%*%';

PRINT 'Empresa_Concesionaria: cuit original anonimizado.';
GO

-- ================================================================================================
-- 7. SPs DE LECTURA CON DESCIFRADO
-- ================================================================================================
CREATE OR ALTER PROCEDURE Personal.Guia_ObtenerDNI
    @id_guia INT
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY Clave_simetrica
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

    CLOSE SYMMETRIC KEY Clave_simetrica;
END;
GO

CREATE OR ALTER PROCEDURE Personal.Guardaparque_ObtenerDNI
    @id_guardaparque INT
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY Clave_simetrica
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

    CLOSE SYMMETRIC KEY Clave_simetrica;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.Empresa_ObtenerCUIT
    @id_empresa INT
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY Clave_simetrica
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    SELECT
        id_empresa,
        razon_social,
        CONVERT(NVARCHAR(15), DECRYPTBYKEY(cuit_cifrado)) AS cuit,
        contacto,
        activo
    FROM Concesiones.Empresa_Concesionaria
    WHERE id_empresa = @id_empresa;

    CLOSE SYMMETRIC KEY Clave_simetrica;
END;
GO

-- ================================================================================================
-- 8. SPs DE ALTA ADAPTADOS PARA CIFRAR AL INSERTAR
-- ================================================================================================
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

    IF EXISTS (
        SELECT 1 FROM Personal.Guia
        WHERE dni_hash = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(10), @dni))
    )
        SET @mensaje += 'Ya existe un guia con ese DNI.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50100, @mensaje, 1;

    OPEN SYMMETRIC KEY Clave_simetrica
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    INSERT INTO Personal.Guia
        (nombre, apellido, fecha_nacimiento, dni, especialidad, id_titulo, dni_cifrado, dni_hash)
    VALUES
        (@nombre, @apellido, @fecha_nacimiento,
         '**********',
         @especialidad, @id_titulo,
         ENCRYPTBYKEY(KEY_GUID('Clave_simetrica'), CONVERT(NVARCHAR(10), @dni)),
         HASHBYTES('SHA2_256', CONVERT(NVARCHAR(10), @dni))
        );

    CLOSE SYMMETRIC KEY Clave_simetrica;
END;
GO

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

    IF EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE dni_hash = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(10), @dni))
    )
        SET @mensaje += 'Ya existe un guardaparque con ese DNI.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50200, @mensaje, 1;

    OPEN SYMMETRIC KEY Clave_simetrica
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    INSERT INTO Personal.Guardaparque
        (nombre, apellido, dni, fecha_nacimiento, dni_cifrado, dni_hash)
    VALUES
        (@nombre, @apellido,
         '**********',
         @fecha_nacimiento,
         ENCRYPTBYKEY(KEY_GUID('Clave_simetrica'), CONVERT(NVARCHAR(10), @dni)),
         HASHBYTES('SHA2_256', CONVERT(NVARCHAR(10), @dni))
        );

    CLOSE SYMMETRIC KEY Clave_simetrica;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.Empresa_Concesionaria_Alta
    @razon_social VARCHAR(30),
    @cuit         VARCHAR(15),
    @contacto     VARCHAR(60)
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

    IF EXISTS (
        SELECT 1 FROM Concesiones.Empresa_Concesionaria
        WHERE cuit_hash = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(15), @cuit))
    )
        SET @mensaje += 'Ya existe una empresa con ese CUIT.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50500, @mensaje, 1;

    OPEN SYMMETRIC KEY Clave_simetrica
        DECRYPTION BY CERTIFICATE Cert_DatosSensibles;

    INSERT INTO Concesiones.Empresa_Concesionaria
        (razon_social, cuit, contacto, cuit_cifrado, cuit_hash)
    VALUES
        (@razon_social,
         '***************',
         @contacto,
         ENCRYPTBYKEY(KEY_GUID('Clave_simetrica'), CONVERT(NVARCHAR(15), @cuit)),
         HASHBYTES('SHA2_256', CONVERT(NVARCHAR(15), @cuit))
        );

    CLOSE SYMMETRIC KEY Clave_simetrica;
END;
GO

PRINT 'Script de cifrado aplicado exitosamente.';
GO