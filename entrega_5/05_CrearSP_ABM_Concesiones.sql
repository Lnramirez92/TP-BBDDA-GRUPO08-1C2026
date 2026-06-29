/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCIÓN: SP de ABM de las tablas pertenecientes al esquema Conceciones.
-- Tablas: Tipo_Actividad, Empresa_Concesionaria, Concesion, Pago_Canon
================================================================================================= */

USE ParquesNacionales;
GO

/* ================================================================================================
--Tipo_Actividad
================================================================================================= */
CREATE OR ALTER PROCEDURE Concesiones.Tipo_Actividad_Alta
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @mensaje += 'La descripción es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Concesiones.Tipo_Actividad
        WHERE descripcion = @descripcion
    )
        SET @mensaje += 'Ya existe un tipo de actividad con esa descripción.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50200, @mensaje, 1;

    INSERT INTO Concesiones.Tipo_Actividad(descripcion)
    VALUES (@descripcion);
END;
GO


CREATE OR ALTER PROCEDURE Concesiones.Tipo_Actividad_Modificar
    @id_tipo_actividad INT,
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Tipo_Actividad
        WHERE id_tipo_actividad = @id_tipo_actividad
    )
        SET @mensaje += 'El tipo de actividad no existe.' + CHAR(13);

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @mensaje += 'La descripción es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Concesiones.Tipo_Actividad
        WHERE descripcion = @descripcion
          AND id_tipo_actividad <> @id_tipo_actividad
    )
        SET @mensaje += 'Ya existe otro tipo de actividad con esa descripción.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50201, @mensaje, 1;

    UPDATE Concesiones.Tipo_Actividad
    SET descripcion = @descripcion
    WHERE id_tipo_actividad = @id_tipo_actividad;
END;
GO


CREATE OR ALTER PROCEDURE Concesiones.Tipo_Actividad_Baja
    @id_tipo_actividad INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Tipo_Actividad
        WHERE id_tipo_actividad = @id_tipo_actividad
    )
        SET @mensaje += 'El tipo de actividad no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Concesiones.Concesion
        WHERE id_tipo_actividad = @id_tipo_actividad
    )
        SET @mensaje += 'No se puede eliminar porque posee concesiones asociadas.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50202, @mensaje, 1;

    DELETE FROM Concesiones.Tipo_Actividad
    WHERE id_tipo_actividad = @id_tipo_actividad;
END;
GO

/* ================================================================================================
--Empresa_Concesionaria
================================================================================================= */
CREATE OR ALTER PROCEDURE Concesiones.Empresa_Concesionaria_Alta
    @razon_social VARCHAR(50),
    @cuit VARCHAR(15),
    @contacto VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @razon_social IS NULL OR LTRIM(RTRIM(@razon_social)) = ''
        SET @mensaje += 'La razón social es obligatoria.' + CHAR(13);

    IF @cuit IS NULL OR LTRIM(RTRIM(@cuit)) = ''
        SET @mensaje += 'El CUIT es obligatorio.' + CHAR(13);

    IF @contacto IS NULL OR LTRIM(RTRIM(@contacto)) = ''
        SET @mensaje += 'El contacto es obligatorio.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Concesiones.Empresa_Concesionaria
        WHERE cuit = @cuit
    )
        SET @mensaje += 'Ya existe una empresa con ese CUIT.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50210, @mensaje, 1;

    INSERT INTO Concesiones.Empresa_Concesionaria
    (
        razon_social,
        cuit,
        contacto
    )
    VALUES
    (
        @razon_social,
        @cuit,
        @contacto
    );
END;
GO


CREATE OR ALTER PROCEDURE Concesiones.Empresa_Concesionaria_Modificar
    @id_empresa INT,
    @razon_social VARCHAR(50),
    @cuit VARCHAR(15),
    @contacto VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Empresa_Concesionaria
        WHERE id_empresa = @id_empresa
    )
        SET @mensaje += 'La empresa no existe.' + CHAR(13);

    IF @razon_social IS NULL OR LTRIM(RTRIM(@razon_social)) = ''
        SET @mensaje += 'La razón social es obligatoria.' + CHAR(13);

    IF @cuit IS NULL OR LTRIM(RTRIM(@cuit)) = ''
        SET @mensaje += 'El CUIT es obligatorio.' + CHAR(13);

    IF @contacto IS NULL OR LTRIM(RTRIM(@contacto)) = ''
        SET @mensaje += 'El contacto es obligatorio.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Concesiones.Empresa_Concesionaria
        WHERE cuit = @cuit
          AND id_empresa <> @id_empresa
    )
        SET @mensaje += 'Ya existe otra empresa con ese CUIT.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50211, @mensaje, 1;

    UPDATE Concesiones.Empresa_Concesionaria
    SET razon_social = @razon_social,
        cuit = @cuit,
        contacto = @contacto
    WHERE id_empresa = @id_empresa;
