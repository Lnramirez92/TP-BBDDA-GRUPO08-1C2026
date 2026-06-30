/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:  C:\Temp\parques_datos.csv. Padron oficial de parques 
--nacionales y areas protegidas de la Argentina. Se utiliza para nutrir la tabla 
--principal de Parques aplicando logica Upsert sobre el nombre del parque para 
--insertar nuevas reservas o actualizar su superficie y ubicacion sin generar 
--registros duplicados.
--https://datos.gob.ar/dataset/ambiente-areas-protegidas-nacionales/archivo/ambiente_21.1
================================================================================================= */
USE ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Importacion.Importar_Parques-- Recibimos la ruta fisica del archivo
    @Ruta_Archivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @TotalLeidos INT = 0, @Insertados INT = 0, @Actualizados INT = 0, @Errores INT = 0;

    -- Si la tabla ya existia por una ejecucion anterior o fallida, la eliminamos (DROP)
    PRINT '1. Creando tabla temporal';
    IF OBJECT_ID('Importacion.Staging_Parques', 'U') IS NOT NULL 
        DROP TABLE Importacion.Staging_Parques;
    -- Creamos la tabla
    CREATE TABLE Importacion.Staging_Parques (
        nombre VARCHAR(MAX),
        provincia VARCHAR(MAX),
        creacion VARCHAR(MAX),
        hectareas VARCHAR(MAX),
        ambiente_protegido VARCHAR(MAX)
    );
    --comando de insercion masiva
 PRINT '2. Cargando datos fisicos (BULK INSERT)...';
    SET @SQL = 'BULK INSERT Importacion.Staging_Parques
                FROM ''' + @Ruta_Archivo + '''
                WITH (
                    FIELDTERMINATOR = '';'', --
                    ROWTERMINATOR = ''0x0D0A'', 
                    CODEPAGE = ''65001'',
                    FIRSTROW = 2
                );';
                
    BEGIN TRY
        EXEC sp_executesql @SQL;
        -- Contamos cuantas filas trajo el archivo
        -- Guardo la cantidad de filas que entraron para el log historico
        SELECT @TotalLeidos = COUNT(*) FROM Importacion.Staging_Parques;
    END TRY
    BEGIN CATCH
    
        PRINT 'ERROR: Fallo la lectura del archivo fisico.';
        PRINT ERROR_MESSAGE();
        RETURN;
    END CATCH

    PRINT '3. Limpieza de datos masiva...';
    -- Quitamos comillas y limpiamos espacios
    UPDATE Importacion.Staging_Parques
    SET nombre = LTRIM(RTRIM(REPLACE(ISNULL(nombre, ''), '"', ''))),
        provincia = LTRIM(RTRIM(REPLACE(ISNULL(provincia, ''), '"', ''))),
        hectareas = REPLACE(REPLACE(ISNULL(hectareas, '0'), '"', ''), ',', '.');

    PRINT '4. Separando Errores...';
  
    INSERT INTO Importacion.Registro_Errores (archivo_origen, nro_fila, motivo_error)
    SELECT 
        @Ruta_Archivo, 
        0, 
        'Error: Nombre vacio o hectareas invalidas'
    FROM Importacion.Staging_Parques
    WHERE nombre = '' OR TRY_CAST(hectareas AS DECIMAL(10,2)) IS NULL OR TRY_CAST(hectareas AS DECIMAL(10,2)) <= 0;
    
    SET @Errores = @@ROWCOUNT;

   PRINT '5. Procesando UPSERT ...';
    
    -- Uso una Tabla Temporal para guardar los limpios
    IF OBJECT_ID('tempdb..#RegistrosValidos') IS NOT NULL DROP TABLE #RegistrosValidos;
    
    SELECT nombre, provincia, CAST(hectareas AS DECIMAL(10,2)) AS superficie
    INTO #RegistrosValidos
    FROM Importacion.Staging_Parques
    WHERE nombre <> '' AND TRY_CAST(hectareas AS DECIMAL(10,2)) > 0;
    
    -- A) UPDATE: Actualizamos los parques que YA existen
    UPDATE p
    SET p.ubicacion = r.provincia, p.superficie = r.superficie
    FROM GestionParques.Parque p
    INNER JOIN #RegistrosValidos r ON p.nombre = r.nombre;
    
    SET @Actualizados = @@ROWCOUNT;

    -- B) INSERT: Insertamos los parques NUEVOS
    INSERT INTO GestionParques.Parque (nombre, ubicacion, superficie, id_tipo_parque)
    SELECT r.nombre, r.provincia, r.superficie, 1
    FROM #RegistrosValidos r
    WHERE NOT EXISTS (SELECT 1 FROM GestionParques.Parque p WHERE p.nombre = r.nombre);

    SET @Insertados = @@ROWCOUNT;
    PRINT '6. Registrando en Historial...';
    -- 4. Registro Historico
    INSERT INTO Importacion.Historial_Importaciones 
        (archivo_procesado, total_registros_leidos, registros_insertados, registros_actualizados, registros_con_error)
    VALUES 
        (@Ruta_Archivo, @TotalLeidos, @Insertados, @Actualizados, @Errores);

    PRINT '--- RESUMEN ETL ---';
    PRINT CONCAT('Leidos: ', @TotalLeidos, ' | Insertados: ', @Insertados, ' | Actualizados: ', @Actualizados, ' | Errores: ', @Errores);
    
    -- Limpieza final
    DROP TABLE Importacion.Staging_Parques;
END;
GO


