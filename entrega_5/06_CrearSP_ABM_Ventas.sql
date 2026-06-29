/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCIÓN: SP de ABM de las tablas pertenecientes al esquema Ventas.
-- Tablas: Tipo_Visitante, Tipo_Entrada, Forma_Pago, Usuario, Venta_Cabecera, Detalle_Venta
================================================================================================= */

Use ParquesNacionales;
GO

/* ================================================================================================
--Tipo_Visitante
================================================================================================= */
CREATE OR ALTER PROCEDURE Ventas.Tipo_Visitante_Alta
    @descripcion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @mensaje += 'La descripción es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Visitante
        WHERE descripcion = @descripcion
          AND activo = 1
    )
        SET @mensaje += 'Ya existe un tipo de visitante activo con esa descripción.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50301, @mensaje, 1;

    INSERT INTO Ventas.Tipo_Visitante
    (
        descripcion,
        activo
    )
    VALUES
    (
        @descripcion,
        1
    );
END;
GO


CREATE OR ALTER PROCEDURE Ventas.Tipo_Visitante_Modificar
    @id_tipo_visitante INT,
    @descripcion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Visitante
        WHERE id_tipo_visitante = @id_tipo_visitante
    )
        SET @mensaje += 'El tipo de visitante no existe.' + CHAR(13);

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @mensaje += 'La descripción es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Visitante
        WHERE descripcion = @descripcion
          AND id_tipo_visitante <> @id_tipo_visitante
          AND activo = 1
    )
        SET @mensaje += 'Ya existe otro tipo de visitante activo con esa descripción.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50302, @mensaje, 1;

    UPDATE Ventas.Tipo_Visitante
    SET descripcion = @descripcion
    WHERE id_tipo_visitante = @id_tipo_visitante;
END;
GO



CREATE OR ALTER PROCEDURE Ventas.Tipo_Visitante_Baja
    @id_tipo_visitante INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Visitante
        WHERE id_tipo_visitante = @id_tipo_visitante
    )
        SET @mensaje += 'El tipo de visitante no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Entrada
        WHERE id_tipo_visitante = @id_tipo_visitante
          AND activo = 1
    )
        SET @mensaje += 'No se puede dar de baja porque existen tipos de entrada activos asociados.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50303, @mensaje, 1;

    UPDATE Ventas.Tipo_Visitante
    SET activo = 0
    WHERE id_tipo_visitante = @id_tipo_visitante;
END;
GO


/* ================================================================================================
--Tipo_Entrada
================================================================================================= */
CREATE OR ALTER PROCEDURE Ventas.Tipo_Entrada_Alta
    @id_tipo_visitante INT,
    @precio DECIMAL(10,2),
    @fecha_desde DATE,
    @fecha_hasta DATE,
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Visitante
        WHERE id_tipo_visitante = @id_tipo_visitante
          AND activo = 1
    )
        SET @mensaje += 'El tipo de visitante no existe o está inactivo.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
          AND activo = 1
    )
        SET @mensaje += 'El parque no existe o está inactivo.' + CHAR(13);

    IF @precio IS NULL OR @precio <= 0
        SET @mensaje += 'El precio debe ser mayor a cero.' + CHAR(13);

    IF @fecha_desde IS NULL OR @fecha_hasta IS NULL
        SET @mensaje += 'Las fechas son obligatorias.' + CHAR(13);

    IF @fecha_desde > @fecha_hasta
        SET @mensaje += 'La fecha desde no puede ser posterior a la fecha hasta.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Entrada
        WHERE id_tipo_visitante = @id_tipo_visitante
          AND id_parque = @id_parque
          AND fecha_desde = @fecha_desde
          AND fecha_hasta = @fecha_hasta
          AND activo = 1
    )
        SET @mensaje += 'Ya existe un tipo de entrada activo con esos datos.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50310, @mensaje, 1;

    INSERT INTO Ventas.Tipo_Entrada
    (
        id_tipo_visitante,
        precio,
        fecha_desde,
        fecha_hasta,
        id_parque,
        activo
    )
    VALUES
    (
        @id_tipo_visitante,
        @precio,
        @fecha_desde,
        @fecha_hasta,
        @id_parque,
        1
    );
END;
GO


