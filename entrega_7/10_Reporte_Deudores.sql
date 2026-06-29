/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:REPORTE 3 (XML): Deudores: Concesiones atrasadas detallando meses y montos.
================================================================================================= */

USE ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Reportes.Deudores_XML
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.razon_social AS '@Titular',
        ta.descripcion AS '@Servicio',
        p.nombre AS '@Parque',

        (
            SELECT
                pc.mes_correspondiente AS '@Mes',
                pc.anio_correspondiente AS '@Anio',

                (c.monto_canon_mensual - SUM(pc.monto_pagado)) AS '@Monto_Adeudado'

            FROM Concesiones.Pago_Canon pc
            WHERE pc.id_concesion = c.id_concesion
            GROUP BY pc.mes_correspondiente, pc.anio_correspondiente
            HAVING SUM(pc.monto_pagado) < c.monto_canon_mensual

            FOR XML PATH('Deuda_Mensual'), TYPE
        )

    FROM Concesiones.Concesion c
        INNER JOIN Concesiones.Empresa_Concesionaria e
            ON e.id_empresa = c.id_empresa
        INNER JOIN Concesiones.Tipo_Actividad ta
            ON ta.id_tipo_actividad = c.id_tipo_actividad
        INNER JOIN GestionParques.Parque p
            ON p.id_parque = c.id_parque

    WHERE EXISTS (
        SELECT 1
        FROM Concesiones.Pago_Canon pc
        WHERE pc.id_concesion = c.id_concesion
        GROUP BY pc.mes_correspondiente, pc.anio_correspondiente
        HAVING SUM(pc.monto_pagado) < c.monto_canon_mensual
    )

    FOR XML PATH('Concesionario_Deudor'), ROOT('Reporte_Deudores');
END;
GO

EXEC Reportes.Deudores_XML;