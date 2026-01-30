-- ============================================================================
-- TECMADE - SITRAC: Sistema de Gestión de Embalado (2 puntos)
-- Evaluación Técnica - Desarrollador Android
-- @author Alex
-- ============================================================================
-- Descripción: Sistema para gestionar series (productos individuales) y bultos
-- (cajas que contienen series u otros bultos) con estructura recursiva.
-- ============================================================================

-- Usar la base de datos
USE tecmade_db;

-- ============================================================================
-- 1. DDL - CREACIÓN DE TABLAS
-- ============================================================================

-- Limpiar tablas existentes (en orden por dependencias)
DROP TABLE IF EXISTS historial_movimientos;
DROP TABLE IF EXISTS bultos_bultos;
DROP TABLE IF EXISTS series_bultos;
DROP TABLE IF EXISTS bultos;
DROP TABLE IF EXISTS series;

-- ---------------------------------------------------------------------------
-- Tabla series: Productos individuales con código AAA999
-- ---------------------------------------------------------------------------
CREATE TABLE series (
    id_serie INT AUTO_INCREMENT PRIMARY KEY,
    serie VARCHAR(6) NOT NULL UNIQUE COMMENT 'Formato: AAA999 (3 letras + 3 números)',
    descripcion VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_serie (serie)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Tabla bultos: Cajas con etiqueta 999AAA
-- ---------------------------------------------------------------------------
CREATE TABLE bultos (
    id_bulto INT AUTO_INCREMENT PRIMARY KEY,
    etiqueta VARCHAR(6) NOT NULL UNIQUE COMMENT 'Formato: 999AAA (3 números + 3 letras)',
    descripcion VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_etiqueta (etiqueta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Tabla series_bultos: Relación entre series y bultos
-- ---------------------------------------------------------------------------
CREATE TABLE series_bultos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_serie INT NOT NULL,
    id_bulto INT NOT NULL,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_serie) REFERENCES series(id_serie) ON DELETE CASCADE,
    FOREIGN KEY (id_bulto) REFERENCES bultos(id_bulto) ON DELETE CASCADE,
    UNIQUE KEY uk_serie_bulto (id_serie, id_bulto),
    INDEX idx_serie (id_serie),
    INDEX idx_bulto (id_bulto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Tabla bultos_bultos: Relación recursiva (bultos dentro de bultos)
-- ---------------------------------------------------------------------------
CREATE TABLE bultos_bultos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_bulto_contenedor INT NOT NULL COMMENT 'Bulto que contiene',
    id_bulto_contenido INT NOT NULL COMMENT 'Bulto contenido',
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_bulto_contenedor) REFERENCES bultos(id_bulto) ON DELETE CASCADE,
    FOREIGN KEY (id_bulto_contenido) REFERENCES bultos(id_bulto) ON DELETE CASCADE,
    UNIQUE KEY uk_contenedor_contenido (id_bulto_contenedor, id_bulto_contenido),
    CHECK (id_bulto_contenedor != id_bulto_contenido),
    INDEX idx_contenedor (id_bulto_contenedor),
    INDEX idx_contenido (id_bulto_contenido)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Tabla historial_movimientos: Log de cambios (para trigger)
-- ---------------------------------------------------------------------------
CREATE TABLE historial_movimientos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_movimiento ENUM('SERIE_ASIGNADA', 'SERIE_MIGRADA', 'SERIE_ELIMINADA', 'BULTO_ASIGNADO', 'BULTO_ELIMINADO') NOT NULL,
    id_serie INT NULL,
    id_bulto_origen INT NULL,
    id_bulto_destino INT NULL,
    descripcion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_fecha (fecha),
    INDEX idx_tipo (tipo_movimiento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. FUNCIONES PARA GENERACIÓN AUTONUMÉRICA
-- ============================================================================

DELIMITER //

-- ---------------------------------------------------------------------------
-- Función: GenerarSerie - Genera código AAA999 autonumérico
-- ---------------------------------------------------------------------------
-- Capacidad: Hasta 1,000,000 de series (AAA000 a ZZZ999)
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS GenerarSerie//

CREATE FUNCTION GenerarSerie() RETURNS VARCHAR(6)
DETERMINISTIC
BEGIN
    DECLARE v_contador INT;
    DECLARE v_letras CHAR(3);
    DECLARE v_numeros CHAR(3);
    DECLARE v_serie VARCHAR(6);
    DECLARE v_existe INT;
    
    -- Obtener el contador actual
    SELECT COUNT(*) INTO v_contador FROM series;
    
    -- Calcular letras (parte AAA)
    SET v_letras = CONCAT(
        CHAR(65 + FLOOR(v_contador / 26000) % 26),
        CHAR(65 + FLOOR(v_contador / 1000) % 26),
        CHAR(65 + v_contador % 26)
    );
    
    -- Calcular números (parte 999)
    SET v_numeros = LPAD(FLOOR(v_contador / 26) % 1000, 3, '0');
    
    -- Generar serie
    SET v_serie = CONCAT(v_letras, v_numeros);
    
    -- Verificar si existe, si existe, incrementar
    SELECT COUNT(*) INTO v_existe FROM series WHERE serie = v_serie;
    
    WHILE v_existe > 0 DO
        SET v_contador = v_contador + 1;
        SET v_letras = CONCAT(
            CHAR(65 + FLOOR(v_contador / 26000) % 26),
            CHAR(65 + FLOOR(v_contador / 1000) % 26),
            CHAR(65 + v_contador % 26)
        );
        SET v_numeros = LPAD(FLOOR(v_contador / 26) % 1000, 3, '0');
        SET v_serie = CONCAT(v_letras, v_numeros);
        SELECT COUNT(*) INTO v_existe FROM series WHERE serie = v_serie;
    END WHILE;
    
    RETURN v_serie;
END//

-- ---------------------------------------------------------------------------
-- Función: GenerarEtiquetaBulto - Genera código 999AAA autonumérico
-- ---------------------------------------------------------------------------
-- Capacidad: Hasta 1,000,000 de bultos (000AAA a 999ZZZ)
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS GenerarEtiquetaBulto//

CREATE FUNCTION GenerarEtiquetaBulto() RETURNS VARCHAR(6)
DETERMINISTIC
BEGIN
    DECLARE v_contador INT;
    DECLARE v_numeros CHAR(3);
    DECLARE v_letras CHAR(3);
    DECLARE v_etiqueta VARCHAR(6);
    DECLARE v_existe INT;
    
    -- Obtener el contador actual
    SELECT COUNT(*) INTO v_contador FROM bultos;
    
    -- Calcular números (parte 999)
    SET v_numeros = LPAD(v_contador % 1000, 3, '0');
    
    -- Calcular letras (parte AAA)
    SET v_letras = CONCAT(
        CHAR(65 + FLOOR(v_contador / 26000) % 26),
        CHAR(65 + FLOOR(v_contador / 1000) % 26),
        CHAR(65 + FLOOR(v_contador / 26) % 26)
    );
    
    -- Generar etiqueta
    SET v_etiqueta = CONCAT(v_numeros, v_letras);
    
    -- Verificar si existe, si existe, incrementar
    SELECT COUNT(*) INTO v_existe FROM bultos WHERE etiqueta = v_etiqueta;
    
    WHILE v_existe > 0 DO
        SET v_contador = v_contador + 1;
        SET v_numeros = LPAD(v_contador % 1000, 3, '0');
        SET v_letras = CONCAT(
            CHAR(65 + FLOOR(v_contador / 26000) % 26),
            CHAR(65 + FLOOR(v_contador / 1000) % 26),
            CHAR(65 + FLOOR(v_contador / 26) % 26)
        );
        SET v_etiqueta = CONCAT(v_numeros, v_letras);
        SELECT COUNT(*) INTO v_existe FROM bultos WHERE etiqueta = v_etiqueta;
    END WHILE;
    
    RETURN v_etiqueta;
END//

DELIMITER ;

-- ============================================================================
-- 3. PROCEDIMIENTOS ALMACENADOS - ALTAS
-- ============================================================================

DELIMITER //

-- ---------------------------------------------------------------------------
-- Procedimiento: CrearSerie - Alta de serie
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS CrearSerie//

CREATE PROCEDURE CrearSerie(
    IN p_descripcion VARCHAR(255),
    OUT p_id_serie INT,
    OUT p_serie VARCHAR(6)
)
BEGIN
    -- Generar código de serie
    SET p_serie = GenerarSerie();
    
    -- Insertar serie
    INSERT INTO series (serie, descripcion)
    VALUES (p_serie, p_descripcion);
    
    -- Obtener ID
    SET p_id_serie = LAST_INSERT_ID();
    
    SELECT p_id_serie AS id_serie, p_serie AS serie, 'Serie creada exitosamente' AS mensaje;
END//

-- ---------------------------------------------------------------------------
-- Procedimiento: CrearBulto - Alta de bulto
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS CrearBulto//

CREATE PROCEDURE CrearBulto(
    IN p_descripcion VARCHAR(255),
    OUT p_id_bulto INT,
    OUT p_etiqueta VARCHAR(6)
)
BEGIN
    -- Generar etiqueta
    SET p_etiqueta = GenerarEtiquetaBulto();
    
    -- Insertar bulto
    INSERT INTO bultos (etiqueta, descripcion)
    VALUES (p_etiqueta, p_descripcion);
    
    -- Obtener ID
    SET p_id_bulto = LAST_INSERT_ID();
    
    SELECT p_id_bulto AS id_bulto, p_etiqueta AS etiqueta, 'Bulto creado exitosamente' AS mensaje;
END//

DELIMITER ;

-- ============================================================================
-- 4. PROCEDIMIENTOS ALMACENADOS - ASIGNACIONES
-- ============================================================================

DELIMITER //

-- ---------------------------------------------------------------------------
-- Procedimiento: AsignarSerieABulto - Asignar serie a bulto
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS AsignarSerieABulto//

CREATE PROCEDURE AsignarSerieABulto(
    IN p_id_serie INT,
    IN p_id_bulto INT
)
BEGIN
    DECLARE v_existe_serie INT;
    DECLARE v_existe_bulto INT;
    DECLARE v_ya_asignada INT;
    
    -- Verificar que la serie existe
    SELECT COUNT(*) INTO v_existe_serie FROM series WHERE id_serie = p_id_serie;
    IF v_existe_serie = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La serie no existe';
    END IF;
    
    -- Verificar que el bulto existe
    SELECT COUNT(*) INTO v_existe_bulto FROM bultos WHERE id_bulto = p_id_bulto;
    IF v_existe_bulto = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El bulto no existe';
    END IF;
    
    -- Verificar si ya está asignada a este bulto
    SELECT COUNT(*) INTO v_ya_asignada 
    FROM series_bultos 
    WHERE id_serie = p_id_serie AND id_bulto = p_id_bulto;
    
    IF v_ya_asignada > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La serie ya está asignada a este bulto';
    END IF;
    
    -- Insertar asignación
    INSERT INTO series_bultos (id_serie, id_bulto)
    VALUES (p_id_serie, p_id_bulto);
    
    SELECT 'Serie asignada al bulto exitosamente' AS mensaje;
END//

-- ---------------------------------------------------------------------------
-- Procedimiento: AsignarBultoABulto - Asignar bulto dentro de otro bulto
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS AsignarBultoABulto//

CREATE PROCEDURE AsignarBultoABulto(
    IN p_id_bulto_contenedor INT,
    IN p_id_bulto_contenido INT
)
BEGIN
    DECLARE v_existe_contenedor INT;
    DECLARE v_existe_contenido INT;
    DECLARE v_ya_asignado INT;
    
    -- Verificar que no sea el mismo bulto
    IF p_id_bulto_contenedor = p_id_bulto_contenido THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un bulto no puede contenerse a sí mismo';
    END IF;
    
    -- Verificar que ambos bultos existen
    SELECT COUNT(*) INTO v_existe_contenedor FROM bultos WHERE id_bulto = p_id_bulto_contenedor;
    SELECT COUNT(*) INTO v_existe_contenido FROM bultos WHERE id_bulto = p_id_bulto_contenido;
    
    IF v_existe_contenedor = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El bulto contenedor no existe';
    END IF;
    
    IF v_existe_contenido = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El bulto contenido no existe';
    END IF;
    
    -- Verificar si ya está asignado
    SELECT COUNT(*) INTO v_ya_asignado 
    FROM bultos_bultos 
    WHERE id_bulto_contenedor = p_id_bulto_contenedor 
      AND id_bulto_contenido = p_id_bulto_contenido;
    
    IF v_ya_asignado > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El bulto ya está asignado';
    END IF;
    
    -- Insertar asignación
    INSERT INTO bultos_bultos (id_bulto_contenedor, id_bulto_contenido)
    VALUES (p_id_bulto_contenedor, p_id_bulto_contenido);
    
    SELECT 'Bulto asignado exitosamente' AS mensaje;
END//

DELIMITER ;

-- ============================================================================
-- 5. PROCEDIMIENTOS ALMACENADOS - MIGRACIONES Y ELIMINACIONES
-- ============================================================================

DELIMITER //

-- ---------------------------------------------------------------------------
-- Procedimiento: MigrarSerie - Mover serie de un bulto a otro
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS MigrarSerie//

CREATE PROCEDURE MigrarSerie(
    IN p_id_serie INT,
    IN p_id_bulto_origen INT,
    IN p_id_bulto_destino INT
)
BEGIN
    DECLARE v_existe_asignacion INT;
    
    -- Verificar que la serie está asignada al bulto origen
    SELECT COUNT(*) INTO v_existe_asignacion 
    FROM series_bultos 
    WHERE id_serie = p_id_serie AND id_bulto = p_id_bulto_origen;
    
    IF v_existe_asignacion = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La serie no está asignada al bulto origen';
    END IF;
    
    -- Eliminar asignación anterior
    DELETE FROM series_bultos 
    WHERE id_serie = p_id_serie AND id_bulto = p_id_bulto_origen;
    
    -- Crear nueva asignación
    INSERT INTO series_bultos (id_serie, id_bulto)
    VALUES (p_id_serie, p_id_bulto_destino);
    
    SELECT 'Serie migrada exitosamente' AS mensaje;
END//

-- ---------------------------------------------------------------------------
-- Procedimiento: EliminarAsignacionSerie - Quitar serie de un bulto
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS EliminarAsignacionSerie//

CREATE PROCEDURE EliminarAsignacionSerie(
    IN p_id_serie INT,
    IN p_id_bulto INT
)
BEGIN
    DECLARE v_existe_asignacion INT;
    
    -- Verificar que existe la asignación
    SELECT COUNT(*) INTO v_existe_asignacion 
    FROM series_bultos 
    WHERE id_serie = p_id_serie AND id_bulto = p_id_bulto;
    
    IF v_existe_asignacion = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La asignación no existe';
    END IF;
    
    -- Eliminar asignación
    DELETE FROM series_bultos 
    WHERE id_serie = p_id_serie AND id_bulto = p_id_bulto;
    
    SELECT 'Asignación eliminada exitosamente' AS mensaje;
END//

-- ---------------------------------------------------------------------------
-- Procedimiento: EliminarAsignacionBulto - Quitar bulto de otro bulto
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS EliminarAsignacionBulto//

CREATE PROCEDURE EliminarAsignacionBulto(
    IN p_id_bulto_contenedor INT,
    IN p_id_bulto_contenido INT
)
BEGIN
    DECLARE v_existe_asignacion INT;
    
    -- Verificar que existe la asignación
    SELECT COUNT(*) INTO v_existe_asignacion 
    FROM bultos_bultos 
    WHERE id_bulto_contenedor = p_id_bulto_contenedor 
      AND id_bulto_contenido = p_id_bulto_contenido;
    
    IF v_existe_asignacion = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La asignación no existe';
    END IF;
    
    -- Eliminar asignación
    DELETE FROM bultos_bultos 
    WHERE id_bulto_contenedor = p_id_bulto_contenedor 
      AND id_bulto_contenido = p_id_bulto_contenido;
    
    SELECT 'Asignación de bulto eliminada exitosamente' AS mensaje;
END//

-- ---------------------------------------------------------------------------
-- Procedimiento: ObtenerUltimoBultoDeSerie - Buscar dónde está una serie
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS ObtenerUltimoBultoDeSerie//

CREATE PROCEDURE ObtenerUltimoBultoDeSerie(IN p_id_serie INT)
BEGIN
    SELECT 
        s.id_serie,
        s.serie,
        b.id_bulto,
        b.etiqueta AS etiqueta_bulto,
        b.descripcion AS descripcion_bulto,
        sb.fecha_asignacion
    FROM series s
    INNER JOIN series_bultos sb ON s.id_serie = sb.id_serie
    INNER JOIN bultos b ON sb.id_bulto = b.id_bulto
    WHERE s.id_serie = p_id_serie
    ORDER BY sb.fecha_asignacion DESC
    LIMIT 1;
END//

DELIMITER ;

-- ============================================================================
-- 6. TRIGGERS - HISTORIAL DE MOVIMIENTOS
-- ============================================================================

DELIMITER //

-- Trigger: Después de asignar serie a bulto
DROP TRIGGER IF EXISTS trg_serie_asignada//

CREATE TRIGGER trg_serie_asignada
AFTER INSERT ON series_bultos
FOR EACH ROW
BEGIN
    INSERT INTO historial_movimientos (
        tipo_movimiento, id_serie, id_bulto_destino, descripcion
    ) VALUES (
        'SERIE_ASIGNADA', 
        NEW.id_serie, 
        NEW.id_bulto, 
        CONCAT('Serie asignada al bulto ', NEW.id_bulto)
    );
END//

-- Trigger: Después de eliminar asignación de serie
DROP TRIGGER IF EXISTS trg_serie_eliminada//

CREATE TRIGGER trg_serie_eliminada
AFTER DELETE ON series_bultos
FOR EACH ROW
BEGIN
    INSERT INTO historial_movimientos (
        tipo_movimiento, id_serie, id_bulto_origen, descripcion
    ) VALUES (
        'SERIE_ELIMINADA', 
        OLD.id_serie, 
        OLD.id_bulto, 
        CONCAT('Serie eliminada del bulto ', OLD.id_bulto)
    );
END//

-- Trigger: Después de asignar bulto a bulto
DROP TRIGGER IF EXISTS trg_bulto_asignado//

CREATE TRIGGER trg_bulto_asignado
AFTER INSERT ON bultos_bultos
FOR EACH ROW
BEGIN
    INSERT INTO historial_movimientos (
        tipo_movimiento, id_bulto_origen, id_bulto_destino, descripcion
    ) VALUES (
        'BULTO_ASIGNADO', 
        NEW.id_bulto_contenido, 
        NEW.id_bulto_contenedor, 
        CONCAT('Bulto ', NEW.id_bulto_contenido, ' asignado a bulto ', NEW.id_bulto_contenedor)
    );
END//

-- Trigger: Después de eliminar asignación de bulto
DROP TRIGGER IF EXISTS trg_bulto_eliminado//

CREATE TRIGGER trg_bulto_eliminado
AFTER DELETE ON bultos_bultos
FOR EACH ROW
BEGIN
    INSERT INTO historial_movimientos (
        tipo_movimiento, id_bulto_origen, id_bulto_destino, descripcion
    ) VALUES (
        'BULTO_ELIMINADO', 
        OLD.id_bulto_contenido, 
        OLD.id_bulto_contenedor, 
        CONCAT('Bulto ', OLD.id_bulto_contenido, ' eliminado del bulto ', OLD.id_bulto_contenedor)
    );
END//

DELIMITER ;

-- ============================================================================
-- 7. CONSULTAS RECURSIVAS
-- ============================================================================

DELIMITER //

-- ---------------------------------------------------------------------------
-- Procedimiento: ObtenerSeriesEnBulto - Ver todas las series en un bulto
-- ---------------------------------------------------------------------------
-- Incluye series directas y series en bultos contenidos (recursivo)
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS ObtenerSeriesEnBulto//

CREATE PROCEDURE ObtenerSeriesEnBulto(IN p_id_bulto INT)
BEGIN
    -- Series directamente en el bulto
    SELECT 
        s.id_serie,
        s.serie,
        s.descripcion,
        'Directa' AS ubicacion,
        p_id_bulto AS id_bulto_contenedor,
        0 AS nivel
    FROM series s
    INNER JOIN series_bultos sb ON s.id_serie = sb.id_serie
    WHERE sb.id_bulto = p_id_bulto
    
    UNION ALL
    
    -- Series en bultos contenidos (un nivel)
    SELECT 
        s.id_serie,
        s.serie,
        s.descripcion,
        CONCAT('En bulto ', b_interno.etiqueta) AS ubicacion,
        bb.id_bulto_contenido AS id_bulto_contenedor,
        1 AS nivel
    FROM bultos_bultos bb
    INNER JOIN series_bultos sb ON bb.id_bulto_contenido = sb.id_bulto
    INNER JOIN series s ON sb.id_serie = s.id_serie
    INNER JOIN bultos b_interno ON bb.id_bulto_contenido = b_interno.id_bulto
    WHERE bb.id_bulto_contenedor = p_id_bulto
    
    ORDER BY nivel, serie;
END//

-- ---------------------------------------------------------------------------
-- Procedimiento: ObtenerJerarquiaBultos - Ver jerarquía de bultos
-- ---------------------------------------------------------------------------
-- Muestra la estructura recursiva de bultos dentro de bultos
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS ObtenerJerarquiaBultos//

CREATE PROCEDURE ObtenerJerarquiaBultos(IN p_id_bulto INT)
BEGIN
    WITH RECURSIVE jerarquia AS (
        -- Bulto raíz
        SELECT 
            b.id_bulto,
            b.etiqueta,
            b.descripcion,
            0 AS nivel,
            CAST(b.etiqueta AS CHAR(1000)) AS ruta
        FROM bultos b
        WHERE b.id_bulto = p_id_bulto
        
        UNION ALL
        
        -- Bultos contenidos (recursión)
        SELECT 
            b.id_bulto,
            b.etiqueta,
            b.descripcion,
            j.nivel + 1,
            CONCAT(j.ruta, ' → ', b.etiqueta)
        FROM bultos b
        INNER JOIN bultos_bultos bb ON b.id_bulto = bb.id_bulto_contenido
        INNER JOIN jerarquia j ON bb.id_bulto_contenedor = j.id_bulto
    )
    SELECT 
        nivel,
        REPEAT('  ', nivel) AS indentacion,
        etiqueta,
        descripcion,
        ruta
    FROM jerarquia
    ORDER BY ruta, nivel;
END//

DELIMITER ;

-- ============================================================================
-- 8. DATOS DE PRUEBA
-- ============================================================================

-- Crear series de ejemplo
CALL CrearSerie('Producto A - Lote 1', @id_s1, @serie1);
CALL CrearSerie('Producto B - Lote 1', @id_s2, @serie2);
CALL CrearSerie('Producto C - Lote 1', @id_s3, @serie3);
CALL CrearSerie('Producto A - Lote 2', @id_s4, @serie4);
CALL CrearSerie('Producto B - Lote 2', @id_s5, @serie5);

-- Crear bultos de ejemplo
CALL CrearBulto('Caja Principal A', @id_b1, @bulto1);
CALL CrearBulto('Caja Secundaria A1', @id_b2, @bulto2);
CALL CrearBulto('Caja Secundaria A2', @id_b3, @bulto3);
CALL CrearBulto('Caja Principal B', @id_b4, @bulto4);

-- Asignar series a bultos
CALL AsignarSerieABulto(1, 1); -- Serie 1 en Bulto 1
CALL AsignarSerieABulto(2, 2); -- Serie 2 en Bulto 2
CALL AsignarSerieABulto(3, 2); -- Serie 3 en Bulto 2
CALL AsignarSerieABulto(4, 3); -- Serie 4 en Bulto 3
CALL AsignarSerieABulto(5, 4); -- Serie 5 en Bulto 4

-- Crear jerarquía de bultos (Bulto 2 y 3 dentro de Bulto 1)
CALL AsignarBultoABulto(1, 2); -- Bulto 2 dentro de Bulto 1
CALL AsignarBultoABulto(1, 3); -- Bulto 3 dentro de Bulto 1

-- ============================================================================
-- 9. TESTS Y VERIFICACIONES
-- ============================================================================

-- Ver todas las series
SELECT * FROM series ORDER BY serie;

-- Ver todos los bultos
SELECT * FROM bultos ORDER BY etiqueta;

-- Ver asignaciones de series a bultos
SELECT 
    s.serie,
    s.descripcion AS desc_serie,
    b.etiqueta,
    b.descripcion AS desc_bulto
FROM series_bultos sb
INNER JOIN series s ON sb.id_serie = s.id_serie
INNER JOIN bultos b ON sb.id_bulto = b.id_bulto
ORDER BY b.etiqueta, s.serie;

-- Ver jerarquía de bultos
SELECT 
    b_contenedor.etiqueta AS bulto_contenedor,
    b_contenido.etiqueta AS bulto_contenido
FROM bultos_bultos bb
INNER JOIN bultos b_contenedor ON bb.id_bulto_contenedor = b_contenedor.id_bulto
INNER JOIN bultos b_contenido ON bb.id_bulto_contenido = b_contenido.id_bulto
ORDER BY b_contenedor.etiqueta, b_contenido.etiqueta;

-- Ver historial de movimientos
SELECT * FROM historial_movimientos ORDER BY fecha DESC LIMIT 20;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
