/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: Script 03 - Carga de datos iniciales (Seed Data) para todas las tablas
-- REQUISITOS CUMPLIDOS:
--   - 10+ Parques
--   - 30+ Actividades/Tours
--   - 20+ Guías
--   - 20+ Guardaparques
--   - 10+ Concesiones
--   - Historial de ventas de entradas
--   - Casos obligatorios: actividades simultáneas, cupo completo, concesiones vigentes/vencidas
================================================================================================= */

USE ParquesNacionales;
GO

-- ================================================================================================
-- 1. CARGA DE DATOS MAESTROS - SCHEMA GestionParques
-- ================================================================================================

-- 1.1 Tipos de Parque (5 tipos)
INSERT INTO GestionParques.Tipo_Parque (descripcion)
VALUES 
    ('Parque Nacional'),
    ('Reserva Natural'),
    ('Monumento Natural'),
    ('Parque Provincial'),
    ('Área Protegida');

-- 1.2 Parques (10 parques en diferentes provincias)
INSERT INTO GestionParques.Parque (nombre, ubicacion, superficie, id_tipo_parque, activo)
VALUES 
    ('Parque Nacional Los Glaciares', 'Santa Cruz', 726927.00, 1, 1),
    ('Parque Nacional Iguazú', 'Misiones', 67720.00, 1, 1),
    ('Parque Nacional Nahuel Huapi', 'Neuquén/Río Negro', 705000.00, 1, 1),
    ('Parque Nacional Tierra del Fuego', 'Tierra del Fuego', 63000.00, 1, 1),
    ('Reserva Natural Otamendi', 'Buenos Aires', 3200.00, 2, 1),
    ('Monumento Natural Bosques Petrificados', 'Santa Cruz', 15000.00, 3, 1),
    ('Parque Nacional Talampaya', 'La Rioja', 215000.00, 1, 1),
    ('Parque Nacional El Palmar', 'Entre Ríos', 8500.00, 1, 1),
    ('Parque Provincial Aconcagua', 'Mendoza', 71000.00, 4, 1),
    ('Área Protegida Península Valdés', 'Chubut', 400000.00, 5, 1);

-- 1.3 Actividades y Tours (35 actividades distribuidas en los parques)
INSERT INTO GestionParques.Atraccion (nombre, costo, duracion_minutos, cupo_maximo, tipo_atraccion, id_parque, activo)
VALUES 
    -- Parque Los Glaciares (id_parque = 1) - 4 actividades
    ('Mini Trekking Perito Moreno', 85000.00, 180, 20, 'Tour', 1, 1),
    ('Navegación a los Glaciares', 45000.00, 300, 150, 'Atraccion', 1, 1),
    ('Senderismo Cerro Fitz Roy', 20000.00, 480, 15, 'Tour', 1, 1),
    ('Avistaje de Cóndores', 15000.00, 120, 25, 'Atraccion', 1, 1),
    
    -- Parque Iguazú (id_parque = 2) - 4 actividades
    ('Garganta del Diablo', 35000.00, 240, 200, 'Atraccion', 2, 1),
    ('Circuito Superior', 25000.00, 180, 100, 'Atraccion', 2, 1),
    ('Circuito Inferior', 25000.00, 180, 100, 'Atraccion', 2, 1),
    ('Paseo en Lancha', 40000.00, 120, 50, 'Tour', 2, 1),
    
    -- Parque Nahuel Huapi (id_parque = 3) - 4 actividades
    ('Ascenso Cerro Catedral', 18000.00, 360, 30, 'Tour', 3, 1),
    ('Isla Victoria', 22000.00, 300, 80, 'Atraccion', 3, 1),
    ('Puerto Blest', 20000.00, 240, 60, 'Atraccion', 3, 1),
    ('Kayak en Lago Nahuel Huapi', 15000.00, 180, 10, 'Tour', 3, 1),
    
    -- Parque Tierra del Fuego (id_parque = 4) - 3 actividades
    ('Tren del Fin del Mundo', 12000.00, 180, 120, 'Atraccion', 4, 1),
    ('Senderismo Bahía Lapataia', 8000.00, 240, 20, 'Tour', 4, 1),
    ('Avistaje de Aves', 10000.00, 150, 15, 'Atraccion', 4, 1),
    
    -- Reserva Otamendi (id_parque = 5) - 3 actividades
    ('Observación de Aves Migratorias', 5000.00, 120, 20, 'Atraccion', 5, 1),
    ('Sendero Interpretativo', 3000.00, 90, 30, 'Tour', 5, 1),
    ('Avistaje de Carpinchos', 4000.00, 150, 25, 'Atraccion', 5, 1),
    
    -- Monumento Bosques Petrificados (id_parque = 6) - 3 actividades
    ('Recorrido Paleontológico', 8000.00, 180, 15, 'Tour', 6, 1),
    ('Avistaje de Estrellas', 12000.00, 120, 10, 'Atraccion', 6, 1),
    ('Senderismo Bosque Petrificado', 6000.00, 240, 12, 'Tour', 6, 1),
    
    -- Parque Talampaya (id_parque = 7) - 4 actividades
    ('Cañón de Talampaya', 15000.00, 300, 30, 'Tour', 7, 1),
    ('Ciudad Perdida', 12000.00, 180, 20, 'Tour', 7, 1),
    ('Petroglifos', 10000.00, 150, 25, 'Atraccion', 7, 1),
    ('Avistaje de Fauna Autóctona', 8000.00, 120, 20, 'Atraccion', 7, 1),
    
    -- Parque El Palmar (id_parque = 8) - 3 actividades
    ('Palmeras del Palmar', 7000.00, 180, 40, 'Atraccion', 8, 1),
    ('Senderos del Palmar', 5000.00, 150, 25, 'Tour', 8, 1),
    ('Avistaje de Yacarés', 6000.00, 120, 20, 'Atraccion', 8, 1),
    
    -- Parque Aconcagua (id_parque = 9) - 4 actividades
    ('Trekking Base Aconcagua', 25000.00, 360, 20, 'Tour', 9, 1),
    ('Avistaje de Guanacos', 10000.00, 180, 15, 'Atraccion', 9, 1),
    ('Ascenso a Campamento Plaza', 35000.00, 480, 8, 'Tour', 9, 1), -- Cupo reducido
    ('Fotografía de Flora de Altura', 8000.00, 150, 10, 'Atraccion', 9, 1),
    
    -- Península Valdés (id_parque = 10) - 3 actividades
    ('Avistaje de Ballenas', 35000.00, 240, 50, 'Tour', 10, 1),
    ('Colonia de Pingüinos', 15000.00, 180, 60, 'Atraccion', 10, 1),
    ('Avistaje de Orcas', 40000.00, 300, 30, 'Tour', 10, 1);

