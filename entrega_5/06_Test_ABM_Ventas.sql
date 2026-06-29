/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCIÓN: Script de Test de ABM de las tablas pertenecientes al esquema Ventas.
-- Tablas: 
================================================================================================= */

USE ParquesNacionales;
GO

/* ================================================================================================
--Tipo_Visitante
================================================================================================= */
--Alta exitosa
EXEC Ventas.Tipo_Visitante_Alta 'Residente';
EXEC Ventas.Tipo_Visitante_Alta 'Jubilado';

SELECT *
FROM Ventas.Tipo_Visitante;

--Alta error duplicado
EXEC Ventas.Tipo_Visitante_Alta 'Residente';

--Modificacion exitosa
EXEC Ventas.Tipo_Visitante_Modificar
    1,
    'Extranjero';

SELECT *
FROM Ventas.Tipo_Visitante
WHERE id_tipo_visitante = 1;

--Modificacion error inexistente
EXEC Ventas.Tipo_Visitante_Modificar
    999,
    'Jubilado';

--Baja exitosa
EXEC Ventas.Tipo_Visitante_Baja 1;

SELECT *
FROM Ventas.Tipo_Visitante
WHERE id_tipo_visitante = 1;


--Baja con entradas asociadas
EXEC Ventas.Tipo_Entrada_Alta
    5,
    20000,
    '2026-01-01',
    '2026-12-31',
    1;
EXEC Ventas.Tipo_Visitante_Baja 2;

/* ================================================================================================
--Tipo_Entrada
================================================================================================= */
--Alta exitosa
EXEC Ventas.Tipo_Entrada_Alta
    1,
    15000,
    '2026-01-01',
    '2026-12-31',
    1;

EXEC Ventas.Tipo_Entrada_Alta
    2,
    10000,
    '2026-01-01',
    '2026-12-31',
    1;

SELECT *
FROM Ventas.Tipo_Entrada;

--Alta error tipo visitante inexistente
EXEC Ventas.Tipo_Entrada_Alta
    999,
    15000,
    '2026-01-01',
    '2026-12-31',
    1;

--Alta error parque inexistente
EXEC Ventas.Tipo_Entrada_Alta
    1,
    15000,
    '2026-01-01',
    '2026-12-31',
    999;

--Alta error precio invalido
EXEC Ventas.Tipo_Entrada_Alta
    1,
    -100,
    '2026-01-01',
    '2026-12-31',
    1;

--Alta error fechas invalidas
EXEC Ventas.Tipo_Entrada_Alta
    1,
    15000,
    '2026-12-31',
    '2026-01-01',
    1;

--Alta error duplicado
EXEC Ventas.Tipo_Entrada_Alta
    1,
    15000,
    '2026-01-01',
    '2026-12-31',
    1;

--Modificacion exitosa
EXEC Ventas.Tipo_Entrada_Modificar
    1,
    1,
    18000,
    '2026-01-01',
    '2026-12-31',
    1;

SELECT *
FROM Ventas.Tipo_Entrada
WHERE id_tipo_entrada = 1;

--Baja exitosa
EXEC Ventas.Tipo_Entrada_Baja 1;

SELECT *
FROM Ventas.Tipo_Entrada
WHERE id_tipo_entrada = 1;


/* ================================================================================================
--Forma_Pago
================================================================================================= */
--Alta exitosa
EXEC Ventas.Forma_Pago_Alta 'Efectivo';

SELECT *
FROM Ventas.Forma_Pago;

--Alta duplicada
EXEC Ventas.Forma_Pago_Alta 'Efectivo';

--Modificacion exitosa
EXEC Ventas.Forma_Pago_Modificar
    1,
    'Tarjeta';

SELECT *
FROM Ventas.Forma_Pago
WHERE id_forma_pago = 1;

--Modificacion inexistente
EXEC Ventas.Forma_Pago_Modificar
    999,
    'Transferencia';

