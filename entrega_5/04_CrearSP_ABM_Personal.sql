/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCIÓN: SP de ABM de las tablas pertenecientes al esquema Personal.
-- Tablas: Titulo, Guia, Habilitacion_Guia, GuardaParque, Asignacion_Guardaparque, Asignacion_Guia
================================================================================================= */

USE ParquesNacionales;
GO

-- ================================================================================================
-- Titulo
-- ================================================================================================

CREATE OR ALTER PROCEDURE Personal.Titulo_Alta
    @descripcion VARCHAR(60)
AS
BEGIN
    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @mensaje += 'La descripcion es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Titulo
        WHERE descripcion = @descripcion
    )
        SET @mensaje += 'Ya existe un titulo con esa descripcion.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50100, @mensaje, 1;

    INSERT INTO Personal.Titulo (descripcion)
    VALUES (@descripcion);
END;
GO


CREATE OR ALTER PROCEDURE Personal.Titulo_Modificar
    @id_titulo INT,
    @descripcion VARCHAR(60)
AS
BEGIN
    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Titulo
        WHERE id_titulo = @id_titulo
    )
        SET @mensaje += 'El titulo no existe.' + CHAR(13);

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @mensaje += 'La descripcion es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Titulo
        WHERE descripcion = @descripcion
          AND id_titulo <> @id_titulo
    )
        SET @mensaje += 'Ya existe otro titulo con esa descripcion.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50101, @mensaje, 1;

    UPDATE Personal.Titulo
    SET descripcion = @descripcion
    WHERE id_titulo = @id_titulo;
END;
GO


CREATE OR ALTER PROCEDURE Personal.Titulo_Baja
    @id_titulo INT
AS
BEGIN
    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Titulo
        WHERE id_titulo = @id_titulo
    )
        SET @mensaje += 'El titulo no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Guia
        WHERE id_titulo = @id_titulo
    )
        SET @mensaje += 'No se puede eliminar porque existen guias asociados.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50102, @mensaje, 1;

    DELETE FROM Personal.Titulo
    WHERE id_titulo = @id_titulo;
END;
GO


-- ================================================================================================
-- Guia
-- ================================================================================================

CREATE OR ALTER PROCEDURE Personal.Guia_Alta
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @fecha_nacimiento DATE,
    @dni CHAR(10),
    @especialidad VARCHAR(100),
    @id_titulo INT = NULL
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

    IF EXISTS (
        SELECT 1
        FROM Personal.Guia
        WHERE dni = @dni
    )
        SET @mensaje += 'Ya existe un guía con ese DNI.' + CHAR(13);

    IF @id_titulo IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM Personal.Titulo
            WHERE id_titulo = @id_titulo
       )
        SET @mensaje += 'El título indicado no existe.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50110, @mensaje, 1;

    INSERT INTO Personal.Guia
    (
        nombre,
        apellido,
        fecha_nacimiento,
        dni,
        especialidad,
        id_titulo
    )
    VALUES
    (
        @nombre,
        @apellido,
        @fecha_nacimiento,
        @dni,
        @especialidad,
        @id_titulo
    );
END;
GO



CREATE OR ALTER PROCEDURE Personal.Guia_Modificar
    @id_guia INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @fecha_nacimiento DATE,
    @dni CHAR(10),
    @especialidad VARCHAR(100),
    @id_titulo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Guia
        WHERE id_guia = @id_guia
    )
        SET @mensaje += 'El guía no existe.' + CHAR(13);

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

    IF EXISTS (
        SELECT 1
        FROM Personal.Guia
        WHERE dni = @dni
          AND id_guia <> @id_guia
    )
        SET @mensaje += 'Ya existe otro guía con ese DNI.' + CHAR(13);

    IF @id_titulo IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM Personal.Titulo
            WHERE id_titulo = @id_titulo
       )
        SET @mensaje += 'El título indicado no existe.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50111, @mensaje, 1;

    UPDATE Personal.Guia
    SET nombre = @nombre,
        apellido = @apellido,
        fecha_nacimiento = @fecha_nacimiento,
        dni = @dni,
        especialidad = @especialidad,
        id_titulo = @id_titulo
    WHERE id_guia = @id_guia;
END;
GO



CREATE OR ALTER PROCEDURE Personal.Guia_Baja
    @id_guia INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Guia
        WHERE id_guia = @id_guia
          AND activo = 1
    )
        SET @mensaje += 'El guía no existe o ya se encuentra inactivo.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Asignacion_Guia
        WHERE id_guia = @id_guia
          AND fecha_egreso IS NULL
    )
        SET @mensaje += 'No se puede desactivar un guía con asignaciones activas.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50112, @mensaje, 1;

    UPDATE Personal.Guia
    SET activo = 0
    WHERE id_guia = @id_guia;
