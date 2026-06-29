/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCIÓN: Script de Test de ABM de las tablas pertenecientes al esquema Conceciones.
-- Tablas: 
================================================================================================= */

USE ParquesNacionales;
GO

/* ================================================================================================
--Tipo_Actividad
================================================================================================= */
--Alta exitosa
EXEC Concesiones.Tipo_Actividad_Alta --eliminar 
    'Restaurante';

SELECT *
FROM Concesiones.Tipo_Actividad;

--Alta duplicada
EXEC Concesiones.Tipo_Actividad_Alta
    'Restaurante';

--Alta sin descripcion
EXEC Concesiones.Tipo_Actividad_Alta
    '';

--Modificacion exitosa
EXEC Concesiones.Tipo_Actividad_Modificar
    1,
    'Tienda';

SELECT *
FROM Concesiones.Tipo_Actividad
WHERE id_tipo_actividad = 1;

--Modificacion error inexistente
EXEC Concesiones.Tipo_Actividad_Modificar
    999,
    'Camping';

--Modificacion error duplicado
EXEC Concesiones.Tipo_Actividad_Alta
    'Kiosco';

EXEC Concesiones.Tipo_Actividad_Modificar
    1,
    'Kiosco';

--Baja exitosa
EXEC Concesiones.Tipo_Actividad_Alta
    'Temporal';

EXEC Concesiones.Tipo_Actividad_Baja
    3;

SELECT *
FROM Concesiones.Tipo_Actividad;

--Baja con concesiones asociadas
EXEC Concesiones.Tipo_Actividad_Baja
    1;

/* ================================================================================================
--Empresa_Concesionaria
================================================================================================= */
--Alta exitosa
EXEC Concesiones.Empresa_Concesionaria_Alta
    'Aventura Patagonia S.A.',
    '30-12345678-9',
    'info@aventurapatagonia.com';

SELECT *
FROM Concesiones.Empresa_Concesionaria;

--Alta con CUIT duplicado
EXEC Concesiones.Empresa_Concesionaria_Alta
    'Otra Empresa',
    '30-12345678-9',
    'contacto@empresa.com';

--Alta sin razon social
EXEC Concesiones.Empresa_Concesionaria_Alta
    '',
    '30-11111111-1',
    'contacto@empresa.com';

--Modificacion exitosa
EXEC Concesiones.Empresa_Concesionaria_Modificar
    1,
    'Aventura Patagonia SRL',
    '30-12345678-9',
    'administracion@aventurapatagonia.com';

SELECT *
FROM Concesiones.Empresa_Concesionaria
WHERE id_empresa = 1;

--Modificacion inexistente
EXEC Concesiones.Empresa_Concesionaria_Modificar
    999,
    'Empresa Fantasma',
    '30-99999999-9',
    'contacto@test.com';

--Modificacion con cuit duplicado
EXEC Concesiones.Empresa_Concesionaria_Alta
    'Turismo Sur',
    '30-22222222-2',
    'contacto@turismosur.com';

EXEC Concesiones.Empresa_Concesionaria_Modificar
    2,
    'Turismo Sur',
    '30-12345678-9',
    'nuevo@turismosur.com';

--Baja exitosa
EXEC Concesiones.Empresa_Concesionaria_Baja
    1;

SELECT *
FROM Concesiones.Empresa_Concesionaria
WHERE id_empresa = 1;

--Baja empresa inexistente
EXEC Concesiones.Empresa_Concesionaria_Baja
    999;

--Baja empresa ya inactiva
EXEC Concesiones.Empresa_Concesionaria_Baja
    1;



/* ================================================================================================
--Concesion
================================================================================================= */
--Alta exitosa
EXEC Concesiones.Concesion_Alta
    '2026-01-01',
    '2026-12-31',
    150000,
    1,
    1,
    1;

SELECT *
FROM Concesiones.Concesion;

--Alta empresa inactiva
EXEC Concesiones.Empresa_Concesionaria_Baja 1;

EXEC Concesiones.Concesion_Alta
    '2026-01-01',
    '2026-12-31',
    150000,
    1,
    1,
    1;

--Alta fecha invalida
EXEC Concesiones.Concesion_Alta
    '2026-12-31',
    '2026-01-01',
    150000,
    1,
    1,
    1;

--Alta canon invalido
EXEC Concesiones.Concesion_Alta
    '2026-01-01',
    '2026-12-31',
    0,
    1,
    1,
    1;

--Modificacion exitosa
EXEC Concesiones.Concesion_Modificar
    1,
    '2026-01-01',
    '2027-12-31',
    180000,
    1,
    1,
    1;

--Baja exitosa
EXEC Concesiones.Concesion_Baja 1;

SELECT *
FROM Concesiones.Concesion
WHERE id_concesion = 1;



/* ================================================================================================
--Pago_Canon
================================================================================================= */
--Alta exitosa
EXEC Concesiones.Pago_Canon_Alta
    GETDATE(),
    40000,
    6,
    2026,
    1;

EXEC Concesiones.Pago_Canon_Alta
    GETDATE(),
    60000,
    6,
    2026,
    1;

SELECT *
FROM Concesiones.Pago_Canon;

--Alta superando el canon
EXEC Concesiones.Pago_Canon_Alta
    GETDATE(),
    1000,
    6,
    2026,
    1;

--Concesion inexistente
EXEC Concesiones.Pago_Canon_Alta
    GETDATE(),
    5000,
    6,
    2026,
    999;

--Modificacion exitosa
EXEC Concesiones.Pago_Canon_Modificar
    1,
    GETDATE(),
    30000,
    6,
    2026,
    1;

--Modificacion error superando el canon
EXEC Concesiones.Pago_Canon_Modificar
    1,
    GETDATE(),
    90000,
    6,
    2026,
    1;

--Baja exitosa
EXEC Concesiones.Pago_Canon_Baja 1;

SELECT *
FROM Concesiones.Pago_Canon;

--Baja inexistente
EXEC Concesiones.Pago_Canon_Baja 999;