/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:Motor de reglas de precios tarifarios. El SP de ventas extrae la fecha de visita deseada por el turista, 
--consulta el endpoint y filtra el JSON resultante. Si la fecha coincide con un 
--feriado oficial de Argentina, el sistema aplica automaticamente un recargo 
--del 20% en concepto de "Tarifa de alta demanda" sobre el valor base de la entrada.
================================================================================================= */

USE ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Ventas.Verificar_Feriado_Recargo
    @FechaVenta DATE,
    @MontoBase DECIMAL(10,2),
    @MontoFinal DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Extraemos el anio para armar la URL de ArgentinaDatos
    DECLARE @Anio INT = YEAR(@FechaVenta);

    -- 2. Armamos la URL dinamica (Ej: https://api.argentinadatos.com/v1/feriados/2026)
    DECLARE @URL NVARCHAR(MAX) = 'https://api.argentinadatos.com/v1/feriados/' + CAST(@Anio AS VARCHAR(4));
    DECLARE @Object INT;
    DECLARE @ResponseText NVARCHAR(MAX);

    -- 3. Hacemos la peticion HTTP a la nueva API
    EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @Object OUT;
    EXEC sp_OAMethod @Object, 'open', NULL, 'GET', @URL, 'false';
    EXEC sp_OAMethod @Object, 'send';

    -- 4. Capturamos el JSON de respuesta
    DECLARE @ResponseTable TABLE (JsonData NVARCHAR(MAX));
    INSERT INTO @ResponseTable (JsonData)
    EXEC sp_OAGetProperty @Object, 'responseText';

    SELECT @ResponseText = JsonData FROM @ResponseTable;
    EXEC sp_OADestroy @Object;

    -- 5. Buscamos si nuestra fecha coincide con la fecha del feriado en el JSON
    DECLARE @NombreFeriado VARCHAR(255) = NULL;

    -- OPENJSON adaptado a la estructura de ArgentinaDatos ($.fecha y $.nombre)
    SELECT @NombreFeriado = nombre
    FROM OPENJSON(@ResponseText)
    WITH (
        fecha DATE '$.fecha',
        nombre VARCHAR(255) '$.nombre'
    )
    WHERE fecha = @FechaVenta;

    -- 6. Logica de Recargo Comercial
    IF @NombreFeriado IS NOT NULL
    BEGIN
        -- Es feriado: Se le cobra un 20% mas caro
        SET @MontoFinal = @MontoBase * 1.20;
        PRINT '==================================================';
        PRINT ' TARIFA DE FERIADO APLICADA';
        PRINT ' - Feriado Oficial: ' + @NombreFeriado;
        PRINT ' - Recargo: 20% (Tarifa de alta demanda)';
        PRINT ' - Monto Base: $' + CAST(@MontoBase AS VARCHAR(20));
        PRINT ' - MONTO TOTAL A COBRAR: $' + CAST(@MontoFinal AS VARCHAR(20));
        PRINT '==================================================';
    END
    ELSE
    BEGIN
        -- Dia normal
        SET @MontoFinal = @MontoBase;
        PRINT '==================================================';
        PRINT ' TARIFA NORMAL APLICADA';
        PRINT ' - La fecha ingresada es un dia laborable ordinario.';
        PRINT ' - MONTO TOTAL A COBRAR: $' + CAST(@MontoFinal AS VARCHAR(20));
        PRINT '==================================================';
    END
END;
GO
