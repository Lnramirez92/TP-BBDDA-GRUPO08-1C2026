/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:Parques y vector anidado con concesiones (fecha inicio, titular, servicio).
================================================================================================= */

CREATE OR ALTER PROCEDURE Reportes.SP_Parques_Concesiones_XML
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.nombre AS '@NombreParque',
        p.ubicacion AS '@Ubicacion',
        p.superficie AS '@Hectareas',
        (
            SELECT 
                e.razon_social AS 'Titular',
                ta.descripcion AS 'Servicio',
                c.fecha_inicio AS 'FechaInicio'
            FROM Concesiones.Concesion c
            JOIN Concesiones.Empresa_Concesionaria e ON c.id_empresa = e.id_empresa
            JOIN Concesiones.Tipo_Actividad ta ON c.id_tipo_actividad = ta.id_tipo_actividad
            WHERE c.id_parque = p.id_parque
            FOR XML PATH('Concesion'), TYPE
        ) AS Concesiones_Otorgadas
    FROM GestionParques.Parque p
    FOR XML PATH('Parque'), ROOT('Catalogo_Parques_Concesiones');
END;
GO

-- Ejecucion Reporte 5 (XML):
EXEC Reportes.SP_Parques_Concesiones_XML;
