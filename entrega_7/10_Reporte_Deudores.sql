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

USE ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Reportes.Deudores_XML
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Meses AS
    (
        -- Primer mes
        SELECT
            c.id_concesion,
            c.id_empresa,
            c.id_tipo_actividad,
            c.id_parque,
            c.monto_canon_mensual,
            DATEFROMPARTS(YEAR(c.fecha_inicio), MONTH(c.fecha_inicio), 1) AS FechaMes
        FROM Concesiones.Concesion c

        UNION ALL

        -- Genero meses hasta el mes actual
        SELECT
            m.id_concesion,
            m.id_empresa,
            m.id_tipo_actividad,
            m.id_parque,
            m.monto_canon_mensual,
            DATEADD(MONTH,1,m.FechaMes)
        FROM Meses m
        WHERE DATEADD(MONTH,1,m.FechaMes)
              <= DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)
    )

    SELECT
        e.razon_social AS '@Titular',
        ta.descripcion AS '@Servicio',
        p.nombre AS '@Parque',

        (
            SELECT
                MONTH(m2.FechaMes) AS '@Mes',
                YEAR(m2.FechaMes) AS '@Anio',

                m2.monto_canon_mensual
                -
                ISNULL(SUM(pc.monto_pagado),0)
                AS '@Monto_Adeudado'

            FROM Meses m2

            LEFT JOIN Concesiones.Pago_Canon pc
                ON pc.id_concesion = m2.id_concesion
               AND pc.mes_correspondiente = MONTH(m2.FechaMes)
               AND pc.anio_correspondiente = YEAR(m2.FechaMes)

            WHERE m2.id_concesion = m.id_concesion

            GROUP BY
                m2.FechaMes,
                m2.monto_canon_mensual

            HAVING
                ISNULL(SUM(pc.monto_pagado),0) < m2.monto_canon_mensual

            ORDER BY
                YEAR(m2.FechaMes),
                MONTH(m2.FechaMes)

            FOR XML PATH('Deuda_Mensual'), TYPE
        )

    FROM Meses m

    INNER JOIN Concesiones.Empresa_Concesionaria e
        ON e.id_empresa = m.id_empresa

    INNER JOIN Concesiones.Tipo_Actividad ta
        ON ta.id_tipo_actividad = m.id_tipo_actividad

    INNER JOIN GestionParques.Parque p
        ON p.id_parque = m.id_parque

    GROUP BY
        m.id_concesion,
        e.razon_social,
        ta.descripcion,
        p.nombre

    HAVING EXISTS
    (
        SELECT 1
        FROM Meses m2

        LEFT JOIN Concesiones.Pago_Canon pc
            ON pc.id_concesion = m2.id_concesion
           AND pc.mes_correspondiente = MONTH(m2.FechaMes)
           AND pc.anio_correspondiente = YEAR(m2.FechaMes)

        WHERE m2.id_concesion = m.id_concesion

        GROUP BY
            m2.FechaMes,
            m2.monto_canon_mensual

        HAVING
            ISNULL(SUM(pc.monto_pagado),0) < m2.monto_canon_mensual
    )

    FOR XML PATH('Concesionario_Deudor'),
            ROOT('Reporte_Deudores');

END;
GO

EXEC Reportes.Deudores_XML;