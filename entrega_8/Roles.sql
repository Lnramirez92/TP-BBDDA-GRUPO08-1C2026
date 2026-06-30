/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: Script 14 - Creacion de roles de seguridad con permisos granulares.
--
-- ROLES DEFINIDOS:
--   rol_admin      — Control total sobre la base de datos.
--   rol_consultas  — Solo puede ejecutar los SPs de reportes. Sin acceso a escritura.
--   rol_importador — Solo puede ejecutar los SPs de importacion de datos externos.
--                    Sin acceso a ventas, personal ni reportes.
--   rol_rrhh       — Gestiona guias y guardaparques. Puede descifrar DNI via SP autorizado.
--                    Sin acceso a ventas, concesiones ni reportes.
--
-- PERMISOS GRANULARES: cada rol recibe unicamente los permisos minimos necesarios
-- para cumplir su funcion. Ningun rol tiene mas permisos de los que necesita.
================================================================================================= */

USE ParquesNacionales;
GO

-- ================================================================================================
-- 1. CREAR ROLES
-- ================================================================================================
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_admin' AND type = 'R')
    CREATE ROLE rol_admin;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_consultas' AND type = 'R')
    CREATE ROLE rol_consultas;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_importador' AND type = 'R')
    CREATE ROLE rol_importador;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_rrhh' AND type = 'R')
    CREATE ROLE rol_rrhh;

PRINT 'Roles creados.';
GO

-- ================================================================================================
-- 2. rol_admin — control total sobre todos los esquemas
-- ================================================================================================
GRANT CONTROL ON SCHEMA::GestionParques TO rol_admin;
GRANT CONTROL ON SCHEMA::Ventas         TO rol_admin;
GRANT CONTROL ON SCHEMA::Personal       TO rol_admin;
GRANT CONTROL ON SCHEMA::Concesiones    TO rol_admin;
GRANT CONTROL ON SCHEMA::Reportes       TO rol_admin;
GRANT CONTROL ON SYMMETRIC KEY::Clave_simetrica   TO rol_admin;
GRANT CONTROL ON CERTIFICATE::Cert_DatosSensibles TO rol_admin;

PRINT 'Permisos rol_admin configurados.';
GO

-- ================================================================================================
-- 3. rol_consultas — solo ejecucion de SPs de reportes, sin escritura
-- ================================================================================================

-- Puede ejecutar los 5 reportes
GRANT EXECUTE ON OBJECT::Reportes.Visitas_Por_Parque         TO rol_consultas;
GRANT EXECUTE ON OBJECT::Reportes.Ingresos_Totales           TO rol_consultas;
GRANT EXECUTE ON OBJECT::Reportes.Deudores_XML               TO rol_consultas;
GRANT EXECUTE ON OBJECT::Reportes.Matriz_Visitas_Pivot       TO rol_consultas;
GRANT EXECUTE ON OBJECT::Reportes.SP_Parques_Concesiones_XML TO rol_consultas;

-- Puede consultar tablas necesarias para que los reportes funcionen internamente
GRANT SELECT ON OBJECT::GestionParques.Parque             TO rol_consultas;
GRANT SELECT ON OBJECT::GestionParques.Atraccion          TO rol_consultas;
GRANT SELECT ON OBJECT::Ventas.Venta_Cabecera             TO rol_consultas;
GRANT SELECT ON OBJECT::Ventas.Detalle_Venta              TO rol_consultas;
GRANT SELECT ON OBJECT::Concesiones.Concesion             TO rol_consultas;
GRANT SELECT ON OBJECT::Concesiones.Pago_Canon            TO rol_consultas;
GRANT SELECT ON OBJECT::Concesiones.Empresa_Concesionaria TO rol_consultas;
GRANT SELECT ON OBJECT::Concesiones.Tipo_Actividad        TO rol_consultas;

-- NO tiene EXECUTE sobre SPs de ABM ni acceso a Personal
PRINT 'Permisos rol_consultas configurados.';
GO

-- ================================================================================================
-- 4. rol_importador — puede importar cualquier dato de la base via SPs
--    Tiene EXECUTE y SELECT sobre todos los esquemas de datos.
--    NO tiene acceso a reportes ni a objetos de seguridad (clave, certificado).
-- ================================================================================================