END;
GO


-- ================================================================================================
-- Guardaparque
-- ================================================================================================
CREATE OR ALTER PROCEDURE Personal.Guardaparque_Alta
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @dni CHAR(10),
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
        SELECT 1
        FROM Personal.Guardaparque
        WHERE dni = @dni
    )
        SET @mensaje += 'Ya existe un guardaparque con ese DNI.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50120, @mensaje, 1;

    INSERT INTO Personal.Guardaparque
    (
        nombre,
        apellido,
        dni,
        fecha_nacimiento
    )
    VALUES
    (
        @nombre,
        @apellido,
        @dni,
        @fecha_nacimiento
    );
END;
GO



CREATE OR ALTER PROCEDURE Personal.Guardaparque_Modificar
    @id_guardaparque INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @dni CHAR(10),
    @fecha_nacimiento DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Guardaparque
        WHERE id_guardaparque = @id_guardaparque
    )
        SET @mensaje += 'El guardaparque no existe.' + CHAR(13);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @mensaje += 'El nombre es obligatorio.' + CHAR(13);

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @mensaje += 'El apellido es obligatorio.' + CHAR(13);

    IF @dni IS NULL OR LTRIM(RTRIM(@dni)) = ''
        SET @mensaje += 'El DNI es obligatorio.' + CHAR(13);

    IF @fecha_nacimiento IS NULL
        SET @mensaje += 'La fecha de nacimiento es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Guardaparque
        WHERE dni = @dni
          AND id_guardaparque <> @id_guardaparque
    )
        SET @mensaje += 'Ya existe otro guardaparque con ese DNI.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50121, @mensaje, 1;

    UPDATE Personal.Guardaparque
    SET nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        fecha_nacimiento = @fecha_nacimiento
    WHERE id_guardaparque = @id_guardaparque;
END;
GO



CREATE OR ALTER PROCEDURE Personal.Guardaparque_Baja
    @id_guardaparque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Guardaparque
        WHERE id_guardaparque = @id_guardaparque
          AND activo = 1
    )
        SET @mensaje += 'El guardaparque no existe o ya se encuentra inactivo.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Asignacion_Guardaparque
        WHERE id_guardaparque = @id_guardaparque
          AND fecha_egreso IS NULL
    )
        SET @mensaje += 'No se puede desactivar un guardaparque con asignaciones activas.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50122, @mensaje, 1;

    UPDATE Personal.Guardaparque
    SET activo = 0
    WHERE id_guardaparque = @id_guardaparque;
END;
GO


-- ================================================================================================
-- Habilitacion_Guia
-- ================================================================================================
CREATE OR ALTER PROCEDURE Personal.Habilitacion_Guia_Alta
    @nro_matricula VARCHAR(20),
    @fecha_emision DATE,
    @estado VARCHAR(15),
    @id_guia INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @nro_matricula IS NULL OR LTRIM(RTRIM(@nro_matricula)) = ''
        SET @mensaje += 'El número de matrícula es obligatorio.' + CHAR(13);

    IF @fecha_emision IS NULL
        SET @mensaje += 'La fecha de emisión es obligatoria.' + CHAR(13);

    IF @estado NOT IN ('Activa', 'Inactiva')
        SET @mensaje += 'El estado es inválido.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Guia
        WHERE id_guia = @id_guia
          AND activo = 1
    )
        SET @mensaje += 'El guía no existe o está inactivo.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Habilitacion_Guia
        WHERE nro_matricula = @nro_matricula
    )
        SET @mensaje += 'Ya existe una habilitación con ese número de matrícula.' + CHAR(13);

    IF @estado = 'Activa'
       AND EXISTS (
            SELECT 1
            FROM Personal.Habilitacion_Guia
            WHERE id_guia = @id_guia
              AND estado = 'Activa'
       )
        SET @mensaje += 'El guía ya posee una habilitación activa.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50150, @mensaje, 1;

    INSERT INTO Personal.Habilitacion_Guia
    (
        nro_matricula,
        fecha_emision,
        estado,
        id_guia
    )
    VALUES
    (
        @nro_matricula,
        @fecha_emision,
        @estado,
        @id_guia
    );
END;
GO