CREATE OR ALTER PROCEDURE Ventas.Tipo_Entrada_Modificar
    @id_tipo_entrada INT,
    @id_tipo_visitante INT,
    @precio DECIMAL(10,2),
    @fecha_desde DATE,
    @fecha_hasta DATE,
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Entrada
        WHERE id_tipo_entrada = @id_tipo_entrada
    )
        SET @mensaje += 'El tipo de entrada no existe.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Visitante
        WHERE id_tipo_visitante = @id_tipo_visitante
          AND activo = 1
    )
        SET @mensaje += 'El tipo de visitante no existe o está inactivo.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
          AND activo = 1
    )
        SET @mensaje += 'El parque no existe o está inactivo.' + CHAR(13);

    IF @precio IS NULL OR @precio <= 0
        SET @mensaje += 'El precio debe ser mayor a cero.' + CHAR(13);

    IF @fecha_desde > @fecha_hasta
        SET @mensaje += 'La fecha desde no puede ser posterior a la fecha hasta.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Entrada
        WHERE id_tipo_visitante = @id_tipo_visitante
          AND id_parque = @id_parque
          AND fecha_desde = @fecha_desde
          AND fecha_hasta = @fecha_hasta
          AND activo = 1
          AND id_tipo_entrada <> @id_tipo_entrada
    )
        SET @mensaje += 'Ya existe otro tipo de entrada activo con esos datos.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50311, @mensaje, 1;

    UPDATE Ventas.Tipo_Entrada
    SET id_tipo_visitante = @id_tipo_visitante,
        precio = @precio,
        fecha_desde = @fecha_desde,
        fecha_hasta = @fecha_hasta,
        id_parque = @id_parque
    WHERE id_tipo_entrada = @id_tipo_entrada;
END;
GO


CREATE OR ALTER PROCEDURE Ventas.Tipo_Entrada_Baja
    @id_tipo_entrada INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Tipo_Entrada
        WHERE id_tipo_entrada = @id_tipo_entrada
    )
        SET @mensaje += 'El tipo de entrada no existe.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50312, @mensaje, 1;

    UPDATE Ventas.Tipo_Entrada
    SET activo = 0
    WHERE id_tipo_entrada = @id_tipo_entrada;
END;
GO

/* ================================================================================================
--Forma_Pago
================================================================================================= */
CREATE OR ALTER PROCEDURE Ventas.Forma_Pago_Alta
    @descripcion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @mensaje += 'La descripcion es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Forma_Pago
        WHERE descripcion = @descripcion
    )
        SET @mensaje += 'Ya existe una forma de pago con esa descripcion.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50320, @mensaje, 1;

    INSERT INTO Ventas.Forma_Pago (descripcion)
    VALUES (@descripcion);
END;
GO

CREATE OR ALTER PROCEDURE Ventas.Forma_Pago_Modificar
    @id_forma_pago INT,
    @descripcion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Forma_Pago
        WHERE id_forma_pago = @id_forma_pago
    )
        SET @mensaje += 'La forma de pago no existe.' + CHAR(13);

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @mensaje += 'La descripcion es obligatoria.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Forma_Pago
        WHERE descripcion = @descripcion
          AND id_forma_pago <> @id_forma_pago
    )
        SET @mensaje += 'Ya existe otra forma de pago con esa descripcion.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50321, @mensaje, 1;

    UPDATE Ventas.Forma_Pago
    SET descripcion = @descripcion
    WHERE id_forma_pago = @id_forma_pago;
END;
GO


CREATE OR ALTER PROCEDURE Ventas.Forma_Pago_Baja
    @id_forma_pago INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Forma_Pago
        WHERE id_forma_pago = @id_forma_pago
    )
        SET @mensaje += 'La forma de pago no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Venta_Cabecera
        WHERE id_forma_pago = @id_forma_pago
    )
        SET @mensaje += 'No se puede eliminar porque existen ventas asociadas.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50322, @mensaje, 1;

    DELETE FROM Ventas.Forma_Pago
    WHERE id_forma_pago = @id_forma_pago;
END;
GO



/* ================================================================================================
--Usuario
================================================================================================= */
CREATE OR ALTER PROCEDURE Ventas.Usuario_Alta
    @nombre VARCHAR(30),
    @rol VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @mensaje += 'El nombre es obligatorio.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Usuario
        WHERE nombre = @nombre
          AND activo = 1
    )
        SET @mensaje += 'Ya existe un usuario activo con ese nombre.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50330, @mensaje, 1;

    INSERT INTO Ventas.Usuario
    (
        nombre,
        rol,
        activo
    )
    VALUES
    (
        @nombre,
        @rol,
        1
    );
END;
GO


CREATE OR ALTER PROCEDURE Ventas.Usuario_Modificar
    @id_usuario INT,
    @nombre VARCHAR(30),
    @rol VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Usuario
        WHERE id_usuario = @id_usuario
    )
        SET @mensaje += 'El usuario no existe.' + CHAR(13);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @mensaje += 'El nombre es obligatorio.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Usuario
        WHERE nombre = @nombre
          AND id_usuario <> @id_usuario
          AND activo = 1
    )
        SET @mensaje += 'Ya existe otro usuario activo con ese nombre.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50331, @mensaje, 1;

    UPDATE Ventas.Usuario
    SET nombre = @nombre,
        rol = @rol
    WHERE id_usuario = @id_usuario;
