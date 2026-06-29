/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:Creacion de los 5 Procedimientos Almacenados.
================================================================================================= */
USE ParquesNacionales;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Reportes')
BEGIN
    EXEC('CREATE SCHEMA Reportes');
END
GO

/* ------------------------------------------------------------------------------------------------
   REPORTE 1: Visitas por semana, mes y anio, por parque.
   ------------------------------------------------------------------------------------------------ */
CREATE OR ALTER PROCEDURE Reportes.Visitas_Por_Parque
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.nombre AS Parque,
        YEAR(vc.fecha_ingreso) AS Anio,
        MONTH(vc.fecha_ingreso) AS Mes,
        DATEPART(WEEK, vc.fecha_ingreso) AS Semana,
        SUM(dv.cantidad) AS Total_Visitas
    FROM GestionParques.Parque p
    JOIN Ventas.Venta_Cabecera vc ON p.id_parque = vc.id_parque
    JOIN Ventas.Detalle_Venta dv ON vc.id_venta = dv.id_venta
    WHERE dv.id_tipo_entrada IS NOT NULL 
        AND vc.fecha_anulacion IS NULL
    GROUP BY 
        p.nombre, 
        YEAR(vc.fecha_ingreso), 
        MONTH(vc.fecha_ingreso), 
        DATEPART(WEEK, vc.fecha_ingreso)
    ORDER BY 
        Parque, Anio, Mes, Semana;
END;
GO

-- Ejecucion:
EXEC Reportes.Visitas_Por_Parque;