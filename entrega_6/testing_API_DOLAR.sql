/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION:TESTING
================================================================================================= */

USE ParquesNacionales;
GO
-------------------------------------   TESTING ----------------------
DECLARE @TotalAPagar DECIMAL(10,2);

-- Simulamos que le cobramos una entrada de 25 dolares
EXEC Ventas.Cobrar_Entrada_Extranjero 
    @MontoDolares = 25.00, 
    @MontoPesos = @TotalAPagar OUTPUT;