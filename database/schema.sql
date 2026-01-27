-- =====================================================
-- TECMADE - SITRAC: Script de creación de Base de Datos
-- Desarrollador: Alex
-- =====================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS tecmade_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE tecmade_db;

-- =====================================================
-- TABLA: usuarios
-- =====================================================
DROP TABLE IF EXISTS usuarios;

CREATE TABLE usuarios (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    legajo VARCHAR(50) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Índices adicionales
    INDEX idx_email (email),
    INDEX idx_legajo (legajo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: stock
-- =====================================================
DROP TABLE IF EXISTS stock;

CREATE TABLE stock (
    idstock INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    articulo VARCHAR(255) NOT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    
    -- Validación: cantidad no puede ser negativa
    CONSTRAINT chk_cantidad_positiva CHECK (cantidad >= 0),
    
    -- Índice para búsquedas por artículo
    INDEX idx_articulo (articulo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA: tokens (para autenticación Bearer)
-- =====================================================
DROP TABLE IF EXISTS tokens;

CREATE TABLE tokens (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT UNSIGNED NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    
    -- Foreign key
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    -- Índices
    INDEX idx_token (token),
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- COMENTARIOS DE TABLAS
-- =====================================================
ALTER TABLE usuarios COMMENT = 'Tabla de usuarios del sistema con autenticación';
ALTER TABLE stock COMMENT = 'Tabla de artículos de stock con cantidades';
ALTER TABLE tokens COMMENT = 'Tokens de autenticación Bearer para la API';
