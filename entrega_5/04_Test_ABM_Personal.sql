/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCIÓN: Script de test de las tablas pertenecientes al esquema Personal.
-- Tablas: Titulo, Guia, Habilitacion_Guia, GuardaParque, Asignacion_Guardaparque, Asignacion_Guia
================================================================================================= */

USE ParquesNacionales;
GO

-- ================================================================================================
-- Titulo
-- ================================================================================================

--Alta exitosa
EXEC Personal.Titulo_Alta
    'Licenciado en Turismo';

SELECT *
FROM Personal.Titulo;

--Alta error duplicado
EXEC Personal.Titulo_Alta
    'Licenciado en Turismo';

--Alta sin descripcion
EXEC Personal.Titulo_Alta
    '';

--Modificacion exitosa
EXEC Personal.Titulo_Modificar
    1,
    'Profesor de Turismo';

SELECT *
FROM Personal.Titulo
WHERE id_titulo = 1;

--Modificacion error inexistente
EXEC Personal.Titulo_Modificar
    999,
    'X';

--Modificacion error duplicado
EXEC Personal.Titulo_Modificar
    1,
    'Profesor de Turismo';

--Baja exitosa
EXEC Personal.Titulo_Alta
    'Licenciado en Turismo';

SELECT *
FROM Personal.Titulo;

EXEC Personal.Titulo_Baja
    2;

SELECT *
FROM Personal.Titulo;

--Baja error inexistente
EXEC Personal.Titulo_Baja
    999;

--Baja con guias asociados
EXEC Personal.Guia_Alta
    'Jose',
    'Dominguez',
    '1990-10-20',
    '34111222',
    'Arboles',
    1;

SELECT * FROM
Personal.Guia

EXEC Personal.Titulo_Baja
    1;

-- ================================================================================================
-- Guia
-- ================================================================================================
--Alta exitosa
EXEC Personal.Guia_Alta
    @nombre = 'Juan',
    @apellido = 'Perez',
    @fecha_nacimiento = '1990-05-10',
    @dni = '30111222',
    @especialidad = 'Avistaje de aves',
    @id_titulo = 1;

SELECT *
FROM Personal.Guia;

--Alta error titulo inexistente
EXEC Personal.Guia_Alta
    'Juan',
    'Perez',
    '1990-05-10',
    '30111223',
    'Avistaje',
    999;

--Alta con DNI duplicado
EXEC Personal.Guia_Alta
    'Pedro',
    'Lopez',
    '1985-03-15',
    '30111222',
    'Fauna',
    NULL;

--Alta sin nombre
EXEC Personal.Guia_Alta
    '',
    'Perez',
    '1990-05-10',
    '30111224',
    'Avistaje',
    NULL;

--Modificacion exitosa
EXEC Personal.Guia_Modificar
    @id_guia = 1,
    @nombre = 'Juan Carlos',
    @apellido = 'Perez',
    @fecha_nacimiento = '1990-05-10',
    @dni = '30333333',
    @especialidad = 'Fauna autóctona',
    @id_titulo = 1;

SELECT *
FROM Personal.Guia
WHERE id_guia = 1;

--Modificacion error inexistente
EXEC Personal.Guia_Modificar
    999,
    'Juan',
    'Perez',
    '1990-05-10',
    '30111222',
    'Fauna',
    NULL;

--Modificacion error DNI duplicado
EXEC Personal.Guia_Alta
    'Maria',
    'Gomez',
    '1992-01-10',
    '33444444',
    'Montañismo',
    NULL;

EXEC Personal.Guia_Modificar
    1,
    'Juan',
    'Perez',
    '1990-05-10',
    '33444444',
    'Fauna',
    NULL;

--Baja exitosa
EXEC Personal.Guia_Baja 1;

SELECT *
FROM Personal.Guia
WHERE id_guia = 1;

--Baja error guia inexistente
EXEC Personal.Guia_Baja 999;

--Baja de guia con asignacion activa
EXEC Personal.Asignacion_Guia_Alta
    1,
    2,
    '2026-01-01'

EXEC Personal.Guia_Baja 2;


-- ================================================================================================
-- Guardaparque
-- ================================================================================================
--Alta exitosa
EXEC Personal.Guardaparque_Alta
    @nombre = 'Carlos',
    @apellido = 'Lopez',
    @dni = '28444555',
    @fecha_nacimiento = '1980-05-15';

SELECT *
FROM Personal.Guardaparque;

--Alta error DNI duplicado
EXEC Personal.Guardaparque_Alta
    @nombre = 'Pedro',
    @apellido = 'Gomez',
    @dni = '28444555',
    @fecha_nacimiento = '1985-10-20';

--Alta error sin nombre
EXEC Personal.Guardaparque_Alta
    @nombre = '',
    @apellido = 'Lopez',
    @dni = '30111222',
    @fecha_nacimiento = '1980-05-15';

--Modificacion exitosa
EXEC Personal.Guardaparque_Modificar
    @id_guardaparque = 1,
    @nombre = 'Carlos Alberto',
    @apellido = 'Lopez',
    @dni = '28444555',
    @fecha_nacimiento = '1980-05-15';

SELECT *
FROM Personal.Guardaparque
WHERE id_guardaparque = 1;

--Modificacion error inexistente
EXEC Personal.Guardaparque_Modificar
    999,
    'Carlos',
    'Lopez',
    '28444555',
    '1980-05-15';

