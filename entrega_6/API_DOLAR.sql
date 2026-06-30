/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:Transformacion monetaria en tiempo real exigida en la 
--rubrica. Permite al modulo de ventas recibir un precio base en dolares 
--estadounidenses para visitantes extranjeros y convertirlo automaticamente a pesos argentinos 
--utilizando el valor de venta oficial al momento exacto de la transaccion.
--https://dolarapi.com/v1/dolares/oficial
================================================================================================= */

USE ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Ventas.Cobrar_Entrada_Extranjero
    @MontoDolares DECIMAL(10,2),
    @MontoPesos DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1. Configuramos la URL de la API del Dolar Oficial
    DECLARE @URL NVARCHAR(MAX) = 'https://dolarapi.com/v1/dolares/oficial';
    DECLARE @Object INT;
    DECLARE @ResponseText NVARCHAR(MAX);

    -- 2. Creamos un objeto HTTP en Windows desde SQL
    EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @Object OUT;
    
    -- 3. Hacemos la peticion GET a la API
    EXEC sp_OAMethod @Object, 'open', NULL, 'GET', @URL, 'false';
    EXEC sp_OAMethod @Object, 'send';
    
    -- 4. Guardamos la respuesta de la API (El JSON) en una tabla temporal
    DECLARE @ResponseTable TABLE (JsonData NVARCHAR(MAX));
    INSERT INTO @ResponseTable (JsonData)
    EXEC sp_OAGetProperty @Object, 'responseText';
    
    SELECT @ResponseText = JsonData FROM @ResponseTable;
    
    -- 5. Destruimos el objeto para liberar memoria de la PC
    EXEC sp_OADestroy @Object;

    -- 6. Analizamos el JSON que nos devolvio la API para sacar el valor
    DECLARE @CotizacionVenta DECIMAL(10,2);
    
    -- Extraemos el valor "venta" del JSON 
    SELECT @CotizacionVenta = CAST(JSON_VALUE(@ResponseText, '$.venta') AS DECIMAL(10,2));

    -- 7. Calculamos el total
    SET @MontoPesos = @MontoDolares * @CotizacionVenta;
    
    PRINT '==================================================';
    PRINT ' CONEXION A API EXITOSA (DolarApi.com)';
    PRINT ' - Cotizacion Oficial Venta de hoy: $' + CAST(@CotizacionVenta AS VARCHAR(20));
    PRINT ' - Valor de la entrada: USD ' + CAST(@MontoDolares AS VARCHAR(20));
    PRINT ' - TOTAL A COBRAR EN PESOS: $' + CAST(@MontoPesos AS VARCHAR(20));
    PRINT '==================================================';
END;
GO

