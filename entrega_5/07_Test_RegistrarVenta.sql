/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCIÓN: Script de test para el registro de ventas.
================================================================================================= */

USE ParquesNacionales;
GO

--Registrar venta OK (DAR DE ALTA USUARIO, FORMA DE PAGO, TIPO ENTRADA y ATRACCION ANTES)
DECLARE @Detalles Ventas.TVP_Detalle_Venta;

INSERT INTO @Detalles
VALUES
(1, NULL, 2, 1500),
(2, NULL, 1, 1500),
(NULL, 1, 1, 3000); --tipo entrada, atraccion, cantidad, precio

EXEC Ventas.Registrar_Venta
    @fecha_ingreso = '2026-23-06',
    @fecha_compra = '2026-23-06',
    @punto_venta = 1,
    @id_forma_pago = 1,
    @id_usuario = 1,
    @id_parque = 1,
    @detalles = @Detalles;

SELECT *
FROM Ventas.Venta_Cabecera
ORDER BY id_venta DESC;

SELECT *
FROM Ventas.Detalle_Venta
ORDER BY id_detalle_venta DESC;


--sin detalle ERROR
DECLARE @Detalles Ventas.TVP_Detalle_Venta;

EXEC Ventas.Registrar_Venta
    @fecha_ingreso = GETDATE(),
    @fecha_compra = GETDATE(),
    @punto_venta = 1,
    @id_forma_pago = 1,
    @id_usuario = 1,
    @id_parque = 1,
    @detalles = @Detalles;


--cantidad invalida ERROR
DECLARE @Detalles Ventas.TVP_Detalle_Venta;

INSERT INTO @Detalles
VALUES
(1,NULL,0,1500);

EXEC Ventas.Registrar_Venta
    @fecha_ingreso = GETDATE(),
    @fecha_compra = GETDATE(),
    @punto_venta = 1,
    @id_forma_pago = 1,
    @id_usuario = 1,
    @id_parque = 1,
    @detalles = @Detalles;


--precio negativo ERROR
DECLARE @Detalles Ventas.TVP_Detalle_Venta;

INSERT INTO @Detalles
VALUES
(1,NULL,2,-100);

EXEC Ventas.Registrar_Venta
    @fecha_ingreso = GETDATE(),
    @fecha_compra = GETDATE(),
    @punto_venta = 1,
    @id_forma_pago = 1,
    @id_usuario = 1,
    @id_parque = 1,
    @detalles = @Detalles;

--entrada y atraccion al mismo tiempo ERROR
DECLARE @Detalles Ventas.TVP_Detalle_Venta;

INSERT INTO @Detalles
VALUES
(1,1,2,1500);

EXEC Ventas.Registrar_Venta
    @fecha_ingreso = GETDATE(),
    @fecha_compra = GETDATE(),
    @punto_venta = 1,
    @id_forma_pago = 1,
    @id_usuario = 1,
    @id_parque = 1,
    @detalles = @Detalles;


--sin entrada ni atraccion ERROR
DECLARE @Detalles Ventas.TVP_Detalle_Venta;

INSERT INTO @Detalles
VALUES
(NULL,NULL,2,1500);

EXEC Ventas.Registrar_Venta
    @fecha_ingreso = GETDATE(),
    @fecha_compra = GETDATE(),
    @punto_venta = 1,
    @id_forma_pago = 1,
    @id_usuario = 1,
    @id_parque = 1,
    @detalles = @Detalles;


--usuario inexistente ERROR
DECLARE @Detalles Ventas.TVP_Detalle_Venta;

INSERT INTO @Detalles
VALUES
(1,NULL,1,1500);

EXEC Ventas.Registrar_Venta
    @fecha_ingreso = GETDATE(),
    @fecha_compra = GETDATE(),
    @punto_venta = 1,
    @id_forma_pago = 1,
    @id_usuario = 999,
    @id_parque = 1,
    @detalles = @Detalles;


--parque inexistente ERROR
DECLARE @Detalles Ventas.TVP_Detalle_Venta;

INSERT INTO @Detalles
VALUES
(1,NULL,1,1500);

EXEC Ventas.Registrar_Venta
    @fecha_ingreso = GETDATE(),
    @fecha_compra = GETDATE(),
    @punto_venta = 1,
    @id_forma_pago = 1,
    @id_usuario = 1,
    @id_parque = 999,
    @detalles = @Detalles;


--forma de pago inexistente ERROR
DECLARE @Detalles Ventas.TVP_Detalle_Venta;

INSERT INTO @Detalles
VALUES
(1,NULL,1,1500);

EXEC Ventas.Registrar_Venta
    @fecha_ingreso = GETDATE(),
    @fecha_compra = GETDATE(),
    @punto_venta = 1,
    @id_forma_pago = 999,
    @id_usuario = 1,
    @id_parque = 1,
    @detalles = @Detalles;


--Registrar venta OK
DECLARE @Detalles Ventas.TVP_Detalle_Venta;

INSERT INTO @Detalles
VALUES
(1, NULL, 2, 1500),
(NULL, 1, 1, 3000);  --tipo entrada, atraccion, cantidad, precio

EXEC Ventas.Registrar_Venta
    @fecha_ingreso = GETDATE(),
    @fecha_compra = GETDATE(),
    @punto_venta = 1,
    @id_forma_pago = 1,
    @id_usuario = 1,
    @id_parque = 1,
    @detalles = @Detalles;

SELECT *
FROM Ventas.Venta_Cabecera
ORDER BY id_venta DESC;

SELECT *
FROM Ventas.Detalle_Venta
ORDER BY id_detalle_venta DESC;