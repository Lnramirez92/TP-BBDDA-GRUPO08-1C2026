/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: SCRIPT DE IMPORTACION ETL (DATASET C: Alojamientos Turisticos)
-- Formato: JSON / GEOJSON. Lógica basada en conjuntos (Set-Based) sin cursores y con tabla Staging dinámica.
================================================================================================= */
USE ParquesNacionales;
GO
------------------------ TESTING  -------------------------------------------
EXEC Importacion.Importar_Alojamientos_JSON @Ruta_Archivo = 'C:\Temp\alojamientos_turisticos.json';

-- Verificamos resultados
SELECT TOP 10 * FROM GestionParques.Alojamiento_Turistico;
SELECT *FROM GestionParques.Alojamiento_Turistico;
