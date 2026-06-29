/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCIÓN: SP de ABM de las tablas pertenecientes al esquema GestionParques.
-- Tablas: Tipo_Parque, Parque, Atraccion
================================================================================================= */

USE ParquesNacionales;
GO

-- ================================================================================================
-- Tipo_Parque
-- ================================================================================================
CREATE OR ALTER PROCEDURE GestionParques.Tipo_Parque_Alta
    @descripcion VARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(50) = '';

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @mensaje += 'La descripcion es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM GestionParques.Tipo_Parque
        WHERE descripcion = @descripcion
    )
        SET @mensaje += 'Ya existe un tipo de parque con esa descripcion.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50001, @mensaje, 1;

    INSERT INTO GestionParques.Tipo_Parque (descripcion)
    VALUES (@descripcion);
END;
GO

CREATE OR ALTER PROCEDURE GestionParques.Tipo_Parque_Modificar
    @id_tipo_parque INT,
    @descripcion VARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(60) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Tipo_Parque
        WHERE id_tipo_parque = @id_tipo_parque
    )
        SET @mensaje += 'El tipo de parque no existe.' + CHAR(13);

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @mensaje += 'La descripcion es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM GestionParques.Tipo_Parque
        WHERE descripcion = @descripcion
          AND id_tipo_parque <> @id_tipo_parque
    )
        SET @mensaje += 'Ya existe otro tipo de parque con esa descripcion.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50002, @mensaje, 1;

    UPDATE GestionParques.Tipo_Parque
    SET descripcion = @descripcion
    WHERE id_tipo_parque = @id_tipo_parque;
END;
GO

CREATE OR ALTER PROCEDURE GestionParques.Tipo_Parque_Baja
    @id_tipo_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(60) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Tipo_Parque
        WHERE id_tipo_parque = @id_tipo_parque
    )
        SET @mensaje += 'El tipo de parque no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_tipo_parque = @id_tipo_parque
    )
        SET @mensaje += 'No se puede eliminar porque existen parques asociados.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50003, @mensaje, 1;

    DELETE FROM GestionParques.Tipo_Parque
    WHERE id_tipo_parque = @id_tipo_parque;
END;
GO


-- ================================================================================================
-- Parque
-- ================================================================================================
CREATE OR ALTER PROCEDURE GestionParques.Parque_Alta
    @nombre VARCHAR(100),
    @ubicacion VARCHAR(50),
    @superficie DECIMAL,
    @id_tipo_parque INT
AS
BEGIN
    DECLARE @mensaje VARCHAR(50) = '';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @mensaje += 'El nombre es obligatorio.' + CHAR(13);

    IF @ubicacion IS NULL OR LTRIM(RTRIM(@ubicacion)) = ''
        SET @mensaje += 'La ubicacion es obligatoria.' + CHAR(13);

    IF @superficie IS NULL OR @superficie <= 0
        SET @mensaje += 'La superficie debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Tipo_Parque
        WHERE id_tipo_parque = @id_tipo_parque
    )
        SET @mensaje += 'El tipo de parque indicado no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE nombre = @nombre
          AND ubicacion = @ubicacion
    )
        SET @mensaje += 'Ya existe un parque con ese nombre y ubicacion.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50010, @mensaje, 1;

    INSERT INTO GestionParques.Parque
    (
        nombre,
        ubicacion,
        superficie,
        id_tipo_parque
    )
    VALUES
    (
        @nombre,
        @ubicacion,
        @superficie,
        @id_tipo_parque
    );
END;
GO

CREATE OR ALTER PROCEDURE GestionParques.Parque_Modificar
    @id_parque INT,
    @nombre VARCHAR(100),
    @ubicacion VARCHAR(50),
    @superficie DECIMAL,
    @id_tipo_parque INT
AS
BEGIN
    DECLARE @mensaje VARCHAR(50) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
    )
        SET @mensaje += 'El parque no existe.' + CHAR(13);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @mensaje += 'El nombre es obligatorio.' + CHAR(13);

    IF @ubicacion IS NULL OR LTRIM(RTRIM(@ubicacion)) = ''
        SET @mensaje += 'La ubicacion es obligatoria.' + CHAR(13);

    IF @superficie IS NULL OR @superficie <= 0
        SET @mensaje += 'La superficie debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Tipo_Parque
        WHERE id_tipo_parque = @id_tipo_parque
    )
        SET @mensaje += 'El tipo de parque indicado no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE nombre = @nombre
          AND ubicacion = @ubicacion
          AND id_parque <> @id_parque
    )
        SET @mensaje += 'Ya existe otro parque con ese nombre y ubicacion.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50011, @mensaje, 1;

    UPDATE GestionParques.Parque
    SET nombre = @nombre,
        ubicacion = @ubicacion,
        superficie = @superficie,
        id_tipo_parque = @id_tipo_parque
    WHERE id_parque = @id_parque;
