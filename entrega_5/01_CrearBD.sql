/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: Script 01 - Generacion de la base de datos ParquesNacionales y esquemas.
================================================================================================= */

USE master;
GO

-- 1. Forzar cierre de conexiones activas y eliminar la Base de Datos si existe
IF DB_ID('ParquesNacionales') IS NOT NULL
BEGIN
    PRINT 'Cerrando conexiones activas y eliminando la base de datos vieja....';
    ALTER DATABASE ParquesNacionales SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ParquesNacionales;
END
GO

-- 2. Creacion de la Base de Datos
PRINT 'Creando la base de datos ParquesNacionales......';
CREATE DATABASE ParquesNacionales;
GO

USE ParquesNacionales;
GO

-- 3. Creacion de Esquemas
DROP SCHEMA IF EXISTS GestionParques;
GO
CREATE SCHEMA GestionParques;
GO

DROP SCHEMA IF EXISTS Ventas
GO
CREATE SCHEMA Ventas;
GO

DROP SCHEMA IF EXISTS Personal
GO
CREATE SCHEMA Personal;
GO

DROP SCHEMA IF EXISTS Concesiones
GO
CREATE SCHEMA Concesiones;
GO

DROP SCHEMA IF EXISTS Reportes
GO
CREATE SCHEMA Reportes;
GO

DROP SCHEMA IF EXISTS Importacion
GO
CREATE SCHEMA Importacion;
GO


PRINT 'Base de datos y esquemas creados exitosamente.';
GO