/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño,Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: Script 02 - Generacion de todas las tablas y restricciones (Constraints).
================================================================================================= */


USE ParquesNacionales;
GO

/* ================================================================================================
--SCHEMA GestionParques
================================================================================================= */
DROP TABLE IF EXISTS GestionParques.Tipo_Parque;
CREATE TABLE GestionParques.Tipo_Parque (
	id_tipo_parque INT IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(40) NOT NULL
);

DROP TABLE IF EXISTS GestionParques.Parque;
CREATE TABLE GestionParques.Parque (
	id_parque INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	ubicacion VARCHAR(50) NOT NULL,
	superficie DECIMAL(10,2) NOT NULL,
	id_tipo_parque INT NOT NULL,
	activo BIT DEFAULT 1,

	CONSTRAINT FK_Parque_Tipo_Parque FOREIGN KEY (id_tipo_parque) REFERENCES GestionParques.Tipo_Parque(id_tipo_parque)
);

DROP TABLE IF EXISTS GestionParques.Atraccion;
CREATE TABLE GestionParques.Atraccion (
	id_atraccion INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	costo DECIMAL(10,2) NOT NULL, --GRATIS SI COSTO NULL o CERO ?
	duracion_minutos SMALLINT NOT NULL,
	cupo_maximo SMALLINT NOT NULL,
	tipo_atraccion VARCHAR(15) NOT NULL,
	id_parque INT NOT NULL,
	activo BIT DEFAULT 1,	
	
	CONSTRAINT FK_Atraccion_Parque FOREIGN KEY (id_parque) REFERENCES GestionParques.Parque(id_parque),	
	CONSTRAINT CK_Atraccion_Duracion CHECK (duracion_minutos >= 0),
	CONSTRAINT CK_Atraccion_Cupo CHECK (cupo_maximo >= 0),
	CONSTRAINT CK_Atraccion_Tipo CHECK (tipo_atraccion IN ('Tour', 'Atraccion'))
);


/* ================================================================================================
--SCHEMA Ventas
================================================================================================= */
DROP TABLE IF EXISTS Ventas.Tipo_Visitante;
CREATE TABLE Ventas.Tipo_Visitante (
	id_tipo_visitante INT IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(30) NOT NULL,
	activo BIT DEFAULT 1
);

DROP TABLE IF EXISTS Ventas.Tipo_Entrada;
CREATE TABLE Ventas.Tipo_Entrada (
	id_tipo_entrada INT IDENTITY(1,1) PRIMARY KEY,
	id_tipo_visitante INT NOT NULL,
	precio DECIMAL(10,2) NOT NULL,
	fecha_desde DATE NOT NULL,
	fecha_hasta DATE NOT NULL,
	id_parque INT NOT NULL,
	activo BIT DEFAULT 1,

	CONSTRAINT FK_Tipo_Entrada_Tipo_Visitante FOREIGN KEY (id_tipo_visitante) REFERENCES Ventas.Tipo_Visitante(id_tipo_visitante),
	CONSTRAINT FK_Tipo_Entrada_Parque FOREIGN KEY (id_parque) REFERENCES GestionParques.Parque(id_parque)
);

DROP TABLE IF EXISTS Ventas.Forma_Pago;
CREATE TABLE Ventas.Forma_Pago (
	id_forma_pago INT IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(30) NOT NULL
);

DROP TABLE IF EXISTS Ventas.Usuario;
CREATE TABLE Ventas.Usuario (
	id_usuario INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(30) NOT NULL,
	rol VARCHAR(30),
	activo BIT DEFAULT 1
);

