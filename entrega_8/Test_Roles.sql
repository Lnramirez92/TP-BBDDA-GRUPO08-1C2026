/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: Tests de roles
================================================================================================= */

USE ParquesNacionales;
GO

-- ================================================================================================
-- Verificar que los roles existen en la BD
-- ================================================================================================
SELECT name AS Rol, type_desc
FROM sys.database_principals
WHERE name IN ('rol_admin','rol_cajero','rol_importador','rol_consultas','rol_rrhh','rol_concesiones')
  AND type = 'R';
GO

-- ================================================================================================
-- Verificar asignación de usuarios a roles
-- ================================================================================================
SELECT
    r.name AS Rol,
    m.name AS Usuario
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name IN ('rol_admin','rol_cajero','rol_importador','rol_consultas','rol_rrhh','rol_concesiones')
ORDER BY r.name;
GO
