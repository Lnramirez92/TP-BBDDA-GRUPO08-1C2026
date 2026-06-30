/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:  C:\Temp\parques_datos.csv. TESTING
================================================================================================= */
------------------------  TESTING  ---------------------------------
USE ParquesNacionales;
GO

EXEC Importacion.Importar_Parques @Ruta_Archivo = 'C:\Temp\parques_datos.csv';

SELECT * FROM Importacion.Historial_Importaciones;