DROP TABLE IF EXISTS Ventas.Venta_Cabecera;
CREATE TABLE Ventas.Venta_Cabecera (
	id_venta INT IDENTITY(1,1) PRIMARY KEY,
	fecha_ingreso DATETIME NOT NULL,
	fecha_compra DATETIME NOT NULL,
	punto_venta INT NOT NULL,
	total DECIMAL(10,2) NOT NULL,
	fecha_anulacion DATETIME,
    motivo_anulacion VARCHAR(200),
	id_forma_pago INT NOT NULL,
	id_usuario INT NOT NULL,
	id_parque INT NOT NULL,

	CONSTRAINT FK_Venta_Cabecera_Forma_Pago FOREIGN KEY (id_forma_pago) REFERENCES Ventas.Forma_Pago(id_forma_pago),
	CONSTRAINT FK_Venta_Cabecera_Usuario FOREIGN KEY (id_usuario) REFERENCES Ventas.Usuario(id_usuario),
	CONSTRAINT FK_Venta_Cabecera_Parque FOREIGN KEY (id_parque) REFERENCES GestionParques.Parque(id_parque)
);

DROP TABLE IF EXISTS Ventas.Detalle_Venta;
CREATE TABLE Ventas.Detalle_Venta (
	id_detalle_venta INT IDENTITY(1,1) PRIMARY KEY,
	precio_final_item DECIMAL(10,2) NOT NULL,
	cantidad SMALLINT NOT NULL,
	id_tipo_entrada INT, 
	id_atraccion INT,    
	id_venta INT NOT NULL,

	CONSTRAINT FK_Detalle_Venta_Cabecera FOREIGN KEY (id_venta) REFERENCES Ventas.Venta_Cabecera(id_venta),
	CONSTRAINT FK_Detalle_Venta_Entrada FOREIGN KEY (id_tipo_entrada) REFERENCES Ventas.Tipo_Entrada(id_tipo_entrada),
	CONSTRAINT FK_Detalle_Venta_Atraccion FOREIGN KEY (id_atraccion) REFERENCES GestionParques.Atraccion(id_atraccion),
	CONSTRAINT CK_Detalle_Venta_Cantidad CHECK (cantidad > 0),

	CONSTRAINT CK_Detalle_Venta_Item
		CHECK (
			(id_tipo_entrada IS NOT NULL AND id_atraccion IS NULL)
			OR
			(id_tipo_entrada IS NULL AND id_atraccion IS NOT NULL)
)
);
GO

IF TYPE_ID('Ventas.TVP_Detalle_Venta') IS NOT NULL
    DROP TYPE Ventas.TVP_Detalle_Venta;
GO

CREATE TYPE Ventas.TVP_Detalle_Venta AS TABLE
(
    id_tipo_entrada INT NULL,
    id_atraccion INT NULL,
    cantidad SMALLINT NOT NULL,
    precio_final_item DECIMAL(10,2) NOT NULL
);
GO

/* ================================================================================================
--SCHEMA Personal
================================================================================================= */
DROP TABLE IF EXISTS Personal.Titulo;
CREATE TABLE Personal.Titulo (
	id_titulo INT IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(60) NOT NULL
);

DROP TABLE IF EXISTS Personal.Guia;
CREATE TABLE Personal.Guia (
	id_guia INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	apellido VARCHAR(100) NOT NULL,
	fecha_nacimiento DATE NOT NULL,
	dni CHAR(10) NOT NULL UNIQUE, --VALIDAR QUE NO PONGA LETRAS
	especialidad VARCHAR(100) NOT NULL,
	id_titulo INT,
	activo BIT DEFAULT 1,

	CONSTRAINT FK_Guia_Titulo FOREIGN KEY (id_titulo) REFERENCES Personal.Titulo (id_titulo)
);

DROP TABLE IF EXISTS Personal.Habilitacion_Guia;
CREATE TABLE Personal.Habilitacion_Guia (
	id_habilitacion INT IDENTITY(1,1) PRIMARY KEY,
	nro_matricula VARCHAR(20) NOT NULL,
	fecha_emision DATE NOT NULL,
	estado VARCHAR(15) NOT NULL,
	id_guia INT NOT NULL,

	CONSTRAINT FK_Habilitacion_Guia_Guia FOREIGN KEY (id_guia) REFERENCES Personal.Guia (id_guia),
	CONSTRAINT CK_Habilitacion_Guia_Estado CHECK (estado IN ('Activa', 'Inactiva'))
);

