/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: SCRIPT DE IMPORTACION ETL (DATASET B: Estadisticas de Visitantes / Turistas No Residentes)
-- Formato: CSV separado por comas.Sin cursores y con tabla Staging dinámica.
--https://datos.yvera.gob.ar/dataset/turismo-internacional-total-pais
================================================================================================= */

USE ParquesNacionales;
GO

-- 1. Nos aseguramos de que la tabla final exista 
IF OBJECT_ID('GestionParques.Estadistica_Visitante', 'U') IS NULL 
BEGIN
    CREATE TABLE GestionParques.Estadistica_Visitante (
        id_estadistica INT IDENTITY(1,1) PRIMARY KEY,
        fecha DATE,
        medio_transporte VARCHAR(100),
        pais_origen VARCHAR(100),
        cantidad_turistas INT
    );
    PRINT 'Tabla destino de Estadisticas creada exitosamente.';
END
GO

-- 2. PROCEDIMIENTO ALMACENADO PRINCIPAL
CREATE OR ALTER PROCEDURE Importacion.Importar_Estadisticas_Turismo
    @Ruta_Archivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @TotalLeidos INT = 0, @Insertados INT = 0, @Actualizados INT = 0, @Errores INT = 0;
    
    PRINT '1. Creando tabla Staging temporal';
    IF OBJECT_ID('Importacion.Staging_Turistas', 'U') IS NOT NULL 
        DROP TABLE Importacion.Staging_Turistas;

    CREATE TABLE Importacion.Staging_Turistas (
        indice_tiempo VARCHAR(MAX),
        medio_de_transporte VARCHAR(MAX),
        pais_origen VARCHAR(MAX),
        viajes_de_turistas_no_residentes VARCHAR(MAX),
        observaciones VARCHAR(MAX)
    );

SET @SQL = 'BULK INSERT Importacion.Staging_Turistas
                FROM ''' + @Ruta_Archivo + '''
                WITH (
                    FIELDTERMINATOR = '','', 
                    ROWTERMINATOR = ''0x0a'', 
                    CODEPAGE = ''65001'',
                    FIRSTROW = 2
                );';
                
    BEGIN TRY
        EXEC sp_executesql @SQL;
        SELECT @TotalLeidos = COUNT(*) FROM Importacion.Staging_Turistas;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CRITICO AL LEER EL ARCHIVO:';
        PRINT ERROR_MESSAGE();
        RETURN;
    END CATCH

    PRINT '3. Limpieza de datos masiva';
    UPDATE Importacion.Staging_Turistas
    SET indice_tiempo = LTRIM(RTRIM(REPLACE(ISNULL(indice_tiempo, ''), '"', ''))),
        medio_de_transporte = LTRIM(RTRIM(REPLACE(ISNULL(medio_de_transporte, ''), '"', ''))),
        pais_origen = LTRIM(RTRIM(REPLACE(ISNULL(pais_origen, ''), '"', ''))),
        viajes_de_turistas_no_residentes = LTRIM(RTRIM(REPLACE(ISNULL(viajes_de_turistas_no_residentes, '0'), '"', '')));
    
    PRINT '4. Separando Errores...';
    -- Enviamos los registros corruptos a la tabla de errores
    INSERT INTO Importacion.Registro_Errores (archivo_origen, nro_fila, motivo_error)
    SELECT 
        @Ruta_Archivo, 
        0, 
        'Error: Fecha, Transporte o Pais vacios, o cantidad invalida'
    FROM Importacion.Staging_Turistas
    WHERE TRY_CAST(indice_tiempo AS DATE) IS NULL 
       OR medio_de_transporte = '' 
       OR pais_origen = '' 
       OR TRY_CAST(viajes_de_turistas_no_residentes AS INT) IS NULL 
       OR TRY_CAST(viajes_de_turistas_no_residentes AS INT) < 0;

    SET @Errores = @@ROWCOUNT;

    PRINT '5. Procesando UPSERT...';
    
    -- Filtramos los datos sanos hacia una tabla temporal
    IF OBJECT_ID('tempdb..#TuristasValidos') IS NOT NULL DROP TABLE #TuristasValidos;
    
    SELECT 
        CAST(indice_tiempo AS DATE) AS fecha, 
        medio_de_transporte AS transporte, 
        pais_origen AS pais, 
        CAST(viajes_de_turistas_no_residentes AS INT) AS cantidad
    INTO #TuristasValidos
    FROM Importacion.Staging_Turistas
    WHERE TRY_CAST(indice_tiempo AS DATE) IS NOT NULL 
      AND medio_de_transporte <> '' 
      AND pais_origen <> '' 
      AND TRY_CAST(viajes_de_turistas_no_residentes AS INT) >= 0;

    -- A) UPDATE: Si ya existe una fila para esa fecha, ese medio y ese pais, actualizamos la cantidad
    UPDATE e
    SET e.cantidad_turistas = t.cantidad
    FROM GestionParques.Estadistica_Visitante e
    INNER JOIN #TuristasValidos t 
        ON e.fecha = t.fecha AND e.medio_transporte = t.transporte AND e.pais_origen = t.pais;
    
    SET @Actualizados = @@ROWCOUNT;

    -- B) INSERT: Si la combinacion (fecha + transporte + pais) no existe, insertamos el nuevo registro
    INSERT INTO GestionParques.Estadistica_Visitante (fecha, medio_transporte, pais_origen, cantidad_turistas)
    SELECT t.fecha, t.transporte, t.pais, t.cantidad
    FROM #TuristasValidos t
    WHERE NOT EXISTS (
        SELECT 1 FROM GestionParques.Estadistica_Visitante e 
        WHERE e.fecha = t.fecha AND e.medio_transporte = t.transporte AND e.pais_origen = t.pais
    );

    SET @Insertados = @@ROWCOUNT;

    PRINT '6. Registrando en Historial...';
    INSERT INTO Importacion.Historial_Importaciones 
        (archivo_procesado, total_registros_leidos, registros_insertados, registros_actualizados, registros_con_error)
    VALUES 
        (@Ruta_Archivo, @TotalLeidos, @Insertados, @Actualizados, @Errores);

    PRINT '==================================================';
    PRINT ' PROCESO ETL FINALIZADO - DATASET B';
    PRINT CONCAT(' Leidos: ', @TotalLeidos, ' | Insertados: ', @Insertados, ' | Actualizados: ', @Actualizados, ' | Errores: ', @Errores);
    PRINT '==================================================';

    -- Limpiamos la tabla staging
    DROP TABLE Importacion.Staging_Turistas;
END;
GO