END;
GO

CREATE OR ALTER PROCEDURE GestionParques.Parque_Baja
    @id_parque INT
AS
BEGIN
    DECLARE @mensaje VARCHAR(50) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
    )
        SET @mensaje += 'El parque no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
          AND activo = 0
    )
        SET @mensaje += 'El parque ya se encuentra dado de baja.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50012, @mensaje, 1;

    UPDATE GestionParques.Parque
    SET activo = 0
    WHERE id_parque = @id_parque;
END;
GO


-- ================================================================================================
-- Atraccion
-- ================================================================================================
CREATE OR ALTER PROCEDURE GestionParques.Atraccion_Alta
    @nombre VARCHAR(50),
    @costo DECIMAL,
    @duracion_minutos SMALLINT,
    @cupo_maximo SMALLINT,
    @tipo_atraccion CHAR(15),
    @id_parque INT
AS
BEGIN
    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @mensaje += 'El nombre es obligatorio.' + CHAR(13);

    IF @costo IS NULL OR @costo < 0
        SET @mensaje += 'El costo debe ser mayor o igual a cero.' + CHAR(13);

    IF @duracion_minutos IS NULL OR @duracion_minutos <= 0
        SET @mensaje += 'La duracion debe ser mayor a cero.' + CHAR(13);

    IF @cupo_maximo IS NULL OR @cupo_maximo <= 0
        SET @mensaje += 'El cupo maximo debe ser mayor a cero.' + CHAR(13);

    IF @tipo_atraccion NOT IN ('Tour', 'Atraccion')
        SET @mensaje += 'El tipo de atraccion es invalido.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
          AND activo = 1
    )
        SET @mensaje += 'El parque indicado no existe o esta inactivo.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM GestionParques.Atraccion
        WHERE nombre = @nombre
          AND id_parque = @id_parque
    )
        SET @mensaje += 'Ya existe una atraccion con ese nombre en el parque.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50020, @mensaje, 1;

    INSERT INTO GestionParques.Atraccion
    (
        nombre,
        costo,
        duracion_minutos,
        cupo_maximo,
        tipo_atraccion,
        id_parque
    )
    VALUES
    (
        @nombre,
        @costo,
        @duracion_minutos,
        @cupo_maximo,
        @tipo_atraccion,
        @id_parque
    );
END;
GO

CREATE OR ALTER PROCEDURE GestionParques.Atraccion_Modificar
    @id_atraccion INT,
    @nombre VARCHAR(50),
    @costo DECIMAL,
    @duracion_minutos SMALLINT,
    @cupo_maximo SMALLINT,
    @tipo_atraccion CHAR(15),
    @id_parque INT
AS
BEGIN
    DECLARE @mensaje VARCHAR(100) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Atraccion
        WHERE id_atraccion = @id_atraccion
    )
        SET @mensaje += 'La atraccion no existe.' + CHAR(13);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @mensaje += 'El nombre es obligatorio.' + CHAR(13);

    IF @costo IS NULL OR @costo < 0
        SET @mensaje += 'El costo debe ser mayor o igual a cero.' + CHAR(13);

    IF @duracion_minutos IS NULL OR @duracion_minutos < 0
        SET @mensaje += 'La duracion debe ser mayor a cero.' + CHAR(13);

    IF @cupo_maximo IS NULL OR @cupo_maximo < 0
        SET @mensaje += 'El cupo maximo debe ser mayor a cero.' + CHAR(13);

    IF @tipo_atraccion NOT IN ('Tour', 'Atraccion')
        SET @mensaje += 'El tipo de atraccion es invalido.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
          AND activo = 1
    )
        SET @mensaje += 'El parque indicado no existe o esta inactivo.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM GestionParques.Atraccion
        WHERE nombre = @nombre
          AND id_parque = @id_parque
          AND id_atraccion <> @id_atraccion
    )
        SET @mensaje += 'Ya existe otra atraccion con ese nombre en el parque.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50021, @mensaje, 1;

    UPDATE GestionParques.Atraccion
    SET nombre = @nombre,
        costo = @costo,
        duracion_minutos = @duracion_minutos,
        cupo_maximo = @cupo_maximo,
        tipo_atraccion = @tipo_atraccion,
        id_parque = @id_parque
    WHERE id_atraccion = @id_atraccion;
END;
GO

CREATE OR ALTER PROCEDURE GestionParques.Atraccion_Baja
    @id_atraccion INT
AS
BEGIN
    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Atraccion
        WHERE id_atraccion = @id_atraccion
    )
        SET @mensaje += 'La atraccion no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Personal.Asignacion_Guia
        WHERE id_atraccion = @id_atraccion
    )
        SET @mensaje += 'No se puede eliminar porque tiene guias asignados.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50022, @mensaje, 1;

    DELETE FROM GestionParques.Atraccion
    WHERE id_atraccion = @id_atraccion;
END;
GO