--Baja exitosa
EXEC Ventas.Forma_Pago_Baja 1;

SELECT *
FROM Ventas.Forma_Pago;

--Baja con venta asociada
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
    GETDATE(),
    GETDATE(),
    1,
    10000,
    2,
    1,
    1
);

EXEC Ventas.Forma_Pago_Baja 2;


/* ================================================================================================
--Usuario
================================================================================================= */
--Alta exitosa
EXEC Ventas.Usuario_Alta
    @nombre = 'nramirez',
    @rol = 'Cajero';

SELECT *
FROM Ventas.Usuario;

--Alta sin rol
EXEC Ventas.Usuario_Alta
    @nombre = 'admin';

--Alta duplicado
EXEC Ventas.Usuario_Alta
    @nombre = 'admin';

--Modificacion exitosa
EXEC Ventas.Usuario_Modificar
    @id_usuario = 1,
    @nombre = 'nicolas',
    @rol = 'Supervisor';

SELECT *
FROM Ventas.Usuario
WHERE id_usuario = 1;

--Modificacion error inexistente
EXEC Ventas.Usuario_Modificar
    @id_usuario = 999,
    @nombre = 'test',
    @rol = 'Admin';

--Baja exitosa
EXEC Ventas.Usuario_Baja 1;

SELECT *
FROM Ventas.Usuario
WHERE id_usuario = 1;

--Baja error inexistente
EXEC Ventas.Usuario_Baja 999;

/* ================================================================================================
--Venta_Cabecera
================================================================================================= */
--Alta exitosa
--EXEC Ventas.Venta_Cabecera_Alta
--    GETDATE(),
--    GETDATE(),
--    1,
--    15000,
--    1,
--    1,
--    1;

--SELECT *
--FROM Ventas.Venta_Cabecera;

----Alta usuario inexistente
--EXEC Ventas.Venta_Cabecera_Alta
--    GETDATE(),
--    GETDATE(),
--    1,
--    15000,
--    1,
--    999,
--    1;

--Modificacion exitosa
EXEC Ventas.Venta_Cabecera_Modificar
    1,
    1,
    1,
    1;

--Baja exitosa
EXEC Ventas.Venta_Cabecera_Baja
    1,
    'Venta registrada por error';

SELECT *
FROM Ventas.Venta_Cabecera
WHERE id_venta = 1;

--Baja error duplicada
EXEC Ventas.Venta_Cabecera_Baja
    1,
    'Segundo intento';



/* ================================================================================================
--Detalle_Venta
================================================================================================= */
--Alta exitosa (entrada)
--EXEC Ventas.Detalle_Venta_Alta
--    @precio_final_item = 5000,
--    @cantidad = 2,
--    @id_tipo_entrada = 1,
--    @id_atraccion = NULL,
--    @id_venta = 1;

--SELECT *
--FROM Ventas.Detalle_Venta;

----Altaexitosa (atraccion)
--EXEC Ventas.Detalle_Venta_Alta
--    @precio_final_item = 2500,
--    @cantidad = 1,
--    @id_tipo_entrada = NULL,
--    @id_atraccion = 1,
--    @id_venta = 1;

----Alta error ambos tipos informados
--EXEC Ventas.Detalle_Venta_Alta
--    @precio_final_item = 1000,
--    @cantidad = 1,
--    @id_tipo_entrada = 1,
--    @id_atraccion = 1,
--    @id_venta = 1;

----Alta ningun tipo informado
--EXEC Ventas.Detalle_Venta_Alta
--    @precio_final_item = 1000,
--    @cantidad = 1,
--    @id_venta = 1;

--Modificacion exitosa
EXEC Ventas.Detalle_Venta_Modificar
    1,
    5500,
    3;

SELECT *
FROM Ventas.Detalle_Venta
WHERE id_detalle_venta = 1;

--Baja exitosa
EXEC Ventas.Detalle_Venta_Baja 1;

SELECT *
FROM Ventas.Detalle_Venta;