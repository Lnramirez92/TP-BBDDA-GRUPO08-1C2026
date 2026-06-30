/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: SCRIPT DE IMPORTACION ETL (DATASET C: Alojamientos Turisticos)
-- Formato: JSON / GEOJSON. Lógica basada en conjuntos (Set-Based) sin cursores y con tabla Staging dinámica.
--https://data.buenosaires.gob.ar/dataset/alojamientos-turisticos
================================================================================================= */
USE ParquesNacionales;
GO

-- 1. TABLA FINAL PARA ALOJAMIENTOS (Nos aseguramos que exista)
IF OBJECT_ID('GestionParques.Alojamiento_Turistico', 'U') IS NULL 
BEGIN
    CREATE TABLE GestionParques.Alojamiento_Turistico (
        id_alojamiento INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(150),
        tipo_alojamiento VARCHAR(100),
        direccion VARCHAR(200),
        latitud VARCHAR(50),
        longitud VARCHAR(50)
    );
    PRINT 'Tabla de Alojamientos Turisticos creada exitosamente.';
END
GO

-- 2. PROCEDIMIENTO ALMACENADO PRINCIPAL
CREATE OR ALTER PROCEDURE Importacion.Importar_Alojamientos_JSON
    @Ruta_Archivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @JSON_Data NVARCHAR(MAX);
    DECLARE @TotalLeidos INT = 0, @Insertados INT = 0, @Actualizados INT = 0, @Errores INT = 0;
    
    PRINT '1. Creando tabla Staging temporal (Todo VARCHAR)...';
    IF OBJECT_ID('Importacion.Staging_Alojamientos', 'U') IS NOT NULL 
        DROP TABLE Importacion.Staging_Alojamientos;

   
    CREATE TABLE Importacion.Staging_Alojamientos (
        nombre VARCHAR(MAX),
        tipo VARCHAR(MAX),
        direccion VARCHAR(MAX),
        latitud VARCHAR(MAX),
        longitud VARCHAR(MAX)
    );

    PRINT '2. Cargando archivo JSON fisico en memoria...';
    SET @SQL = N'SELECT @jsonOut = BulkColumn FROM OPENROWSET(BULK ''' + @Ruta_Archivo + ''', SINGLE_CLOB) AS j;';
    
    BEGIN TRY
        EXEC sp_executesql @SQL, N'@jsonOut NVARCHAR(MAX) OUTPUT', @jsonOut = @JSON_Data OUTPUT;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR CRITICO: No se pudo leer el archivo JSON.';
        PRINT ERROR_MESSAGE();
        RETURN;
    END CATCH

    PRINT '3. Desarmando etiquetas JSON y volcando en Staging...';
    -- Usamos OPENJSON como si fuera una tabla normal y lo insertamos de golpe
    INSERT INTO Importacion.Staging_Alojamientos (nombre, tipo, direccion, latitud, longitud)
    SELECT nombre, tipo, direccion, latitud, longitud
    FROM OPENJSON(@JSON_Data, '$.features')
    WITH (
        nombre VARCHAR(MAX) '$.properties.nombre',
        tipo VARCHAR(MAX) '$.properties.tipo',
        direccion VARCHAR(MAX) '$.properties.direccion',
        latitud VARCHAR(MAX) '$.properties.lat',
        longitud VARCHAR(MAX) '$.properties.long'
    );

    SET @TotalLeidos = @@ROWCOUNT;

    PRINT '4. Limpieza de datos masiva...';
    UPDATE Importacion.Staging_Alojamientos
    SET nombre = LTRIM(RTRIM(ISNULL(nombre, ''))),
        tipo = LTRIM(RTRIM(ISNULL(tipo, 'Sin Especificar'))),
        direccion = LTRIM(RTRIM(ISNULL(direccion, '')));

    PRINT '5. Separando Errores...';
    -- Enviamos a la tabla de errores los alojamientos que no tengan nombre o direccion
    INSERT INTO Importacion.Registro_Errores (archivo_origen, nro_fila, motivo_error)
    SELECT 
        @Ruta_Archivo, 
        0, 
        'Error: Nombre del alojamiento o direccion vacios'
    FROM Importacion.Staging_Alojamientos
    WHERE nombre = '' OR direccion = '';

    SET @Errores = @@ROWCOUNT;

    PRINT '6. Procesando UPSERT (Lógica de conjuntos)...';
    
    -- Filtramos los datos validos hacia una tabla temporal
    IF OBJECT_ID('tempdb..#AlojamientosValidos') IS NOT NULL DROP TABLE #AlojamientosValidos;
    
    SELECT 
        CAST(nombre AS VARCHAR(150)) AS nombre, 
        CAST(tipo AS VARCHAR(100)) AS tipo_alojamiento, 
        CAST(direccion AS VARCHAR(200)) AS direccion, 
        CAST(latitud AS VARCHAR(50)) AS latitud, 
        CAST(longitud AS VARCHAR(50)) AS longitud
    INTO #AlojamientosValidos
    FROM Importacion.Staging_Alojamientos
    WHERE nombre <> '' AND direccion <> '';

    -- A) UPDATE: Buscamos si el hotel ya existe por nombre y direccion
    UPDATE a
    SET a.tipo_alojamiento = v.tipo_alojamiento, 
        a.latitud = v.latitud, 
        a.longitud = v.longitud
    FROM GestionParques.Alojamiento_Turistico a
    INNER JOIN #AlojamientosValidos v ON a.nombre = v.nombre AND a.direccion = v.direccion;
    
    SET @Actualizados = @@ROWCOUNT;

    -- B) INSERT: Insertamos los alojamientos nuevos
    INSERT INTO GestionParques.Alojamiento_Turistico (nombre, tipo_alojamiento, direccion, latitud, longitud)
    SELECT v.nombre, v.tipo_alojamiento, v.direccion, v.latitud, v.longitud
    FROM #AlojamientosValidos v
    WHERE NOT EXISTS (
        SELECT 1 FROM GestionParques.Alojamiento_Turistico a 
        WHERE a.nombre = v.nombre AND a.direccion = v.direccion
    );

    SET @Insertados = @@ROWCOUNT;

    PRINT '7. Registrando en Historial...';
    INSERT INTO Importacion.Historial_Importaciones 
        (archivo_procesado, total_registros_leidos, registros_insertados, registros_actualizados, registros_con_error)
    VALUES 
        (@Ruta_Archivo, @TotalLeidos, @Insertados, @Actualizados, @Errores);

    PRINT '==================================================';
    PRINT ' PROCESO ETL FINALIZADO - DATASET C (JSON)';
    PRINT CONCAT(' Leidos: ', @TotalLeidos, ' | Insertados: ', @Insertados, ' | Actualizados: ', @Actualizados, ' | Errores: ', @Errores);
    PRINT '==================================================';

    -- Limpieza de tabla 
    DROP TABLE Importacion.Staging_Alojamientos;
END;
GO

