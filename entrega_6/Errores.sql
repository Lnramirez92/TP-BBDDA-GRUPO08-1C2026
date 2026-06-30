/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:importación de Parques Nacionales desde CSV con lógica Upsert y reporte de errores.
================================================================================================= */
USE ParquesNacionales;
GO

-- 1. Creamos el esquema de importacion si no existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Importacion')
BEGIN
    EXEC('CREATE SCHEMA Importacion');
END
GO

-- 2. TABLA DE ERRORES (Comun para todos los datasets)
IF OBJECT_ID('Importacion.Registro_Errores', 'U') IS NOT NULL DROP TABLE Importacion.Registro_Errores;
GO
CREATE TABLE Importacion.Registro_Errores (
    id_error INT IDENTITY(1,1) PRIMARY KEY,
    fecha_proceso DATETIME DEFAULT GETDATE(),
    archivo_origen VARCHAR(255),
    nro_fila INT,
    motivo_error VARCHAR(500)
);
PRINT 'Tabla de Errores creada con exito.';
GO

-- 3. TABLA DE HISTORIAL DE IMPORTACIONES 
IF OBJECT_ID('Importacion.Historial_Importaciones', 'U') IS NOT NULL DROP TABLE Importacion.Historial_Importaciones;
GO
CREATE TABLE Importacion.Historial_Importaciones (
    id_historial INT IDENTITY(1,1) PRIMARY KEY,
    archivo_procesado VARCHAR(255),
    fecha_hora DATETIME DEFAULT GETDATE(),
    total_registros_leidos INT,
    registros_insertados INT,
    registros_actualizados INT,
    registros_con_error INT
);
PRINT 'Tabla de Historial de Importaciones creada con exito.';
GO