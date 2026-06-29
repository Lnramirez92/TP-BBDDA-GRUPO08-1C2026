/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCIÓN: SP del proceso de registro de ventas.
-- Tablas: Venta_Cabecera, Detalle_Venta
================================================================================================= */

USE ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Ventas.Registrar_Venta
(
    @fecha_ingreso DATETIME,
    @fecha_compra DATETIME,
    @punto_venta INT,
    @id_forma_pago INT,
    @id_usuario INT,
    @id_parque INT,
    @detalles Ventas.TVP_Detalle_Venta READONLY
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @mensaje VARCHAR(MAX) = '';
        DECLARE @id_venta INT;

        --------------------------------------------------------------------
        -- 1 Validaciones de venta
        --------------------------------------------------------------------
        IF @fecha_ingreso IS NULL
            SET @mensaje += 'La fecha de ingreso es obligatoria.' + CHAR(13);

        IF @fecha_compra IS NULL
            SET @mensaje += 'La fecha de compra es obligatoria.' + CHAR(13);

        IF @punto_venta IS NULL OR @punto_venta <= 0
            SET @mensaje += 'El punto de venta debe ser mayor a cero.' + CHAR(13);

        IF NOT EXISTS (SELECT 1 FROM Ventas.Forma_Pago WHERE id_forma_pago = @id_forma_pago)
            SET @mensaje += 'Forma de pago inexistente.' + CHAR(13);

        IF NOT EXISTS (SELECT 1 FROM Ventas.Usuario WHERE id_usuario = @id_usuario AND activo = 1)
            SET @mensaje += 'Usuario inexistente o inactivo.' + CHAR(13);

        IF NOT EXISTS (SELECT 1 FROM GestionParques.Parque WHERE id_parque = @id_parque AND activo = 1)
            SET @mensaje += 'Parque inexistente o inactivo.' + CHAR(13);

        --------------------------------------------------------------------
        -- 2 Validaciones del tvp
        --------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM @detalles)
            SET @mensaje += 'La venta debe tener al menos un detalle.' + CHAR(13);

        IF EXISTS (
            SELECT 1
            FROM @detalles
            WHERE cantidad IS NULL OR cantidad <= 0
        )
            SET @mensaje += 'Hay cantidades inválidas en los detalles.' + CHAR(13);

        IF EXISTS (
            SELECT 1
            FROM @detalles
            WHERE precio_final_item IS NULL OR precio_final_item < 0
        )
            SET @mensaje += 'Hay precios inválidos en los detalles.' + CHAR(13);

        IF EXISTS (
            SELECT 1
            FROM @detalles
            WHERE (id_tipo_entrada IS NULL AND id_atraccion IS NULL)
               OR (id_tipo_entrada IS NOT NULL AND id_atraccion IS NOT NULL)
        )
            SET @mensaje += 'Cada detalle debe tener entrada o atracción, no ambas.' + CHAR(13);

        IF @mensaje <> ''
            THROW 50300, @mensaje, 1;

        --------------------------------------------------------------------
        -- 3 Inserto cabecera
        --------------------------------------------------------------------
        INSERT INTO Ventas.Venta_Cabecera
        (
            fecha_ingreso,
            fecha_compra,
            punto_venta,
            total,
            id_forma_pago,
            id_usuario,
            id_parque
        )
        VALUES
        (
            @fecha_ingreso,
            @fecha_compra,
            @punto_venta,
            0,
            @id_forma_pago,
            @id_usuario,
            @id_parque
        );

        SET @id_venta = SCOPE_IDENTITY();

        --------------------------------------------------------------------
        -- 4 inserto los detalles
        --------------------------------------------------------------------
        INSERT INTO Ventas.Detalle_Venta
        (
            precio_final_item,
            cantidad,
            id_tipo_entrada,
            id_atraccion,
            id_venta
        )
        SELECT
            d.precio_final_item,
            d.cantidad,
            d.id_tipo_entrada,
            d.id_atraccion,
            @id_venta
        FROM @detalles d;

        --------------------------------------------------------------------
        -- 5 calculo el total
        --------------------------------------------------------------------
        UPDATE Ventas.Venta_Cabecera
        SET total =
        (
            SELECT SUM(precio_final_item * cantidad)
            FROM Ventas.Detalle_Venta
            WHERE id_venta = @id_venta
        )
        WHERE id_venta = @id_venta;

        COMMIT;

        --------------------------------------------------------------------
        -- 6 retorno id
        --------------------------------------------------------------------
        SELECT @id_venta AS id_venta;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH
END;
GO