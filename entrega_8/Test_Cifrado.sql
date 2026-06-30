
-- ================================================================================================
-- Verificar que la Master Key, Certificado y Clave Simetrica existen
-- RESULTADO ESPERADO: 3 filas
-- ================================================================================================
SELECT 'Master Key'      AS Tipo, name FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##'
UNION ALL
SELECT 'Certificado'     AS Tipo, name FROM sys.certificates   WHERE name = 'Cert_DatosSensibles'
UNION ALL
SELECT 'Clave Simetrica' AS Tipo, name FROM sys.symmetric_keys WHERE name = 'Clave_simetrica';
GO
 
-- ================================================================================================
-- Verificar que los datos sensibles están cifrados
-- RESULTADO ESPERADO: dni muestra '**********', dni_cifrado muestra valor binario (0x...)
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
-- RESULTADO ESPERADO: retorna el DNI en texto plano
-- ================================================================================================
EXEC Personal.Guia_ObtenerDNI @id_guia = 1;
GO
 
-- ================================================================================================
-- Descifrar DNI de un guardaparque usando el SP autorizado
-- RESULTADO ESPERADO: retorna el DNI en texto plano
-- ================================================================================================
EXEC Personal.Guardaparque_ObtenerDNI @id_guardaparque = 1;
GO
 
-- ================================================================================================
-- Descifrar CUIT de una empresa concesionaria usando el SP autorizado
-- RESULTADO ESPERADO: retorna el CUIT en texto plano, contacto en claro
-- ================================================================================================
EXEC Concesiones.Empresa_ObtenerCUIT @id_empresa = 1;
GO
 
-- ================================================================================================
-- Intentar descifrar directamente sin abrir la clave
-- RESULTADO ESPERADO: la columna descifrada devuelve NULL
-- ================================================================================================
SELECT
    id_guia,
    CONVERT(NVARCHAR(10), DECRYPTBYKEY(dni_cifrado)) AS dni_intento_sin_abrir_clave
FROM Personal.Guia;
GO
 
-- ================================================================================================
-- Alta de un nuevo guía verificando que el DNI queda cifrado
-- RESULTADO ESPERADO: dni = '**********', dni_cifrado con valor binario
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
-- RESULTADO ESPERADO: error 50100 'Ya existe un guia con ese DNI.'
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
-- Alta de empresa concesionaria verificando que el CUIT queda cifrado
-- RESULTADO ESPERADO: cuit = '***************', cuit_cifrado con valor binario
-- ================================================================================================
EXEC Concesiones.Empresa_Concesionaria_Alta
    @razon_social = 'Empresa Test Cifrado SA',
    @cuit         = '30-88888888-8',
    @contacto     = 'test@cifrado.com';
 
SELECT id_empresa, razon_social, cuit AS cuit_anonimizado, cuit_cifrado, contacto
FROM Concesiones.Empresa_Concesionaria
WHERE razon_social = 'Empresa Test Cifrado SA';
GO
 
-- ================================================================================================
-- Alta duplicada de empresa con mismo CUIT
-- RESULTADO ESPERADO: error 50500 'Ya existe una empresa con ese CUIT.'
-- ================================================================================================
EXEC Concesiones.Empresa_Concesionaria_Alta
    @razon_social = 'Otra Empresa',
    @cuit         = '30-88888888-8',
    @contacto     = 'otro@empresa.com';
GO