CREATE OR ALTER PROCEDURE Personal.Habilitacion_Guia_Modificar
    @id_habilitacion INT,
    @nro_matricula VARCHAR(20),
    @fecha_emision DATE,
    @estado VARCHAR(15),
    @id_guia INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Habilitacion_Guia
        WHERE id_habilitacion = @id_habilitacion
    )
        SET @mensaje += 'La habilitación no existe.' + CHAR(13);

    IF @nro_matricula IS NULL OR LTRIM(RTRIM(@nro_matricula)) = ''
        SET @mensaje += 'El número de matrícula es obligatorio.' + CHAR(13);

    IF @fecha_emision IS NULL
        SET @mensaje += 'La fecha de emisión es obligatoria.' + CHAR(13);

    IF @estado NOT IN ('Activa', 'Inactiva')
        SET @mensaje += 'El estado es inválido.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Guia
        WHERE id_guia = @id_guia
          AND activo = 1
    )
        SET @mensaje += 'El guía no existe o está inactivo.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Habilitacion_Guia
        WHERE nro_matricula = @nro_matricula
          AND id_habilitacion <> @id_habilitacion
    )
        SET @mensaje += 'Ya existe otra habilitación con ese número de matrícula.' + CHAR(13);

    IF @estado = 'Activa'
       AND EXISTS (
            SELECT 1
            FROM Personal.Habilitacion_Guia
            WHERE id_guia = @id_guia
              AND estado = 'Activa'
              AND id_habilitacion <> @id_habilitacion
       )
        SET @mensaje += 'El guía ya posee otra habilitación activa.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50151, @mensaje, 1;

    UPDATE Personal.Habilitacion_Guia
    SET nro_matricula = @nro_matricula,
        fecha_emision = @fecha_emision,
        estado = @estado,
        id_guia = @id_guia
    WHERE id_habilitacion = @id_habilitacion;
END;
GO


CREATE OR ALTER PROCEDURE Personal.Habilitacion_Guia_Baja
    @id_habilitacion INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Habilitacion_Guia
        WHERE id_habilitacion = @id_habilitacion
    )
        SET @mensaje += 'La habilitación no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Habilitacion_Guia
        WHERE id_habilitacion = @id_habilitacion
          AND estado = 'Inactiva'
    )
        SET @mensaje += 'La habilitación ya se encuentra inactiva.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50152, @mensaje, 1;

    UPDATE Personal.Habilitacion_Guia
    SET estado = 'Inactiva'
    WHERE id_habilitacion = @id_habilitacion;
END;
GO

-- ================================================================================================
-- Asignacion_Guia
-- ================================================================================================
CREATE OR ALTER PROCEDURE Personal.Asignacion_Guia_Alta
    @id_atraccion INT,
    @id_guia INT,
    @fecha_inicio DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @fecha_inicio IS NULL
        SET @mensaje += 'La fecha de inicio es obligatoria.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Guia
        WHERE id_guia = @id_guia
          AND activo = 1
    )
        SET @mensaje += 'El guía no existe o está inactivo.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Habilitacion_Guia
        WHERE id_guia = @id_guia
          AND estado = 'Activa'
    )
        SET @mensaje += 'El guía no posee una habilitación activa.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Atraccion
        WHERE id_atraccion = @id_atraccion
          AND activo = 1
    )
        SET @mensaje += 'La atracción no existe o está inactiva.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Asignacion_Guia
        WHERE id_guia = @id_guia
          AND id_atraccion = @id_atraccion
          AND fecha_egreso IS NULL
    )
        SET @mensaje += 'El guía ya se encuentra asignado a esta atracción.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50140, @mensaje, 1;

    INSERT INTO Personal.Asignacion_Guia
    (
        id_atraccion,
        id_guia,
        fecha_inicio
    )
    VALUES
    (
        @id_atraccion,
        @id_guia,
        @fecha_inicio
    );
END;
GO

CREATE OR ALTER PROCEDURE Personal.Asignacion_Guia_Modificar
    @id_asignacion INT,
    @id_atraccion INT,
    @fecha_inicio DATE,
    @fecha_egreso DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Asignacion_Guia
        WHERE id_asignacion = @id_asignacion
    )
        SET @mensaje += 'La asignación no existe.' + CHAR(13);

    IF @fecha_inicio IS NULL
        SET @mensaje += 'La fecha de inicio es obligatoria.' + CHAR(13);

    IF @fecha_egreso IS NOT NULL
       AND @fecha_egreso < @fecha_inicio
        SET @mensaje += 'La fecha de egreso no puede ser anterior a la fecha de inicio.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Atraccion
        WHERE id_atraccion = @id_atraccion
          AND activo = 1
    )
        SET @mensaje += 'La atracción indicada no existe o está inactiva.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50141, @mensaje, 1;

    UPDATE Personal.Asignacion_Guia
    SET id_atraccion = @id_atraccion,
        fecha_inicio = @fecha_inicio,
        fecha_egreso = @fecha_egreso
    WHERE id_asignacion = @id_asignacion;
END;
GO