-- ================================================================================================
-- 2. CARGA DE DATOS MAESTROS - SCHEMA Ventas
-- ================================================================================================

-- 2.1 Tipos de Visitante
INSERT INTO Ventas.Tipo_Visitante (descripcion, activo)
VALUES 
    ('Residente Nacional', 1),
    ('Extranjero Mercosur', 1),
    ('Extranjero No Mercosur', 1),
    ('Estudiante Universitario', 1),
    ('Jubilado/Pensionado', 1),
    ('Menor de 12 años', 1),
    ('Discapacitado', 1),
    ('Docente', 1);

-- 2.2 Formas de Pago
INSERT INTO Ventas.Forma_Pago (descripcion)
VALUES 
    ('Efectivo'),
    ('Tarjeta Débito'),
    ('Tarjeta Crédito'),
    ('Transferencia'),
    ('Mercado Pago'),
    ('QR Code');

-- 2.3 Usuarios (vendedores)
INSERT INTO Ventas.Usuario (nombre, rol, activo)
VALUES 
    ('AdminSistema', 'Administrador', 1),
    ('Vendedor1', 'Vendedor', 1),
    ('Vendedor2', 'Vendedor', 1),
    ('Vendedor3', 'Vendedor', 1),
    ('Supervisor1', 'Supervisor', 1);

-- 2.4 Tipos de Entrada (para diferentes parques y categorías)
-- Creamos precios variados para cada parque y tipo de visitante

-- Función auxiliar para generar fechas (usamos inserciones directas)
-- Parque Los Glaciares (id_parque = 1)
INSERT INTO Ventas.Tipo_Entrada (id_tipo_visitante, precio, fecha_desde, fecha_hasta, id_parque, activo)
VALUES 
    (1, 1500.00, '20260101', '20261231', 1, 1),
    (2, 3000.00, '20260101', '20261231', 1, 1),
    (3, 5000.00, '20260101', '20261231', 1, 1),
    (4, 750.00, '20260101', '20261231', 1, 1),
    (5, 750.00, '20260101', '20261231', 1, 1);

-- Parque Iguazú (id_parque = 2)
INSERT INTO Ventas.Tipo_Entrada (id_tipo_visitante, precio, fecha_desde, fecha_hasta, id_parque, activo)
VALUES 
    (1, 2000.00, '20260101', '20261231', 2, 1),
    (2, 4000.00, '20260101', '20261231', 2, 1),
    (3, 6000.00, '20260101', '20261231', 2, 1),
    (4, 1000.00, '20260101', '20261231', 2, 1),
    (5, 1000.00, '20260101', '20261231', 2, 1);

-- Parque Nahuel Huapi (id_parque = 3)
INSERT INTO Ventas.Tipo_Entrada (id_tipo_visitante, precio, fecha_desde, fecha_hasta, id_parque, activo)
VALUES 
    (1, 1200.00, '20260101', '20261231', 3, 1),
    (2, 2500.00, '20260101', '20261231', 3, 1),
    (3, 4000.00, '20260101', '20261231', 3, 1),
    (4, 600.00, '20260101', '20261231', 3, 1),
    (5, 600.00, '20260101', '20261231', 3, 1);

