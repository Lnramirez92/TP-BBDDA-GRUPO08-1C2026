/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: TESTING dataSetB
================================================================================================= */

USE ParquesNacionales;
GO
-------------------------------  TESTING ----------------------------------------
EXEC Importacion.Importar_Estadisticas_Turismo @Ruta_Archivo = 'C:\Temp\turistas-no-residentes-serie.csv';

-- Verificamos el impacto
SELECT TOP 10 * FROM GestionParques.Estadistica_Visitante;


SELECT* FROM GestionParques.Estadistica_Visitante;

SELECT * FROM Importacion.Historial_Importaciones;

TRUNCATE TABLE Importacion.Registro_Errores;

SELECT * FROM GestionParques.Estadistica_Visitante WHERE pais_origen = 'ARGENTINA'