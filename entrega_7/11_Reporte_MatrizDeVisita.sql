/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:Matriz de visitas (Pivot) mostrando visitas por mes y parque.
================================================================================================= */
USE ParquesNacionales;
GO


CREATE OR ALTER PROCEDURE Reportes.Matriz_Visitas_Pivot
    @AnioConsulta INT = 2026
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Forzamos el idioma a español para que el nombre de los meses del PIVOT coincida
    SET LANGUAGE Spanish;

    SELECT * FROM (
        SELECT 
            p.nombre AS Parque,
            DATENAME(MONTH, vc.fecha_ingreso) AS NombreMes,
            dv.cantidad AS Visitas
        FROM Ventas.Venta_Cabecera vc
        JOIN Ventas.Detalle_Venta dv ON vc.id_venta = dv.id_venta
        JOIN GestionParques.Parque p ON vc.id_parque = p.id_parque
        WHERE YEAR(vc.fecha_ingreso) = @AnioConsulta
          AND dv.id_tipo_entrada IS NOT NULL
    ) AS DatosBase
    PIVOT (
        -- Sumamos las visitas y las repartimos en 12 columnas
        SUM(Visitas)
        FOR NombreMes IN (
            [Enero], [Febrero], [Marzo], [Abril], [Mayo], [Junio], 
            [Julio], [Agosto], [Septiembre], [Octubre], [Noviembre], [Diciembre]
        )
    ) AS MatrizPivotada;
END;
GO
-- Ejecucion Reporte (PIVOT):
EXEC Reportes.Matriz_Visitas_Pivot @AnioConsulta = 2026;