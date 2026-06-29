/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:Ingresos por parque por semana, mes y anio (Sumando Entradas, Tours y Concesiones).
================================================================================================= */
CREATE OR ALTER PROCEDURE Reportes.Ingresos_Totales
AS
BEGIN
    SET NOCOUNT ON;

    WITH Ingresos_Unificados AS (
        -- entradas
        SELECT 
            vc.id_parque, vc.fecha_compra AS Fecha, (dv.precio_final_item * dv.cantidad) AS Monto, 'Entradas' AS Concepto 
        FROM Ventas.Venta_Cabecera vc
        JOIN Ventas.Detalle_Venta dv ON vc.id_venta = dv.id_venta
        WHERE dv.id_tipo_entrada IS NOT NULL 
            AND vc.fecha_anulacion IS NULL

        UNION ALL
        
        -- actividad
        SELECT 
            vc.id_parque, vc.fecha_compra AS Fecha, (dv.precio_final_item * dv.cantidad) AS Monto, 'Tours' AS Concepto 
        FROM Ventas.Venta_Cabecera vc
        JOIN Ventas.Detalle_Venta dv ON vc.id_venta = dv.id_venta
        WHERE dv.id_atraccion IS NOT NULL
            AND vc.fecha_anulacion IS NULL

        UNION ALL
        
        -- concesiones
        SELECT 
            c.id_parque, pc.fecha_pago AS Fecha, pc.monto_pagado AS Monto, 'Concesiones' AS Concepto 
        FROM Concesiones.Pago_Canon pc
        JOIN Concesiones.Concesion c ON pc.id_concesion = c.id_concesion
    )
    
    SELECT 
        p.nombre AS Parque,
        YEAR(i.Fecha) AS Anio,
        MONTH(i.Fecha) AS Mes,
        DATEPART(WEEK, i.Fecha) AS Semana,
        SUM(CASE WHEN i.Concepto = 'Entradas' THEN i.Monto ELSE 0 END) AS Ingresos_Entradas,
        SUM(CASE WHEN i.Concepto = 'Tours' THEN i.Monto ELSE 0 END) AS Ingresos_Tours,
        SUM(CASE WHEN i.Concepto = 'Concesiones' THEN i.Monto ELSE 0 END) AS Ingresos_Concesiones,
        SUM(i.Monto) AS Ingreso_Total_General
    FROM Ingresos_Unificados i
    JOIN GestionParques.Parque p ON i.id_parque = p.id_parque
    GROUP BY 
        p.nombre, YEAR(i.Fecha), MONTH(i.Fecha), DATEPART(WEEK, i.Fecha)
    ORDER BY 
        Parque, Anio, Mes, Semana;
END;
GO

-- Ejecucion:
EXEC Reportes.Ingresos_Totales;