-- Parque Tierra del Fuego (id_parque = 4)
INSERT INTO Ventas.Tipo_Entrada (id_tipo_visitante, precio, fecha_desde, fecha_hasta, id_parque, activo)
VALUES 
    (1, 1000.00, '20260101', '20261231', 4, 1),
    (2, 2000.00, '20260101', '20261231', 4, 1),
    (3, 3500.00, '20260101', '20261231', 4, 1),
    (4, 500.00, '20260101', '20261231', 4, 1),
    (5, 500.00, '20260101', '20261231', 4, 1);

-- Parque Talampaya (id_parque = 7)
INSERT INTO Ventas.Tipo_Entrada (id_tipo_visitante, precio, fecha_desde, fecha_hasta, id_parque, activo)
VALUES 
    (1, 800.00, '20260101', '20261231', 7, 1),
    (2, 1600.00, '20260101', '20261231', 7, 1),
    (3, 2800.00, '20260101', '20261231', 7, 1),
    (4, 400.00, '20260101', '20261231', 7, 1),
    (5, 400.00, '20260101', '20261231', 7, 1);

-- Parque Aconcagua (id_parque = 9)
INSERT INTO Ventas.Tipo_Entrada (id_tipo_visitante, precio, fecha_desde, fecha_hasta, id_parque, activo)
VALUES 
    (1, 1800.00, '20260101', '20261231', 9, 1),
    (2, 3500.00, '20260101', '20261231', 9, 1),
    (3, 5500.00, '20260101', '20261231', 9, 1),
    (4, 900.00, '20260101', '20261231', 9, 1),
    (5, 900.00, '20260101', '20261231', 9, 1);

-- ================================================================================================
-- 3. CARGA DE DATOS MAESTROS - SCHEMA Personal
-- ================================================================================================

-- 3.1 Títulos
INSERT INTO Personal.Titulo (descripcion)
VALUES 
    ('Guía de Montaña'),
    ('Guía de Turismo'),
    ('Biólogo'),
    ('Guía de Aves'),
    ('Guía de Interpretación'),
    ('Técnico en Turismo'),
    ('Licenciado en Turismo'),
    ('Guardaparque Nacional'),
    ('Geólogo');

-- 3.2 Guías (22 guías)
INSERT INTO Personal.Guia (nombre, apellido, fecha_nacimiento, dni, especialidad, id_titulo, activo)
VALUES 
    ('Carlos', 'González', '19850315', '12345678', 'Montaña', 1, 1),
    ('María', 'Pérez', '19900722', '23456789', 'Biodiversidad', 2, 1),
    ('Juan', 'Martínez', '19881105', '34567890', 'Aves', 4, 1),
    ('Ana', 'López', '19920118', '45678901', 'Interpretación', 5, 1),
    ('Roberto', 'Fernández', '19830930', '56789012', 'Montaña', 1, 1),
    ('Laura', 'García', '19950512', '67890123', 'Biodiversidad', 2, 1),
    ('Martín', 'Rodríguez', '19871225', '78901234', 'Aves', 4, 1),
    ('Sofía', 'Díaz', '19910808', '89012345', 'Interpretación', 5, 1),
    ('Pablo', 'Sánchez', '19840417', '90123456', 'Montaña', 1, 1),
    ('Valentina', 'Romero', '19931029', '01234567', 'Biodiversidad', 3, 1),
    ('Miguel', 'Torres', '19860614', '12345098', 'Turismo', 6, 1),
    ('Camila', 'Ruiz', '19940228', '23456109', 'Turismo', 7, 1),
    ('Fernando', 'Castillo', '19890719', '34567210', 'Geología', 9, 1),
    ('Natalia', 'Mendoza', '19921103', '45678321', 'Interpretación', 5, 1),
    ('Diego', 'Herrera', '19850909', '56789432', 'Montaña', 1, 1),
    ('Lucía', 'Alvarez', '19930421', '67890543', 'Aves', 4, 1),
    ('Javier', 'Gómez', '19870812', '78901654', 'Biodiversidad', 2, 1),
    ('Florencia', 'Paz', '19911201', '89012765', 'Turismo', 7, 1),
    ('Andrés', 'Ríos', '19840516', '90123876', 'Montaña', 1, 1),
    ('Carolina', 'Vega', '19950925', '01234987', 'Interpretación', 5, 1),
    ('Esteban', 'Molina', '19900207', '12345000', 'Geología', 9, 1),
    ('Paula', 'Núñez', '19880630', '23456111', 'Turismo', 6, 1);