-- Puede ejecutar SPs de importacion en todos los esquemas de datos
GRANT EXECUTE ON SCHEMA::GestionParques TO rol_importador;
GRANT EXECUTE ON SCHEMA::Personal       TO rol_importador;
GRANT EXECUTE ON SCHEMA::Concesiones    TO rol_importador;
GRANT EXECUTE ON SCHEMA::Ventas         TO rol_importador;

-- Puede hacer SELECT en todas las tablas para validar durante la importacion (evitar duplicados)
GRANT SELECT ON SCHEMA::GestionParques TO rol_importador;
GRANT SELECT ON SCHEMA::Personal       TO rol_importador;
GRANT SELECT ON SCHEMA::Concesiones    TO rol_importador;
GRANT SELECT ON SCHEMA::Ventas         TO rol_importador;

-- NO puede ejecutar reportes ni tocar objetos de seguridad
PRINT 'Permisos rol_importador configurados.';
GO

-- ================================================================================================
-- 5. rol_rrhh — gestion de personal, puede descifrar DNI via SP autorizado
-- ================================================================================================

-- Puede ejecutar todos los SPs del esquema Personal (Alta, Baja, Modificar, Asignaciones)
GRANT EXECUTE ON SCHEMA::Personal TO rol_rrhh;

-- Puede consultar atracciones y parques (necesario para asignar guias)
GRANT SELECT ON OBJECT::GestionParques.Atraccion TO rol_rrhh;
GRANT SELECT ON OBJECT::GestionParques.Parque    TO rol_rrhh;

-- Puede usar la clave para descifrar DNI a traves de los SPs autorizados
GRANT VIEW DEFINITION ON SYMMETRIC KEY::Clave_simetrica   TO rol_rrhh;
GRANT REFERENCES      ON CERTIFICATE::Cert_DatosSensibles TO rol_rrhh;

-- NO tiene acceso a Ventas, Concesiones ni Reportes
PRINT 'Permisos rol_rrhh configurados.';
GO

-- ================================================================================================
-- 6. USUARIOS DE EJEMPLO (para demostracion en coloquio)
-- ================================================================================================
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr_admin')
    CREATE LOGIN usr_admin WITH PASSWORD = 'Adm1n_P@rques!2026';

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr_consultas')
    CREATE LOGIN usr_consultas WITH PASSWORD = 'C0nsult@s!2026';

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr_importador')
    CREATE LOGIN usr_importador WITH PASSWORD = 'Imp0rt@dor!2026';

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr_rrhh')
    CREATE LOGIN usr_rrhh WITH PASSWORD = 'RRHH_P@rques!2026';
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_admin')
    CREATE USER usr_admin FOR LOGIN usr_admin;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_consultas')
    CREATE USER usr_consultas FOR LOGIN usr_consultas;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_importador')
    CREATE USER usr_importador FOR LOGIN usr_importador;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_rrhh')
    CREATE USER usr_rrhh FOR LOGIN usr_rrhh;

PRINT 'Usuarios de ejemplo creados.';
GO

-- ================================================================================================
-- 7. ASIGNAR USUARIOS A ROLES
-- ================================================================================================
ALTER ROLE rol_admin      ADD MEMBER usr_admin;
ALTER ROLE rol_consultas  ADD MEMBER usr_consultas;
ALTER ROLE rol_importador ADD MEMBER usr_importador;
ALTER ROLE rol_rrhh       ADD MEMBER usr_rrhh;

PRINT 'Usuarios asignados a sus roles.';
GO

-- ================================================================================================
-- 8. CONSULTA DE VERIFICACION: cuadro de roles y permisos
-- ================================================================================================
SELECT
    r.name                                                          AS Rol,
    p.class_desc                                                    AS Tipo_Objeto,
    COALESCE(OBJECT_SCHEMA_NAME(p.major_id), SCHEMA_NAME(p.major_id), '') AS Esquema,
    COALESCE(OBJECT_NAME(p.major_id), '')                          AS Objeto,
    p.permission_name                                               AS Permiso,
    p.state_desc                                                    AS Estado
FROM sys.database_permissions p
JOIN sys.database_principals r ON r.principal_id = p.grantee_principal_id
WHERE r.type = 'R'
  AND r.name IN ('rol_admin', 'rol_consultas', 'rol_importador', 'rol_rrhh')
ORDER BY r.name, Objeto, p.permission_name;
GO

PRINT 'Script de roles aplicado exitosamente.';
GO
