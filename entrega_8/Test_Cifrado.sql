/* ================================================================================================
-- UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
-- ASIGNATURA: 3641 - Bases de Datos Aplicada
-- GRUPO: 08
-- INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
-- FECHA: Junio 2026
-- OBJETIVO/DESCRIPCION: Tests de cifrado
================================================================================================= */

USE ParquesNacionales;
GO

-- ================================================================================================
-- Verificar que la Master Key, Certificado y Clave Simetrica existen
-- ================================================================================================
SELECT 'Master Key'     AS Tipo, name FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##'
UNION ALL
SELECT 'Certificado'    AS Tipo, name FROM sys.certificates   WHERE name = 'Certificado'
UNION ALL
SELECT 'Clave Simetrica' AS Tipo, name FROM sys.symmetric_keys WHERE name = 'Clave_simetrica';
GO


-- ================================================================================================
-- Verificar que los datos sensibles están cifrados 
-- ================================================================================================
SELECT id_guia, nombre, apellido, dni AS dni_anonimizado, dni_cifrado
FROM Personal.Guia;

SELECT id_guardaparque, nombre, apellido, dni AS dni_anonimizado, dni_cifrado
FROM Personal.Guardaparque;

SELECT id_empresa, razon_social, cuit AS cuit_anonimizado, cuit_cifrado, contacto
FROM Concesiones.Empresa_Concesionaria;
GO


-- ================================================================================================
-- Descifrar DNI de un guía usando el SP autorizado
-- ================================================================================================
EXEC Personal.Guia_ObtenerDNI @id_guia = 1;
GO

-- ================================================================================================
-- Descifrar DNI de un guardaparque usando el SP autorizado
-- ================================================================================================
EXEC Personal.Guardaparque_ObtenerDNI @id_guardaparque = 1;
GO

-- ================================================================================================
-- Descifrar CUIT y contacto de una empresa concesionaria
-- ================================================================================================
EXEC Concesiones.Empresa_ObtenerCUIT  @id_empresa = 1;
GO


-- ================================================================================================
-- Intentar descifrar directamente sin abrir la clave
-- ================================================================================================
SELECT
    id_guia,
    CONVERT(NVARCHAR(10), DECRYPTBYKEY(dni_cifrado)) AS dni_intento_sin_abrir_clave
FROM Personal.Guia;
GO


-- ================================================================================================
-- Alta de un nuevo guía verificando que el DNI queda cifrado
-- ================================================================================================
EXEC Personal.Guia_Alta
    @nombre           = 'Test',
    @apellido         = 'Cifrado',
    @fecha_nacimiento = '1995-03-15',
    @dni              = '41000999',
    @especialidad     = 'Prueba de Cifrado',
    @id_titulo        = NULL;

SELECT id_guia, nombre, apellido, dni AS dni_anonimizado, dni_cifrado
FROM Personal.Guia
WHERE apellido = 'Cifrado';
GO


-- ================================================================================================
-- Alta duplicada de guía con mismo DNI
-- ================================================================================================
EXEC Personal.Guia_Alta
    @nombre           = 'Test2',
    @apellido         = 'Cifrado2',
    @fecha_nacimiento = '1996-04-20',
    @dni              = '41000999',
    @especialidad     = 'Prueba',
    @id_titulo        = NULL;
GO


-- ================================================================================================
-- Alta de empresa concesionaria
-- ================================================================================================
EXEC Concesiones.Empresa_Concesionaria_Alta
    @razon_social = 'Empresa Test Cifrado SA',
    @cuit         = '30-88888888-8',
    @contacto     = 'test@cifrado.com';

SELECT id_empresa, razon_social, cuit, contacto, cuit_cifrado
FROM Concesiones.Empresa_Concesionaria
WHERE razon_social = 'Empresa Test Cifrado SA';
GO


-- ================================================================================================
-- Alta duplicada de empresa con mismo CUIT
-- ================================================================================================
EXEC Concesiones.Empresa_Concesionaria_Alta
    @razon_social = 'Otra Empresa',
    @cuit         = '30-88888888-8',
    @contacto     = 'otro@empresa.com';
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

