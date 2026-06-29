/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCIÓN: Script Test para tablas del esquema GestionParques.
-- Tablas: Tipo_Parque, Parque, Atraccion
================================================================================================= */

USE ParquesNacionales;
GO

-- ================================================================================================
-- Tipo_Parque
-- ================================================================================================

--Alta exitosa
EXEC GestionParques.Tipo_Parque_Alta 'Parque Nacional';
EXEC GestionParques.Tipo_Parque_Alta 'Parque Provincial';

SELECT * FROM GestionParques.Tipo_Parque;

--Alta error duplicado
EXEC GestionParques.Tipo_Parque_Alta 'Parque Nacional';


--Modificacion exitosa
EXEC GestionParques.Tipo_Parque_Modificar
    1,
    'Reserva Natural';

SELECT *
FROM GestionParques.Tipo_Parque
WHERE id_tipo_parque = 1;

--Modificacion error inexistente
EXEC GestionParques.Tipo_Parque_Modificar
    999,
    'X';

--Baja exitosa 
EXEC GestionParques.Tipo_Parque_Alta 'Parque Nacional';

SELECT *
FROM GestionParques.Tipo_Parque;

EXEC GestionParques.Tipo_Parque_Baja 2;

SELECT *
FROM GestionParques.Tipo_Parque;


--Baja error parque asociado (ASOCIAR PARQUE AL TIPO ANTES)
EXEC GestionParques.Tipo_Parque_Baja 1;


-- ================================================================================================
-- Parque
-- ================================================================================================
--Alta exitosa
EXEC GestionParques.Parque_Alta
    'Iguazu',
    'Misiones',
    67200,
    1;

SELECT *
FROM GestionParques.Parque;

--Alta error duplicado
EXEC GestionParques.Parque_Alta
    'Iguazu',
    'Misiones',
    67200,
    1;

--Alta error tipo inexistente
EXEC GestionParques.Parque_Alta
    'Lanin',
    'Neuquen',
    412000,
    999;

--Modificacion exitosa
EXEC GestionParques.Parque_Modificar
    1,
    'Iguazu',
    'Misiones',
    70000,
    1;

SELECT *
FROM GestionParques.Parque
WHERE id_parque = 1;

--Modificacion error inexistente
EXEC GestionParques.Parque_Modificar
    999,
    'X',
    'X',
    100,
    1;

--Baja exitosa
EXEC GestionParques.Parque_Baja 1;

SELECT *
FROM GestionParques.Parque
WHERE id_parque = 1;

--Baja error inexistente
EXEC GestionParques.Parque_Baja 1;


-- ================================================================================================
-- Atraccion
-- ================================================================================================
--Alta exitosa
EXEC GestionParques.Atraccion_Alta
    'Paseo en lancha',
    5000,
    120,
    20,
    'Tour',
    1;

SELECT *
FROM GestionParques.Atraccion;

--Alta error parque inexistente
EXEC GestionParques.Atraccion_Alta
    'Paseo',
    5000,
    120,
    20,
    'Tour',
    999;

--Alta error duplicado
EXEC GestionParques.Atraccion_Alta
    'Paseo en lancha',
    5000,
    120,
    20,
    'Tour',
    1;

--Alta error tipo invalido
EXEC GestionParques.Atraccion_Alta
    'Paseo',
    5000,
    120,
    20,
    'Otro',
    1;

--Modificacion exitosa
EXEC GestionParques.Atraccion_Modificar
    1,
    'Gran Aventura',
    6000,
    150,
    30,
    'Tour',
    1;

SELECT *
FROM GestionParques.Atraccion
WHERE id_atraccion = 1;

--Modificacion error inexistente
EXEC GestionParques.Atraccion_Modificar
    999,
    'X',
    100,
    10,
    5,
    'Tour',
    1;

--Baja exitosa
EXEC GestionParques.Atraccion_Baja 2;

SELECT *
FROM GestionParques.Atraccion;

--Baja con guias asignados (ASIGNAR GUIA ANTES)
EXEC GestionParques.Atraccion_Baja 1;