-- 3.3 Habilitaciones para Guías
INSERT INTO Personal.Habilitacion_Guia (nro_matricula, fecha_emision, estado, id_guia)
VALUES 
    ('MAT-001', '20240110', 'Activa', 1),
    ('MAT-002', '20240115', 'Activa', 2),
    ('MAT-003', '20240201', 'Activa', 3),
    ('MAT-004', '20240210', 'Activa', 4),
    ('MAT-005', '20240301', 'Activa', 5),
    ('MAT-006', '20240315', 'Activa', 6),
    ('MAT-007', '20240401', 'Activa', 7),
    ('MAT-008', '20240410', 'Activa', 8),
    ('MAT-009', '20240501', 'Activa', 9),
    ('MAT-010', '20240515', 'Activa', 10),
    ('MAT-011', '20240601', 'Activa', 11),
    ('MAT-012', '20240610', 'Activa', 12),
    ('MAT-013', '20240701', 'Activa', 13),
    ('MAT-014', '20240715', 'Activa', 14),
    ('MAT-015', '20240801', 'Activa', 15),
    ('MAT-016', '20240810', 'Activa', 16),
    ('MAT-017', '20240901', 'Activa', 17),
    ('MAT-018', '20240915', 'Activa', 18),
    ('MAT-019', '20241001', 'Activa', 19),
    ('MAT-020', '20241010', 'Activa', 20),
    ('MAT-021', '20241101', 'Inactiva', 21),
    ('MAT-022', '20241115', 'Activa', 22);

-- 3.4 Asignación de Guías a Actividades (al menos 1 guía por tour)
INSERT INTO Personal.Asignacion_Guia (id_atraccion, id_guia, fecha_inicio, fecha_egreso)
VALUES 
    -- Tours del Parque Los Glaciares
    (1, 1, '20260101', NULL),  -- Mini Trekking
    (1, 5, '20260101', NULL),  -- Mini Trekking (2do guía)
    (3, 9, '20260101', NULL),  -- Senderismo Fitz Roy
    (3, 15, '20260101', NULL), -- Senderismo Fitz Roy
    
    -- Tours del Parque Iguazú
    (8, 3, '20260101', NULL),  -- Paseo en Lancha
    (8, 7, '20260101', NULL),  -- Paseo en Lancha
    
    -- Tours del Parque Nahuel Huapi
    (9, 4, '20260101', NULL),  -- Ascenso Cerro Catedral
    (9, 8, '20260101', NULL),  -- Ascenso Cerro Catedral
    (12, 2, '20260101', NULL), -- Kayak en Lago
    
    -- Tours del Parque Tierra del Fuego
    (14, 6, '20260101', NULL), -- Senderismo Bahía Lapataia
    (14, 10, '20260101', NULL),
    
    -- Tours de la Reserva Otamendi
    (17, 11, '20260101', NULL), -- Sendero Interpretativo
    
    -- Tours del Monumento Bosques Petrificados
    (19, 13, '20260101', NULL), -- Recorrido Paleontológico
    (21, 13, '20260101', NULL), -- Senderismo Bosque Petrificado
    
    -- Tours del Parque Talampaya
    (22, 14, '20260101', NULL), -- Cañón de Talampaya
    (23, 18, '20260101', NULL), -- Ciudad Perdida
    
    -- Tours del Parque El Palmar
    (26, 12, '20260101', NULL), -- Senderos del Palmar
    
    -- Tours del Parque Aconcagua
    (28, 20, '20260101', NULL), -- Trekking Base
    (30, 15, '20260101', NULL), -- Ascenso Campamento
    
    -- Tours de Península Valdés
    (32, 16, '20260101', NULL), -- Avistaje de Ballenas
    (34, 22, '20260101', NULL); -- Avistaje de Orcas

-- 3.5 Guardaparques (22 guardaparques)
INSERT INTO Personal.Guardaparque (nombre, apellido, dni, fecha_nacimiento, activo)
VALUES 
    ('Hugo', 'Méndez', '11111111', '19800214', 1),
    ('Elena', 'Silva', '22222222', '19850620', 1),
    ('Luis', 'Ortiz', '33333333', '19820910', 1),
    ('Marta', 'Reyes', '44444444', '19881205', 1),
    ('Oscar', 'Cruz', '55555555', '19790425', 1),
    ('Cecilia', 'Flores', '66666666', '19830815', 1),
    ('Ricardo', 'Muñoz', '77777777', '19861130', 1),
    ('Andrea', 'Paredes', '88888888', '19900120', 1),
    ('Jorge', 'Campos', '99999999', '19840318', 1),
    ('Rosa', 'Guzmán', '10101010', '19870722', 1),
    ('Daniel', 'Ramos', '12121212', '19811011', 1),
    ('Patricia', 'Blanco', '13131313', '19890528', 1),
    ('Alberto', 'Mora', '14141414', '19830907', 1),
    ('Silvia', 'Castro', '15151515', '19860219', 1),
    ('Raúl', 'Romero', '16161616', '19801203', 1),
    ('Lucía', 'Santos', '17171717', '19910614', 1),
    ('Gustavo', 'Peralta', '18181818', '19850826', 1),
    ('Ana', 'Navarro', '19191919', '19880409', 1),
    ('Mario', 'Cabrera', '20202020', '19821116', 1),
    ('Isabel', 'Ramos', '21212121', '19870330', 1),
    ('Francisco', 'Vargas', '22222223', '19840712', 1),
    ('Carina', 'Luna', '23232323', '19901025', 1);

