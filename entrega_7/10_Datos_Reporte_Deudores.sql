/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: creacion de deudores
================================================================================================= */

USE ParquesNacionales;
GO

DECLARE @id_actividad INT;
DECLARE @id_empresa INT;
DECLARE @id_nueva_concesion INT;

-- busco la actividad
IF NOT EXISTS (SELECT 1 FROM Concesiones.Tipo_Actividad WHERE descripcion = 'Kiosco y Comidas Rapidas')
BEGIN
    INSERT INTO Concesiones.Tipo_Actividad (descripcion) VALUES ('Kiosco y Comidas Rapidas');
    SET @id_actividad = SCOPE_IDENTITY();
END
ELSE
BEGIN
    SELECT @id_actividad = id_tipo_actividad FROM Concesiones.Tipo_Actividad WHERE descripcion = 'Kiosco y Comidas Rapidas';
END

-- busco o creo la emprsa
IF NOT EXISTS (SELECT 1 FROM Concesiones.Empresa_Concesionaria WHERE cuit = '30-99999999-9')
BEGIN
    INSERT INTO Concesiones.Empresa_Concesionaria (razon_social, cuit, contacto, activo) 
    VALUES ('La Deudora S.A.', '30-99999999-9', 'Contacto Prueba', 1);
    SET @id_empresa = SCOPE_IDENTITY();
END
ELSE
BEGIN
    SELECT @id_empresa = id_empresa FROM Concesiones.Empresa_Concesionaria WHERE cuit = '30-99999999-9';
END

-- creo la concesion
INSERT INTO Concesiones.Concesion (fecha_inicio, fecha_fin, monto_canon_mensual, id_empresa, id_tipo_actividad, id_parque)
VALUES ('2026-01-01', '2027-01-01', 50000.00, @id_empresa, @id_actividad, 1);
SET @id_nueva_concesion = SCOPE_IDENTITY();

-- inserto el pago parcial (Debia 50.000, paga solo 10.000)
INSERT INTO Concesiones.Pago_Canon (fecha_pago, monto_pagado, mes_correspondiente, anio_correspondiente, id_concesion)
VALUES ('2026-06-10', 10000.00, 6, 2026, @id_nueva_concesion);
GO