END;
GO


CREATE OR ALTER PROCEDURE Concesiones.Empresa_Concesionaria_Baja
    @id_empresa INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Empresa_Concesionaria
        WHERE id_empresa = @id_empresa
    )
        SET @mensaje += 'La empresa no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Concesiones.Empresa_Concesionaria
        WHERE id_empresa = @id_empresa
          AND activo = 0
    )
        SET @mensaje += 'La empresa ya se encuentra inactiva.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50212, @mensaje, 1;

    UPDATE Concesiones.Empresa_Concesionaria
    SET activo = 0
    WHERE id_empresa = @id_empresa;
END;
GO

/* ================================================================================================
--Concesion
================================================================================================= */
CREATE OR ALTER PROCEDURE Concesiones.Concesion_Alta
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @monto_canon_mensual DECIMAL(10,2),
    @id_empresa INT,
    @id_tipo_actividad INT,
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @fecha_inicio IS NULL
        SET @mensaje += 'La fecha de inicio es obligatoria.' + CHAR(13);

    IF @fecha_fin IS NULL
        SET @mensaje += 'La fecha de fin es obligatoria.' + CHAR(13);

    IF @fecha_inicio IS NOT NULL
       AND @fecha_fin IS NOT NULL
       AND @fecha_fin <= @fecha_inicio
        SET @mensaje += 'La fecha de fin debe ser posterior a la fecha de inicio.' + CHAR(13);

    IF @monto_canon_mensual IS NULL
       OR @monto_canon_mensual <= 0
        SET @mensaje += 'El monto del canon mensual debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Empresa_Concesionaria
        WHERE id_empresa = @id_empresa
          AND activo = 1
    )
        SET @mensaje += 'La empresa no existe o se encuentra inactiva.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Tipo_Actividad
        WHERE id_tipo_actividad = @id_tipo_actividad
    )
        SET @mensaje += 'El tipo de actividad no existe.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
          AND activo = 1
    )
        SET @mensaje += 'El parque no existe o se encuentra inactivo.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50220, @mensaje, 1;

    INSERT INTO Concesiones.Concesion
    (
        fecha_inicio,
        fecha_fin,
        monto_canon_mensual,
        id_empresa,
        id_tipo_actividad,
        id_parque
    )
    VALUES
    (
        @fecha_inicio,
        @fecha_fin,
        @monto_canon_mensual,
        @id_empresa,
        @id_tipo_actividad,
        @id_parque
    );
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.Concesion_Modificar
    @id_concesion INT,
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @monto_canon_mensual DECIMAL(10,2),
    @id_empresa INT,
    @id_tipo_actividad INT,
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Concesion
        WHERE id_concesion = @id_concesion
    )
        SET @mensaje += 'La concesión no existe.' + CHAR(13);

    IF @fecha_inicio IS NULL
        SET @mensaje += 'La fecha de inicio es obligatoria.' + CHAR(13);

    IF @fecha_fin IS NULL
        SET @mensaje += 'La fecha de fin es obligatoria.' + CHAR(13);

    IF @fecha_inicio IS NOT NULL
       AND @fecha_fin IS NOT NULL
       AND @fecha_fin <= @fecha_inicio
        SET @mensaje += 'La fecha de fin debe ser posterior a la fecha de inicio.' + CHAR(13);

    IF @monto_canon_mensual IS NULL
       OR @monto_canon_mensual <= 0
        SET @mensaje += 'El monto del canon mensual debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Empresa_Concesionaria
        WHERE id_empresa = @id_empresa
          AND activo = 1
    )
        SET @mensaje += 'La empresa no existe o se encuentra inactiva.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Tipo_Actividad
        WHERE id_tipo_actividad = @id_tipo_actividad
    )
        SET @mensaje += 'El tipo de actividad no existe.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
          AND activo = 1
    )
        SET @mensaje += 'El parque no existe o se encuentra inactivo.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50221, @mensaje, 1;

    UPDATE Concesiones.Concesion
    SET fecha_inicio = @fecha_inicio,
        fecha_fin = @fecha_fin,
        monto_canon_mensual = @monto_canon_mensual,
        id_empresa = @id_empresa,
        id_tipo_actividad = @id_tipo_actividad,
        id_parque = @id_parque
    WHERE id_concesion = @id_concesion;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.Concesion_Baja
    @id_concesion INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Concesion
        WHERE id_concesion = @id_concesion
    )
        SET @mensaje += 'La concesión no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Concesiones.Concesion
        WHERE id_concesion = @id_concesion
          AND fecha_fin < CAST(GETDATE() AS DATE)
    )
        SET @mensaje += 'La concesión ya se encuentra finalizada.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50222, @mensaje, 1;

    UPDATE Concesiones.Concesion
    SET fecha_fin = CAST(GETDATE() AS DATE)
    WHERE id_concesion = @id_concesion;