END;
GO


CREATE OR ALTER PROCEDURE Ventas.Usuario_Baja
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Usuario
        WHERE id_usuario = @id_usuario
    )
        SET @mensaje += 'El usuario no existe.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50332, @mensaje, 1;

    UPDATE Ventas.Usuario
    SET activo = 0
    WHERE id_usuario = @id_usuario;
END;
GO

/* ================================================================================================
--Venta_Cabecera
================================================================================================= */
--CREATE OR ALTER PROCEDURE Ventas.Venta_Cabecera_Alta
--    @fecha_ingreso DATETIME,
--    @fecha_compra DATETIME,
--    @punto_venta INT,
--    @total DECIMAL(10,2),
--    @id_forma_pago INT,
--    @id_usuario INT,
--    @id_parque INT
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DECLARE @mensaje VARCHAR(MAX) = '';

--    IF @fecha_ingreso IS NULL
--        SET @mensaje += 'La fecha de ingreso es obligatoria.' + CHAR(13);

--    IF @fecha_compra IS NULL
--        SET @mensaje += 'La fecha de compra es obligatoria.' + CHAR(13);

--    IF @punto_venta <= 0
--        SET @mensaje += 'El punto de venta debe ser mayor a cero.' + CHAR(13);

--    IF @total < 0
--        SET @mensaje += 'El total no puede ser negativo.' + CHAR(13);

--    IF NOT EXISTS (
--        SELECT 1
--        FROM Ventas.Forma_Pago
--        WHERE id_forma_pago = @id_forma_pago
--    )
--        SET @mensaje += 'La forma de pago no existe.' + CHAR(13);

--    IF NOT EXISTS (
--        SELECT 1
--        FROM Ventas.Usuario
--        WHERE id_usuario = @id_usuario
--          AND activo = 1
--    )
--        SET @mensaje += 'El usuario no existe o está inactivo.' + CHAR(13);

--    IF NOT EXISTS (
--        SELECT 1
--        FROM GestionParques.Parque
--        WHERE id_parque = @id_parque
--          AND activo = 1
--    )
--        SET @mensaje += 'El parque no existe o está inactivo.' + CHAR(13);

--    IF @mensaje <> ''
--        THROW 50340, @mensaje, 1;

--    INSERT INTO Ventas.Venta_Cabecera
--    (
--        fecha_ingreso,
--        fecha_compra,
--        punto_venta,
--        total,
--        id_forma_pago,
--        id_usuario,
--        id_parque
--    )
--    VALUES
--    (
--        @fecha_ingreso,
--        @fecha_compra,
--        @punto_venta,
--        @total,
--        @id_forma_pago,
--        @id_usuario,
--        @id_parque
--    );
--END;
--GO


CREATE OR ALTER PROCEDURE Ventas.Venta_Cabecera_Modificar
    @id_venta INT,
    @id_forma_pago INT,
    @id_usuario INT,
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Venta_Cabecera
        WHERE id_venta = @id_venta
    )
        SET @mensaje += 'La venta no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Venta_Cabecera
        WHERE id_venta = @id_venta
          AND fecha_anulacion IS NOT NULL
    )
        SET @mensaje += 'No se puede modificar una venta anulada.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Forma_Pago
        WHERE id_forma_pago = @id_forma_pago
    )
        SET @mensaje += 'La forma de pago no existe.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Usuario
        WHERE id_usuario = @id_usuario
          AND activo = 1
    )
        SET @mensaje += 'El usuario no existe o está inactivo.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1
        FROM GestionParques.Parque
        WHERE id_parque = @id_parque
          AND activo = 1
    )
        SET @mensaje += 'El parque no existe o está inactivo.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50341, @mensaje, 1;

    UPDATE Ventas.Venta_Cabecera
    SET id_forma_pago = @id_forma_pago,
        id_usuario = @id_usuario,
        id_parque = @id_parque
    WHERE id_venta = @id_venta;
END;
GO


CREATE OR ALTER PROCEDURE Ventas.Venta_Cabecera_Baja
    @id_venta INT,
    @motivo_anulacion VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Venta_Cabecera
        WHERE id_venta = @id_venta
    )
        SET @mensaje += 'La venta no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Venta_Cabecera
        WHERE id_venta = @id_venta
          AND fecha_anulacion IS NOT NULL
    )
        SET @mensaje += 'La venta ya fue anulada.' + CHAR(13);

    IF @motivo_anulacion IS NULL
       OR LTRIM(RTRIM(@motivo_anulacion)) = ''
        SET @mensaje += 'Debe indicar el motivo de la anulacion.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50342, @mensaje, 1;

    UPDATE Ventas.Venta_Cabecera
    SET fecha_anulacion = GETDATE(),
        motivo_anulacion = @motivo_anulacion
    WHERE id_venta = @id_venta;