-- 3.6 Asignación de Guardaparques a Parques (al menos 1 por parque)
INSERT INTO Personal.Asignacion_Guardaparque (fecha_ingreso, fecha_egreso, motivo_egreso, id_guardaparque, id_parque)
VALUES 
    -- Parque Los Glaciares
    ('20100115', NULL, NULL, 1, 1),
    ('20120320', NULL, NULL, 2, 1),
    ('20150610', NULL, NULL, 3, 1),
    
    -- Parque Iguazú
    ('20080512', NULL, NULL, 4, 2),
    ('20110925', NULL, NULL, 5, 2),
    ('20140218', NULL, NULL, 6, 2),
    
    -- Parque Nahuel Huapi
    ('20130701', NULL, NULL, 7, 3),
    ('20161115', NULL, NULL, 8, 3),
    ('20180422', NULL, NULL, 9, 3),
    
    -- Parque Tierra del Fuego
    ('20090819', NULL, NULL, 10, 4),
    ('20121203', NULL, NULL, 11, 4),
    
    -- Reserva Otamendi
    ('20170314', NULL, NULL, 12, 5),
    ('20200630', NULL, NULL, 13, 5),
    
    -- Bosques Petrificados
    ('20160908', NULL, NULL, 14, 6),
    ('20190211', NULL, NULL, 15, 6),
    
    -- Parque Talampaya
    ('20110429', NULL, NULL, 16, 7),
    ('20140816', NULL, NULL, 17, 7),
    ('20171201', NULL, NULL, 18, 7),
    
    -- Parque El Palmar
    ('20181005', NULL, NULL, 19, 8),
    ('20210120', NULL, NULL, 20, 8),
    
    -- Parque Aconcagua
    ('20131111', NULL, NULL, 21, 9),
    ('20160327', NULL, NULL, 22, 9);
    
-- ================================================================================================
-- 4. CARGA DE DATOS MAESTROS - SCHEMA Concesiones
-- ================================================================================================

-- 4.1 Tipos de Actividad
INSERT INTO Concesiones.Tipo_Actividad (descripcion)
VALUES 
    ('Restaurante'),
    ('Cafetería'),
    ('Tienda de Souvenirs'),
    ('Alquiler de Equipamiento'),
    ('Servicio de Guía'),
    ('Transporte'),
    ('Hotel/Refugio'),
    ('Camping'),
    ('Servicio de Fotografía');

-- 4.2 Empresas Concesionarias (12 empresas)
INSERT INTO Concesiones.Empresa_Concesionaria (razon_social, cuit, contacto, activo)
VALUES 
    ('Gourmet Patagonia SRL', '30-12345678-9', 'contacto@gourmetpatagonia.com', 1),
    ('Naturaleza Viva SA', '30-23456789-0', 'info@naturalezaviva.com', 1),
    ('Andes Adventure Group', '30-34567890-1', 'ventas@andesadventure.com', 1),
    ('Selva Misiones SA', '30-45678901-2', 'gerencia@selvamisiones.com', 1),
    ('Austral Turismo SRL', '30-56789012-3', 'reservas@australturismo.com', 1),
    ('Lagos del Sur SA', '30-67890123-4', 'info@lagosdelsur.com', 1),
    ('Pampa Verde SRL', '30-78901234-5', 'contacto@pampaverde.com', 1),
    ('Cordillera Express SA', '30-89012345-6', 'servicios@cordilleraexpress.com', 1),
    ('Mar del Plata Services', '30-90123456-7', 'info@mardelplataservices.com', 1),
    ('Patagonia Camp SRL', '30-01234567-8', 'reservas@patagoniacamp.com', 1),
    ('Cuyo Aventura SA', '30-12345098-7', 'info@cuyoaventura.com', 1),
    ('Norte Verde SRL', '30-23456109-8', 'contacto@norteverde.com', 1);

-- 4.3 Concesiones (12 concesiones - 1 vencida, 1 próximo a vencer, 10 vigentes)
INSERT INTO Concesiones.Concesion (fecha_inicio, fecha_fin, monto_canon_mensual, id_empresa, id_tipo_actividad, id_parque)
VALUES 
    -- Parque Los Glaciares (id_parque = 1)
    ('20240101', '20261231', 150000.00, 1, 1, 1),  -- Restaurante - Vigente
    ('20250601', '20280531', 80000.00, 3, 4, 1),   -- Alquiler Equipamiento - Vigente
    
    -- Parque Iguazú (id_parque = 2)
    ('20240101', '20261231', 120000.00, 4, 1, 2),  -- Restaurante - Vigente
    ('20250315', '20280314', 90000.00, 5, 3, 2),   -- Souvenirs - Vigente
    
    -- Parque Nahuel Huapi (id_parque = 3)
    ('20230701', '20260630', 95000.00, 6, 7, 3),   -- Hotel - Casi Vence (junio 2026)
    ('20250110', '20270109', 60000.00, 2, 2, 3),   -- Cafetería - Vigente
    
    -- Parque Tierra del Fuego (id_parque = 4)
    ('20220101', '20251231', 70000.00, 8, 6, 4),   -- Transporte - VENCIDA (diciembre 2025)
    ('20250401', '20280331', 65000.00, 10, 8, 4),  -- Camping - Vigente
    
    -- Parque Talampaya (id_parque = 7)
    ('2024-02-01', '2027-01-31', 55000.00, 11, 5, 7),  -- Servicio Guía - Vigente
    ('2025-05-01', '2028-04-30', 45000.00, 12, 3, 7),  -- Souvenirs - Vigente
    
    -- Parque El Palmar (id_parque = 8)
    ('20240315', '20270314', 40000.00, 7, 9, 8),   -- Fotografía - Vigente
    ('20250701', '20280630', 50000.00, 9, 2, 8);   -- Cafetería - Vigente

