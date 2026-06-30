/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: creacion de tabla historial_importaciones
--
================================================================================================= */
USE ParquesNacionales;
GO

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
PRINT 'Tabla de Historial de Importaciones creada.';
GO