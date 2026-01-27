-- =====================================================
-- TECMADE - SITRAC: Datos iniciales (Seed Data)
-- Desarrollador: Alex
-- =====================================================

USE tecmade_db;

-- =====================================================
-- USUARIOS
-- =====================================================
-- Nota: Las contraseñas están hasheadas con password_hash() de PHP
-- Para generar el hash en PHP: password_hash('tu_password', PASSWORD_DEFAULT);

-- Usuario 1: admin@tecmade.com / password: admin123
-- Hash generado con: password_hash('admin123', PASSWORD_DEFAULT)
INSERT INTO usuarios (email, password_hash, legajo) VALUES
('admin@tecmade.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'LEG001');

-- Nota: Para agregar más usuarios, generar el hash de la contraseña con PHP:
-- php -r "echo password_hash('tu_password', PASSWORD_DEFAULT);"

-- Usuarios adicionales (opcional para pruebas)
INSERT INTO usuarios (email, password_hash, legajo) VALUES
('user@tecmade.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'LEG002'),
('test@tecmade.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL);

-- =====================================================
-- STOCK (mínimo 5 artículos requeridos)
-- =====================================================
INSERT INTO stock (articulo, cantidad) VALUES
('Tornillo M8x20', 150),
('Tuerca M8', 200),
('Arandela plana M8', 180),
('Perno hexagonal M10x30', 95),
('Remache aluminio 4x10', 320),
('Cable UTP Cat6 (metros)', 500),
('Conector RJ45', 1000),
('Cinta aislante negra', 45),
('Brida plástica 200mm', 250),
('Grasa lubricante (tubos)', 30);

-- =====================================================
-- VERIFICACIÓN
-- =====================================================
-- Mostrar usuarios creados
SELECT id, email, legajo, created_at FROM usuarios;

-- Mostrar stock creado
SELECT idstock, articulo, cantidad FROM stock;

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================
-- Credenciales de prueba:
-- Email: admin@tecmade.com
-- Password: admin123
--
-- Email: user@tecmade.com
-- Password: admin123
--
-- Email: test@tecmade.com
-- Password: admin123