-- 4.4 Pagos de Canon (con algunos pagos atrasados para demostrar deudores)
INSERT INTO Concesiones.Pago_Canon (fecha_pago, monto_pagado, mes_correspondiente, anio_correspondiente, id_concesion)
VALUES 
    -- Concesión 1 (Restaurante Los Glaciares) - Pagos al día
    ('20260105', 150000.00, 1, 2026, 1),
    ('20260203', 150000.00, 2, 2026, 1),
    ('20260302', 150000.00, 3, 2026, 1),
    ('20260402', 150000.00, 4, 2026, 1),
    ('20260504', 150000.00, 5, 2026, 1),
    
    -- Concesión 2 (Alquiler Equipamiento Los Glaciares) - Pagos al día
    ('20260605', 80000.00, 6, 2026, 2),
    
    -- Concesión 3 (Restaurante Iguazú) - Pagos con atraso
    ('20260110', 120000.00, 1, 2026, 3),
    ('20260228', 120000.00, 2, 2026, 3),  -- Atrasado
    ('20260415', 120000.00, 3, 2026, 3),  -- Atrasado
    ('20260415', 120000.00, 4, 2026, 3),  -- Pago doble
    
    -- Concesión 4 (Souvenirs Iguazú) - Pagos al día
    ('20260320', 90000.00, 3, 2026, 4),
    ('20260418', 90000.00, 4, 2026, 4),
    
    -- Concesión 5 (Hotel Nahuel Huapi) - Pagos al día
    ('20260105', 95000.00, 1, 2026, 5),
    ('20260205', 95000.00, 2, 2026, 5),
    ('20260305', 95000.00, 3, 2026, 5),
    
    -- Concesión 6 (Cafetería Nahuel Huapi) - Pagos al día
    ('20260115', 60000.00, 1, 2026, 6),
    ('20260214', 60000.00, 2, 2026, 6),
    
    -- Concesión 7 (Transporte Tierra del Fuego - VENCIDA) - Pagos incompletos
    ('20251220', 70000.00, 12, 2025, 7),  -- Último pago
    
    -- Concesión 8 (Camping Tierra del Fuego) - Pagos al día
    ('20260410', 65000.00, 4, 2026, 8),
    
    -- Concesión 9 (Servicio Guía Talampaya) - Pagos al día
    ('20260215', 55000.00, 2, 2026, 9),
    ('20260314', 55000.00, 3, 2026, 9),
    ('20260412', 55000.00, 4, 2026, 9),
    
    -- Concesión 10 (Souvenirs Talampaya) - Pagos al día
    ('20260510', 45000.00, 5, 2026, 10),
    
    -- Concesión 11 (Fotografía El Palmar) - Pagos con atraso
    ('20260325', 40000.00, 3, 2026, 11),
    ('20260520', 40000.00, 4, 2026, 11),  -- Atrasado
    
    -- Concesión 12 (Cafetería El Palmar) - Pagos al día
    ('20260710', 50000.00, 7, 2026, 12);

-- ================================================================================================
-- 5. CARGA DE VENTAS - SCHEMA Ventas
-- ================================================================================================

