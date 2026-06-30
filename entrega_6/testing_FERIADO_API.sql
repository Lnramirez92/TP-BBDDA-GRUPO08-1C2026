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

------------------------------------    TESTING     ----------------------------
DECLARE @TotalPagar DECIMAL(10,2);
EXEC Ventas.Verificar_Feriado_Recargo
    @FechaVenta = '2026-05-01', 
    @MontoBase = 10000.00, 
    @MontoFinal = @TotalPagar OUTPUT;
--------------- dia laborable   --------------------------
DECLARE @TotalPagar_la DECIMAL(10,2);
EXEC Ventas.Verificar_Feriado_Recargo 
    @FechaVenta = '2026-09-15', 
    @MontoBase = 10000.00, 
    @MontoFinal = @TotalPagar_la OUTPUT;