CREATE OR ALTER PROCEDURE Personal.Asignacion_Guia_Baja
    @id_asignacion INT,
    @fecha_egreso DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';
    DECLARE @fecha_inicio DATE;

    SELECT @fecha_inicio = fecha_inicio
    FROM Personal.Asignacion_Guia
    WHERE id_asignacion = @id_asignacion;

    IF @fecha_inicio IS NULL
        SET @mensaje += 'La asignación no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Asignacion_Guia
        WHERE id_asignacion = @id_asignacion
          AND fecha_egreso IS NOT NULL
    )
        SET @mensaje += 'La asignación ya se encuentra finalizada.' + CHAR(13);

    IF @fecha_egreso IS NULL
        SET @mensaje += 'La fecha de egreso es obligatoria.' + CHAR(13);

    IF @fecha_inicio IS NOT NULL
       AND @fecha_egreso < @fecha_inicio
        SET @mensaje += 'La fecha de egreso no puede ser anterior a la fecha de inicio.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50142, @mensaje, 1;

    UPDATE Personal.Asignacion_Guia
    SET fecha_egreso = @fecha_egreso
    WHERE id_asignacion = @id_asignacion;
END;
GO

-- ================================================================================================
-- Asignacion_Guardaparque
-- ================================================================================================

CREATE OR ALTER PROCEDURE Personal.Asignacion_Guardaparque_Alta
    @fecha_ingreso DATE,
    @id_guardaparque INT,
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @fecha_ingreso IS NULL
        SET @mensaje += 'La fecha de ingreso es obligatoria.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Guardaparque
        WHERE id_guardaparque = @id_guardaparque
          AND activo = 1
    )
        SET @mensaje += 'El guardaparque no existe o está inactivo.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
          AND activo = 1
    )
        SET @mensaje += 'El parque no existe o está inactivo.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Asignacion_Guardaparque
        WHERE id_guardaparque = @id_guardaparque
          AND fecha_egreso IS NULL
    )
        SET @mensaje += 'El guardaparque ya posee una asignación activa.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50130, @mensaje, 1;

    INSERT INTO Personal.Asignacion_Guardaparque
    (
        fecha_ingreso,
        id_guardaparque,
        id_parque
    )
    VALUES
    (
        @fecha_ingreso,
        @id_guardaparque,
        @id_parque
    );
END;
GO

CREATE OR ALTER PROCEDURE Personal.Asignacion_Guardaparque_Modificar
    @id_asignacion INT,
    @fecha_ingreso DATE,
    @fecha_egreso DATE = NULL,
    @motivo_egreso VARCHAR(100) = NULL,
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Asignacion_Guardaparque
        WHERE id_asignacion = @id_asignacion
    )
        SET @mensaje += 'La asignación no existe.' + CHAR(13);

    IF @fecha_ingreso IS NULL
        SET @mensaje += 'La fecha de ingreso es obligatoria.' + CHAR(13);

    IF @fecha_egreso IS NOT NULL
       AND @fecha_egreso < @fecha_ingreso
        SET @mensaje += 'La fecha de egreso no puede ser anterior a la fecha de ingreso.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
          AND activo = 1
    )
        SET @mensaje += 'El parque indicado no existe o está inactivo.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50131, @mensaje, 1;

    UPDATE Personal.Asignacion_Guardaparque
    SET fecha_ingreso = @fecha_ingreso,
        fecha_egreso = @fecha_egreso,
        motivo_egreso = @motivo_egreso,
        id_parque = @id_parque
    WHERE id_asignacion = @id_asignacion;
END;
GO

CREATE OR ALTER PROCEDURE Personal.Asignacion_Guardaparque_Baja
    @id_asignacion INT,
    @fecha_egreso DATE,
    @motivo_egreso VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    DECLARE @fecha_ingreso DATE;

    SELECT @fecha_ingreso = fecha_ingreso
    FROM Personal.Asignacion_Guardaparque
    WHERE id_asignacion = @id_asignacion;

    IF @fecha_ingreso IS NULL
        SET @mensaje += 'La asignación no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Asignacion_Guardaparque
        WHERE id_asignacion = @id_asignacion
          AND fecha_egreso IS NOT NULL
    )
        SET @mensaje += 'La asignación ya se encuentra finalizada.' + CHAR(13);

    IF @fecha_egreso IS NULL
        SET @mensaje += 'La fecha de egreso es obligatoria.' + CHAR(13);

    IF @fecha_ingreso IS NOT NULL
       AND @fecha_egreso < @fecha_ingreso
        SET @mensaje += 'La fecha de egreso no puede ser anterior a la fecha de ingreso.' + CHAR(13);

    IF @motivo_egreso IS NULL
       OR LTRIM(RTRIM(@motivo_egreso)) = ''
        SET @mensaje += 'Debe indicar el motivo de egreso.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50132, @mensaje, 1;

    UPDATE Personal.Asignacion_Guardaparque
    SET fecha_egreso = @fecha_egreso,
        motivo_egreso = @motivo_egreso
    WHERE id_asignacion = @id_asignacion;
END;
GO