-- 5.1 Ventas Cabecera (30 ventas con diferentes fechas, parques y formas de pago)
INSERT INTO Ventas.Venta_Cabecera (fecha_ingreso, fecha_compra, punto_venta, total, fecha_anulacion, motivo_anulacion, id_forma_pago, id_usuario, id_parque)
VALUES 
    -- Ventas de enero
    (GETDATE(), '20260105 10:30:00', 1, 4500.00, NULL, NULL, 1, 2, 1),
    (GETDATE(), '20260108 14:15:00', 2, 12000.00, NULL, NULL, 2, 3, 2),
    (GETDATE(), '20260112 09:45:00', 1, 2400.00, NULL, NULL, 3, 2, 3),
    (GETDATE(), '20260115 11:20:00', 3, 5000.00, NULL, NULL, 1, 4, 4),
    (GETDATE(), '20260120 16:30:00', 2, 3200.00, NULL, NULL, 4, 3, 7),
    (GETDATE(), '20260122 08:50:00', 1, 8500.00, NULL, NULL, 5, 2, 9),
    (GETDATE(), '20260125 13:10:00', 3, 1500.00, NULL, NULL, 2, 4, 5),
    
    -- Ventas de febrero
    (GETDATE(), '20260202 10:00:00', 1, 6800.00, NULL, NULL, 1, 2, 1),
    (GETDATE(), '20260205 15:30:00', 2, 9500.00, NULL, NULL, 3, 3, 2),
    (GETDATE(), '20260210 09:15:00', 3, 3700.00, NULL, NULL, 6, 4, 3),
    (GETDATE(), '20260214 11:45:00', 1, 2100.00, NULL, NULL, 2, 2, 4),
    (GETDATE(), '20260218 14:00:00', 2, 7800.00, NULL, NULL, 4, 3, 7),
    (GETDATE(), '20260222 10:30:00', 3, 5600.00, NULL, NULL, 5, 4, 9),
    (GETDATE(), '20260225 16:20:00', 1, 2900.00, NULL, NULL, 1, 2, 8),
    
    -- Ventas de marzo
    (GETDATE(), '20260303 09:30:00', 2, 10200.00, NULL, NULL, 2, 3, 1),
    (GETDATE(), '20260307 14:45:00', 1, 4200.00, NULL, NULL, 3, 2, 2),
    (GETDATE(), '20260311 11:15:00', 3, 8500.00, NULL, NULL, 1, 4, 3),
    (GETDATE(), '20260315 10:00:00', 2, 3300.00, NULL, NULL, 4, 3, 4),
    (GETDATE(), '20260319 15:30:00', 1, 7200.00, NULL, NULL, 5, 2, 7),
    (GETDATE(), '20260323 12:45:00', 3, 4800.00, NULL, NULL, 2, 4, 9),
    (GETDATE(), '20260327 08:30:00', 2, 2500.00, NULL, NULL, 6, 3, 6),
    
    -- Ventas de abril
    (GETDATE(), '20260401 10:15:00', 1, 9600.00, NULL, NULL, 1, 2, 1),
    (GETDATE(), '20260404 13:50:00', 2, 5800.00, NULL, NULL, 2, 3, 2),
    (GETDATE(), '20260408 09:40:00', 3, 3100.00, NULL, NULL, 3, 4, 3),
    (GETDATE(), '20260412 11:30:00', 1, 6700.00, NULL, NULL, 4, 2, 4),
    (GETDATE(), '20260416 14:20:00', 2, 4400.00, NULL, NULL, 5, 3, 7),
    (GETDATE(), '20260420 10:10:00', 3, 8200.00, NULL, NULL, 2, 4, 9),
    (GETDATE(), '20260424 15:45:00', 1, 5300.00, NULL, NULL, 1, 2, 8),
    (GETDATE(), '20260428 09:00:00', 2, 3600.00, NULL, NULL, 3, 3, 5),
    
    -- Venta anulada (para demostrar que se puede anular)
    (GETDATE(), '20260330 11:20:00', 3, 2200.00, '20260330 11:45:00', 'Error en el importe', 1, 4, 1);