END;
GO



/* ================================================================================================
--Detalle_Venta
================================================================================================= */
--CREATE OR ALTER PROCEDURE Ventas.Detalle_Venta_Alta
--    @precio_final_item DECIMAL(10,2),
--    @cantidad SMALLINT,
--    @id_tipo_entrada INT = NULL,
--    @id_atraccion INT = NULL,
--    @id_venta INT
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DECLARE @mensaje VARCHAR(MAX) = '';

--    IF @precio_final_item IS NULL OR @precio_final_item < 0
--        SET @mensaje += 'El precio final debe ser mayor o igual a cero.' + CHAR(13);

--    IF @cantidad IS NULL OR @cantidad <= 0
--        SET @mensaje += 'La cantidad debe ser mayor a cero.' + CHAR(13);

--    IF NOT EXISTS (
--        SELECT 1
--        FROM Ventas.Venta_Cabecera
--        WHERE id_venta = @id_venta
--          AND fecha_anulacion IS NULL
--    )
--        SET @mensaje += 'La venta no existe o se encuentra anulada.' + CHAR(13);

--    IF @id_tipo_entrada IS NOT NULL
--       AND NOT EXISTS (
--            SELECT 1
--            FROM Ventas.Tipo_Entrada
--            WHERE id_tipo_entrada = @id_tipo_entrada
--              AND activo = 1
--       )
--        SET @mensaje += 'El tipo de entrada no existe o esta inactivo.' + CHAR(13);

--    IF @id_atraccion IS NOT NULL
--       AND NOT EXISTS (
--            SELECT 1
--            FROM GestionParques.Atraccion
--            WHERE id_atraccion = @id_atraccion
--              AND activo = 1
--       )
--        SET @mensaje += 'La atraccion no existe o esta inactiva.' + CHAR(13);

--    IF (
--        (@id_tipo_entrada IS NULL AND @id_atraccion IS NULL)
--        OR
--        (@id_tipo_entrada IS NOT NULL AND @id_atraccion IS NOT NULL)
--    )
--        SET @mensaje += 'Debe indicar una entrada o una atraccion, pero no ambas.' + CHAR(13);

--    IF @mensaje <> ''
--        THROW 50350, @mensaje, 1;

--    INSERT INTO Ventas.Detalle_Venta
--    (
--        precio_final_item,
--        cantidad,
--        id_tipo_entrada,
--        id_atraccion,
--        id_venta
--    )
--    VALUES
--    (
--        @precio_final_item,
--        @cantidad,
--        @id_tipo_entrada,
--        @id_atraccion,
--        @id_venta
--    );
--END;
--GO


CREATE OR ALTER PROCEDURE Ventas.Detalle_Venta_Modificar
    @id_detalle_venta INT,
    @precio_final_item DECIMAL(10,2),
    @cantidad SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Detalle_Venta
        WHERE id_detalle_venta = @id_detalle_venta
    )
        SET @mensaje += 'El detalle de venta no existe.' + CHAR(13);

    IF @precio_final_item IS NULL OR @precio_final_item < 0
        SET @mensaje += 'El precio final debe ser mayor o igual a cero.' + CHAR(13);

    IF @cantidad IS NULL OR @cantidad <= 0
        SET @mensaje += 'La cantidad debe ser mayor a cero.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Detalle_Venta dv
        INNER JOIN Ventas.Venta_Cabecera vc
            ON dv.id_venta = vc.id_venta
        WHERE dv.id_detalle_venta = @id_detalle_venta
          AND vc.fecha_anulacion IS NOT NULL
    )
        SET @mensaje += 'No se puede modificar un detalle perteneciente a una venta anulada.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50351, @mensaje, 1;

    UPDATE Ventas.Detalle_Venta
    SET precio_final_item = @precio_final_item,
        cantidad = @cantidad
    WHERE id_detalle_venta = @id_detalle_venta;
END;
GO


CREATE OR ALTER PROCEDURE Ventas.Detalle_Venta_Baja
    @id_detalle_venta INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje VARCHAR(MAX) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas.Detalle_Venta
        WHERE id_detalle_venta = @id_detalle_venta
    )
        SET @mensaje += 'El detalle de venta no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1
        FROM Ventas.Detalle_Venta dv
        INNER JOIN Ventas.Venta_Cabecera vc
            ON dv.id_venta = vc.id_venta
        WHERE dv.id_detalle_venta = @id_detalle_venta
          AND vc.fecha_anulacion IS NOT NULL
    )
        SET @mensaje += 'No se puede eliminar un detalle perteneciente a una venta anulada.' + CHAR(13);

    IF @mensaje <> ''
        THROW 50352, @mensaje, 1;

    DELETE FROM Ventas.Detalle_Venta
    WHERE id_detalle_venta = @id_detalle_venta;
END;
GO