DROP TABLE IF EXISTS Personal.Asignacion_Guia;
CREATE TABLE Personal.Asignacion_Guia (
	id_asignacion INT IDENTITY(1,1) PRIMARY KEY,
	id_atraccion INT NOT NULL,
	id_guia INT NOT NULL,
	fecha_inicio DATE NOT NULL,
	fecha_egreso DATE,

	CONSTRAINT FK_Asignacion_Guia_Guia FOREIGN KEY (id_guia) REFERENCES Personal.Guia (id_guia),
	CONSTRAINT FK_Asignacion_Guia_Atraccion FOREIGN KEY (id_atraccion) REFERENCES GestionParques.Atraccion (id_atraccion)
);

DROP TABLE IF EXISTS Personal.Guardaparque;
CREATE TABLE Personal.Guardaparque (
	id_guardaparque INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	dni CHAR(10) NOT NULL UNIQUE,
	fecha_nacimiento DATE NOT NULL,
	activo BIT DEFAULT 1
);

DROP TABLE IF EXISTS Personal.Asignacion_Guardaparque;
CREATE TABLE Personal.Asignacion_Guardaparque (
	id_asignacion INT IDENTITY(1,1) PRIMARY KEY,
	fecha_ingreso DATE NOT NULL,
	fecha_egreso DATE,
	motivo_egreso VARCHAR(100),
	id_guardaparque INT NOT NULL,
	id_parque INT NOT NULL,

	CONSTRAINT FK_Asinacion_Guardaparque_Guardaparque FOREIGN KEY (id_guardaparque) REFERENCES Personal.Guardaparque (id_guardaparque),
	CONSTRAINT FK_Asignacion_Guardaparque_Parque FOREIGN KEY (id_parque) REFERENCES GestionParques.Parque (id_parque)
);


/* ================================================================================================
--SCHEMA Concesiones
================================================================================================= */
DROP TABLE IF EXISTS Concesiones.Tipo_Actividad;
CREATE TABLE Concesiones.Tipo_Actividad (
	id_tipo_actividad INT IDENTITY(1,1) PRIMARY KEY,
	descripcion VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS Concesiones.Empresa_Concesionaria;
CREATE TABLE Concesiones.Empresa_Concesionaria (
	id_empresa INT IDENTITY(1,1) PRIMARY KEY,
	razon_social VARCHAR(50) NOT NULL,
	cuit VARCHAR(15) NOT NULL UNIQUE,
	contacto VARCHAR(50) NOT NULL,
	activo BIT DEFAULT 1
);

DROP TABLE IF EXISTS Concesiones.Concesion;
CREATE TABLE Concesiones.Concesion (
	id_concesion INT IDENTITY(1,1) PRIMARY KEY,
	fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,
	monto_canon_mensual DECIMAL(10,2) NOT NULL,
	id_empresa INT NOT NULL,
	id_tipo_actividad INT NOT NULL,
	id_parque INT NOT NULL,

	CONSTRAINT FK_Concesion_Empresa FOREIGN KEY (id_empresa) REFERENCES Concesiones.Empresa_Concesionaria (id_empresa),
	CONSTRAINT FK_Concesion_Tipo_Actividad FOREIGN KEY (id_tipo_actividad) REFERENCES Concesiones.Tipo_Actividad (id_tipo_actividad),
	CONSTRAINT FK_Concesion_Parque FOREIGN KEY (id_parque) REFERENCES GestionParques.Parque (id_parque)
);

DROP TABLE IF EXISTS Concesiones.Pago_Canon;
CREATE TABLE Concesiones.Pago_Canon (
	id_pago INT IDENTITY(1,1) PRIMARY KEY,
	fecha_pago DATETIME NOT NULL,
	monto_pagado DECIMAL NOT NULL,
	mes_correspondiente TINYINT NOT NULL,
	anio_correspondiente SMALLINT NOT NULL,
	id_concesion INT NOT NULL,

	CONSTRAINT FK_Pago_Canon_Concesion FOREIGN KEY (id_concesion) REFERENCES Concesiones.Concesion (id_concesion),
	CONSTRAINT CK_Pago_Canon_Mes CHECK (mes_correspondiente BETWEEN 1 AND 12)
);