--Modificacion error DNI duplicado
EXEC Personal.Guardaparque_Alta
    'Juan',
    'Perez',
    '30111222',
    '1982-01-01';

EXEC Personal.Guardaparque_Modificar
    1,
    'Carlos',
    'Lopez',
    '30111222',
    '1980-05-15';

--Baja exitosa
EXEC Personal.Guardaparque_Baja 1;

SELECT *
FROM Personal.Guardaparque
WHERE id_guardaparque = 1;

--Baja error inexistente
EXEC Personal.Guardaparque_Baja 999;

--Baja error con asignacion activa
EXEC Personal.Asignacion_Guardaparque_Alta
    '2026-01-01',
    2,
    1;

EXEC Personal.Guardaparque_Baja 2;


-- ================================================================================================
-- Habilitacion_Guia
-- ================================================================================================
--Alta exitosa
EXEC Personal.Habilitacion_Guia_Alta
    'MAT-001',
    '2026-01-10',
    'Activa',
    1;

SELECT *
FROM Personal.Habilitacion_Guia;

--Alta con guia inexistente
EXEC Personal.Habilitacion_Guia_Alta
    'MAT-002',
    '2026-01-10',
    'Activa',
    999;

--Alta con matricula duplicada
EXEC Personal.Habilitacion_Guia_Alta
    'MAT-001',
    '2026-01-10',
    'Activa',
    2;

--Alta con habilitacion activa
EXEC Personal.Habilitacion_Guia_Alta
    'MAT-003',
    '2026-01-10',
    'Activa',
    1;

--Modificacion exitosa
EXEC Personal.Habilitacion_Guia_Modificar
    1,
    'MAT-001A',
    '2026-01-10',
    'Activa',
    1;

SELECT *
FROM Personal.Habilitacion_Guia
WHERE id_habilitacion = 1;

--Modificacion inexistente
EXEC Personal.Habilitacion_Guia_Modificar
    999,
    'MAT-999',
    '2026-06-23',
    'Activa',
    1;

--Baja exitosa
EXEC Personal.Habilitacion_Guia_Baja 1;

SELECT *
FROM Personal.Habilitacion_Guia
WHERE id_habilitacion = 1;

--Baja duplicada
EXEC Personal.Habilitacion_Guia_Baja 1;


-- ================================================================================================
-- Asignacion_Guia
-- ================================================================================================
--Alta exitosa
EXEC Personal.Asignacion_Guia_Alta
    @id_atraccion = 1,
    @id_guia = 1,
    @fecha_inicio = '2026-01-10';

SELECT *
FROM Personal.Asignacion_Guia;

--Alta error guia inexistente
EXEC Personal.Asignacion_Guia_Alta
    1,
    999,
    '2026-01-10';

--Alta error guia sin habilitacion activa
EXEC Personal.Asignacion_Guia_Alta
    1,
    2,
    '2026-01-10';

--Alta error atraccion inexistente
EXEC Personal.Asignacion_Guia_Alta
    999,
    1,
    '2026-01-10';

--Alta error duplicado
EXEC Personal.Asignacion_Guia_Alta
    1,
    1,
    '2026-02-01';

--Modificacion exitosa
EXEC Personal.Asignacion_Guia_Modificar
    1,
    2,
    '2026-01-10',
    NULL;

SELECT *
FROM Personal.Asignacion_Guia
WHERE id_asignacion = 1;

--Modificacion error fechas invalidas
EXEC Personal.Asignacion_Guia_Modificar
    1,
    1,
    '2026-06-01',
    '2026-05-01';


--Baja exitosa
EXEC Personal.Asignacion_Guia_Baja
    1,
    '2026-12-31';

SELECT *
FROM Personal.Asignacion_Guia
WHERE id_asignacion = 1;

--Baja error duplicado
EXEC Personal.Asignacion_Guia_Baja
    1,
    '2027-01-01';

--Baja error fecha invalida
EXEC Personal.Asignacion_Guia_Baja
    1,
    '2025-12-31';


-- ================================================================================================
-- Asignacion_Guardaparque
-- ================================================================================================
--Alta exitosa
EXEC Personal.Asignacion_Guardaparque_Alta
    '2026-01-01',
    1,
    1;

SELECT *
FROM Personal.Asignacion_Guardaparque;

--Alta error guardaparque inexistente
EXEC Personal.Asignacion_Guardaparque_Alta
    '2026-01-01',
    999,
    1;

--Alta error con asignacion activa
EXEC Personal.Asignacion_Guardaparque_Alta
    '2026-02-01',
    1,
    2;

--Modificacion exitosa
EXEC Personal.Asignacion_Guardaparque_Modificar
    1,
    '2026-01-01',
    NULL,
    NULL,
    2;

SELECT *
FROM Personal.Asignacion_Guardaparque
WHERE id_asignacion = 1;

--Modificacion error fechas invalidas
EXEC Personal.Asignacion_Guardaparque_Modificar
    1,
    '2026-05-01',
    '2026-04-01',
    'Error',
    1;

--Baja exitosa
EXEC Personal.Asignacion_Guardaparque_Baja
    1,
    '2026-06-30',
    'Reasignación';

SELECT *
FROM Personal.Asignacion_Guardaparque
WHERE id_asignacion = 1;

--Baja error duplicado
EXEC Personal.Asignacion_Guardaparque_Baja
    1,
    '2026-07-01',
    'Otro motivo';

--Baja con fecha invalida
EXEC Personal.Asignacion_Guardaparque_Baja
    1,
    '2025-12-31',
    'Prueba';