END;
GO



/* ================================================================================================
--Pago_Canon
================================================================================================= */
CREATE OR ALTER PROCEDURE Concesiones.Pago_Canon_Alta
    @fecha_pago DATETIME,
    @monto_pagado DECIMAL(10,2),
    @mes_correspondiente TINYINT,
    @anio_correspondiente SMALLINT,
    @id_concesion INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';
    DECLARE @canon DECIMAL(10,2);

    IF @fecha_pago IS NULL
        SET @mensaje += 'La fecha de pago es obligatoria.' + CHAR(13);

    IF @monto_pagado IS NULL OR @monto_pagado <= 0
        SET @mensaje += 'El monto pagado debe ser mayor a cero.' + CHAR(13);

    IF @anio_correspondiente < 2000
        SET @mensaje += 'El año correspondiente es inválido.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Concesion
        WHERE id_concesion = @id_concesion
    )
        SET @mensaje += 'La concesión no existe.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50230, @mensaje, 1;

    SELECT @canon = monto_canon_mensual
    FROM Concesiones.Concesion
    WHERE id_concesion = @id_concesion;

    IF (
        ISNULL((
            SELECT SUM(monto_pagado)
            FROM Concesiones.Pago_Canon
            WHERE id_concesion = @id_concesion
              AND mes_correspondiente = @mes_correspondiente
              AND anio_correspondiente = @anio_correspondiente
        ), 0)
        + @monto_pagado
    ) > @canon
        SET @mensaje += 'La suma de pagos supera el canon mensual de la concesión.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50231, @mensaje, 1;

    INSERT INTO Concesiones.Pago_Canon
    (
        fecha_pago,
        monto_pagado,
        mes_correspondiente,
        anio_correspondiente,
        id_concesion
    )
    VALUES
    (
        @fecha_pago,
        @monto_pagado,
        @mes_correspondiente,
        @anio_correspondiente,
        @id_concesion
    );
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.Pago_Canon_Modificar
    @id_pago INT,
    @fecha_pago DATETIME,
    @monto_pagado DECIMAL(10,2),
    @mes_correspondiente TINYINT,
    @anio_correspondiente SMALLINT,
    @id_concesion INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';
    DECLARE @canon DECIMAL(10,2);

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Pago_Canon
        WHERE id_pago = @id_pago
    )
        SET @mensaje += 'El pago no existe.' + CHAR(13);

    IF @fecha_pago IS NULL
        SET @mensaje += 'La fecha de pago es obligatoria.' + CHAR(13);

    IF @monto_pagado IS NULL OR @monto_pagado <= 0
        SET @mensaje += 'El monto pagado debe ser mayor a cero.' + CHAR(13);

    IF @anio_correspondiente < 2000
        SET @mensaje += 'El año correspondiente es inválido.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Concesion
        WHERE id_concesion = @id_concesion
    )
        SET @mensaje += 'La concesión no existe.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50232, @mensaje, 1;

    SELECT @canon = monto_canon_mensual
    FROM Concesiones.Concesion
    WHERE id_concesion = @id_concesion;

    IF (
        ISNULL((
            SELECT SUM(monto_pagado)
            FROM Concesiones.Pago_Canon
            WHERE id_concesion = @id_concesion
              AND mes_correspondiente = @mes_correspondiente
              AND anio_correspondiente = @anio_correspondiente
              AND id_pago <> @id_pago
        ), 0)
        + @monto_pagado
    ) > @canon
        SET @mensaje += 'La suma de pagos supera el canon mensual de la concesión.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50233, @mensaje, 1;

    UPDATE Concesiones.Pago_Canon
    SET fecha_pago = @fecha_pago,
        monto_pagado = @monto_pagado,
        mes_correspondiente = @mes_correspondiente,
        anio_correspondiente = @anio_correspondiente,
        id_concesion = @id_concesion
    WHERE id_pago = @id_pago;
END;
GO


CREATE OR ALTER PROCEDURE Concesiones.Pago_Canon_Baja
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Concesiones.Pago_Canon
        WHERE id_pago = @id_pago
    )
        SET @mensaje += 'El pago no existe.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50234, @mensaje, 1;

    DELETE FROM Concesiones.Pago_Canon
    WHERE id_pago = @id_pago;
END;
GO