-- 5.2 Detalle de Ventas (más de 50 items para demostrar ventas completas)
INSERT INTO Ventas.Detalle_Venta (precio_final_item, cantidad, id_tipo_entrada, id_atraccion, id_venta)
VALUES 
    -- Venta 1 (Parque Los Glaciares - 4500)
    (1500.00, 2, 1, NULL, 1),  -- 2 entradas residente
    (1500.00, 1, 1, NULL, 1),  -- 1 entrada residente extra
    
    -- Venta 2 (Parque Iguazú - 12000)
    (2000.00, 3, 6, NULL, 2),  -- 3 entradas residente
    (4000.00, 1, 7, NULL, 2),  -- 1 extranjero Mercosur
    (1000.00, 2, 9, NULL, 2),  -- 2 estudiantes
    
    -- Venta 3 (Parque Nahuel Huapi - 2400)
    (1200.00, 2, 11, NULL, 3), -- 2 entradas residente
    
    -- Venta 4 (Parque Tierra del Fuego - 5000)
    (1000.00, 3, 16, NULL, 4), -- 3 entradas residente
    (2000.00, 1, 17, NULL, 4), -- 1 extranjero Mercosur
    
    -- Venta 5 (Parque Talampaya - 3200)
    (800.00, 4, 21, NULL, 5),  -- 4 entradas residente
    
    -- Venta 6 (Parque Aconcagua - 8500)
    (1800.00, 3, 26, NULL, 6), -- 3 entradas residente
    (3500.00, 1, 27, NULL, 6), -- 1 extranjero Mercosur
    (900.00, 2, 29, NULL, 6),  -- 2 estudiantes
    
    -- Venta 7 (Reserva Otamendi - 1500)
    (1500.00, 1, NULL, 17, 7), -- 1 tour Sendero Interpretativo
    
    -- Venta 8 (Los Glaciares - 6800)
    (85000.00, 1, NULL, 1, 8), -- Mini Trekking
    
    -- Venta 9 (Iguazú - 9500)
    (2000.00, 2, 6, NULL, 9),  -- 2 entradas residente
    (2500.00, 1, NULL, 5, 9),  -- Circuito Superior
    (2500.00, 1, NULL, 6, 9),  -- Circuito Inferior
    (2000.00, 1, 6, NULL, 9),  -- 1 entrada residente extra
    
    -- Venta 10 (Nahuel Huapi - 3700)
    (1200.00, 1, 11, NULL, 10), -- 1 entrada residente
    (2500.00, 1, NULL, 10, 10), -- Isla Victoria
    
    -- Venta 11 (Tierra del Fuego - 2100)
    (2100.00, 1, NULL, 13, 11), -- Tren del Fin del Mundo
    
    -- Venta 12 (Talampaya - 7800)
    (800.00, 1, 21, NULL, 12),  -- 1 entrada residente
    (1500.00, 2, NULL, 22, 12), -- Cañón de Talampaya
    (3000.00, 1, 22, NULL, 12), -- 1 extranjero no Mercosur
    (1000.00, 1, NULL, 24, 12), -- Petroglifos
    
    -- Venta 13 (Aconcagua - 5600)
    (1800.00, 2, 26, NULL, 13), -- 2 entradas residente
    (2000.00, 1, NULL, 28, 13), -- Trekking Base
    
    -- Venta 14 (El Palmar - 2900)
    (700.00, 2, NULL, 25, 14),  -- Palmeras del Palmar
    (1500.00, 1, NULL, 26, 14), -- Senderos del Palmar
    
    -- Venta 15 (Los Glaciares - 10200)
    (1500.00, 3, 1, NULL, 15),  -- 3 entradas residente
    (4500.00, 1, NULL, 2, 15),  -- Navegación
    (4200.00, 1, NULL, 1, 15),  -- Mini Trekking
    
    -- Venta 16 (Iguazú - 4200)
    (4200.00, 1, NULL, 4, 16),  -- Garganta del Diablo
    
    -- Venta 17 (Nahuel Huapi - 8500)
    (8500.00, 1, NULL, 9, 17),  -- Ascenso Cerro Catedral
    
    -- Venta 18 (Tierra del Fuego - 3300)
    (1000.00, 2, 16, NULL, 18), -- 2 entradas residente
    (1300.00, 1, NULL, 13, 18), -- Tren del Fin del Mundo
    
    -- Venta 19 (Talampaya - 7200)
    (800.00, 1, 21, NULL, 19),  -- 1 entrada residente
    (1500.00, 1, NULL, 22, 19), -- Cañón
    (1200.00, 2, NULL, 23, 19), -- Ciudad Perdida
    (2500.00, 1, 22, NULL, 19), -- 1 extranjero Mercosur
    
    -- Venta 20 (Aconcagua - 4800)
    (1800.00, 1, 26, NULL, 20), -- 1 entrada residente
    (3000.00, 1, NULL, 28, 20), -- Trekking Base
    
    -- Venta 21 (Bosques Petrificados - 2500)
    (800.00, 1, NULL, 19, 21), -- Recorrido Paleontológico
    (1700.00, 1, NULL, 19, 21), -- Mismo tour con otro guía (cupo)
    
    -- Venta 22 (Los Glaciares - 9600)
    (1500.00, 2, 1, NULL, 22),  -- 2 entradas residente
    (3300.00, 2, NULL, 3, 22),  -- Senderismo Fitz Roy
    (1500.00, 1, 1, NULL, 22),  -- 1 entrada residente extra
    (1800.00, 1, NULL, 4, 22),  -- Avistaje Cóndores
    
    -- Venta 23 (Iguazú - 5800)
    (2000.00, 1, 6, NULL, 23),  -- 1 entrada residente
    (3800.00, 1, NULL, 4, 23),  -- Garganta del Diablo
    
    -- Venta 24 (Nahuel Huapi - 3100)
    (1200.00, 1, 11, NULL, 24), -- 1 entrada residente
    (1900.00, 1, NULL, 11, 24), -- Puerto Blest
    
    -- Venta 25 (Tierra del Fuego - 6700)
    (1000.00, 2, 16, NULL, 25), -- 2 entradas residente
    (4700.00, 1, NULL, 14, 25), -- Senderismo Bahía Lapataia
    
    -- Venta 26 (Talampaya - 4400)
    (800.00, 3, 21, NULL, 26),  -- 3 entradas residente
    (2000.00, 1, NULL, 22, 26), -- Cañón
    
    -- Venta 27 (Aconcagua - 8200)
    (1800.00, 2, 26, NULL, 27), -- 2 entradas residente
    (4600.00, 1, NULL, 29, 27), -- Ascenso Campamento
    
    -- Venta 28 (El Palmar - 5300)
    (700.00, 3, NULL, 25, 28),  -- 3 Palmeras
    (3200.00, 1, NULL, 27, 28), -- Avistaje Yacarés
    
    -- Venta 29 (Otamendi - 3600)
    (500.00, 2, NULL, 16, 29),  -- Observación de Aves
    (2600.00, 1, NULL, 18, 29), -- Avistaje Carpinchos
    
    -- Venta 30 (ANULADA - Los Glaciares - 2200)
    (2200.00, 1, NULL, 4, 30);  -- Avistaje Cóndores (anulada)

