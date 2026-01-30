-- ============================================================================
-- TECMADE - SITRAC: Sistema de Orders/Links (2 puntos)
-- Evaluación Técnica - Desarrollador Android
-- @author Alex
-- ============================================================================
-- Descripción: Sistema de órdenes enlazadas que permite vincular órdenes
-- en una secuencia mediante relaciones previas/siguientes.
-- ============================================================================

-- Usar la base de datos
USE tecmade_db;

-- ============================================================================
-- 1. DDL - CREACIÓN DE TABLAS
-- ============================================================================

-- Tabla Orders: Almacena las órdenes
DROP TABLE IF EXISTS links;
DROP TABLE IF EXISTS Orders;

CREATE TABLE Orders (
    OrderId INT AUTO_INCREMENT PRIMARY KEY,
    OrderNo VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_orderno (OrderNo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla links: Relaciona órdenes (orden actual con su orden previa)
CREATE TABLE links (
    OrderId INT NOT NULL,
    prevOrderId INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (OrderId),
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE,
    FOREIGN KEY (prevOrderId) REFERENCES Orders(OrderId) ON DELETE SET NULL,
    INDEX idx_prev (prevOrderId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. DATOS DE PRUEBA
-- ============================================================================

-- Insertar órdenes de ejemplo
INSERT INTO Orders (OrderNo) VALUES 
    ('ORD-001'),  -- OrderId: 1 (inicial de cadena 1)
    ('ORD-002'),  -- OrderId: 2 (medio de cadena 1)
    ('ORD-003'),  -- OrderId: 3 (medio de cadena 1)
    ('ORD-004'),  -- OrderId: 4 (final de cadena 1)
    ('ORD-005'),  -- OrderId: 5 (inicial de cadena 2)
    ('ORD-006'),  -- OrderId: 6 (final de cadena 2)
    ('ORD-007'),  -- OrderId: 7 (huérfana, sin enlaces)
    ('ORD-008'),  -- OrderId: 8 (inicial de cadena 3)
    ('ORD-009'),  -- OrderId: 9 (final de cadena 3)
    ('ORD-010'); -- OrderId: 10 (huérfana, sin enlaces)

-- Crear enlaces (cadena 1: 1→2→3→4)
INSERT INTO links (OrderId, prevOrderId) VALUES
    (1, NULL),  -- ORD-001 es inicial
    (2, 1),     -- ORD-002 sigue a ORD-001
    (3, 2),     -- ORD-003 sigue a ORD-002
    (4, 3);     -- ORD-004 sigue a ORD-003

-- Crear enlaces (cadena 2: 5→6)
INSERT INTO links (OrderId, prevOrderId) VALUES
    (5, NULL),  -- ORD-005 es inicial
    (6, 5);     -- ORD-006 sigue a ORD-005

-- Crear enlaces (cadena 3: 8→9)
INSERT INTO links (OrderId, prevOrderId) VALUES
    (8, NULL),  -- ORD-008 es inicial
    (9, 8);     -- ORD-009 sigue a ORD-008

-- ORD-007 y ORD-010 son huérfanas (sin registros en links)

-- ============================================================================
-- 3. CONSULTAS REQUERIDAS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- CONSULTA 1: Dado un OrderNo, obtener la orden previa y siguiente
-- ---------------------------------------------------------------------------
-- Descripción: Para una orden específica, muestra qué orden la precede
-- y qué orden la sigue en la cadena.
-- ---------------------------------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS GetPrevNextOrder//

CREATE PROCEDURE GetPrevNextOrder(IN p_OrderNo VARCHAR(50))
BEGIN
    SELECT 
        o.OrderId,
        o.OrderNo,
        -- Orden previa
        prev_o.OrderId AS PrevOrderId,
        prev_o.OrderNo AS PrevOrderNo,
        -- Orden siguiente
        next_o.OrderId AS NextOrderId,
        next_o.OrderNo AS NextOrderNo
    FROM Orders o
    LEFT JOIN links l ON o.OrderId = l.OrderId
    LEFT JOIN Orders prev_o ON l.prevOrderId = prev_o.OrderId
    LEFT JOIN links next_l ON o.OrderId = next_l.prevOrderId
    LEFT JOIN Orders next_o ON next_l.OrderId = next_o.OrderId
    WHERE o.OrderNo = p_OrderNo;
END//

DELIMITER ;

-- Ejemplo de uso:
-- CALL GetPrevNextOrder('ORD-003');
-- Resultado esperado: Prev=ORD-002, Next=ORD-004

-- ---------------------------------------------------------------------------
-- CONSULTA 2: Órdenes iniciales (sin orden previa)
-- ---------------------------------------------------------------------------
-- Descripción: Encuentra todas las órdenes que son el inicio de una cadena
-- (no tienen orden previa)
-- ---------------------------------------------------------------------------

DROP VIEW IF EXISTS InitialOrders;

CREATE VIEW InitialOrders AS
SELECT 
    o.OrderId,
    o.OrderNo,
    o.created_at,
    'ORDEN INICIAL' AS OrderType
FROM Orders o
INNER JOIN links l ON o.OrderId = l.OrderId
WHERE l.prevOrderId IS NULL
ORDER BY o.OrderId;

-- Ejemplo de uso:
-- SELECT * FROM InitialOrders;
-- Resultado esperado: ORD-001, ORD-005, ORD-008

-- ---------------------------------------------------------------------------
-- CONSULTA 3: Órdenes finales (sin orden siguiente)
-- ---------------------------------------------------------------------------
-- Descripción: Encuentra todas las órdenes que son el final de una cadena
-- (no tienen orden siguiente)
-- ---------------------------------------------------------------------------

DROP VIEW IF EXISTS FinalOrders;

CREATE VIEW FinalOrders AS
SELECT 
    o.OrderId,
    o.OrderNo,
    o.created_at,
    'ORDEN FINAL' AS OrderType
FROM Orders o
INNER JOIN links l ON o.OrderId = l.OrderId
WHERE NOT EXISTS (
    SELECT 1 FROM links l2 WHERE l2.prevOrderId = o.OrderId
)
ORDER BY o.OrderId;

-- Ejemplo de uso:
-- SELECT * FROM FinalOrders;
-- Resultado esperado: ORD-004, ORD-006, ORD-009

-- ---------------------------------------------------------------------------
-- CONSULTA 4: Órdenes huérfanas (sin enlaces)
-- ---------------------------------------------------------------------------
-- Descripción: Encuentra órdenes que no tienen ningún enlace
-- (ni son previas ni siguientes de nadie)
-- ---------------------------------------------------------------------------

DROP VIEW IF EXISTS OrphanOrders;

CREATE VIEW OrphanOrders AS
SELECT 
    o.OrderId,
    o.OrderNo,
    o.created_at,
    'ORDEN HUÉRFANA' AS OrderType
FROM Orders o
WHERE o.OrderId NOT IN (SELECT OrderId FROM links)
  AND o.OrderId NOT IN (SELECT prevOrderId FROM links WHERE prevOrderId IS NOT NULL)
ORDER BY o.OrderId;

-- Ejemplo de uso:
-- SELECT * FROM OrphanOrders;
-- Resultado esperado: ORD-007, ORD-010

-- ============================================================================
-- 4. CONSULTA ADICIONAL: Ver todas las cadenas completas
-- ============================================================================

DROP PROCEDURE IF EXISTS GetAllChains//

DELIMITER //

CREATE PROCEDURE GetAllChains()
BEGIN
    -- Mostrar todas las cadenas de órdenes
    WITH RECURSIVE OrderChain AS (
        -- Órdenes iniciales (punto de partida)
        SELECT 
            o.OrderId,
            o.OrderNo,
            l.prevOrderId,
            1 AS depth,
            CAST(o.OrderNo AS CHAR(1000)) AS chain
        FROM Orders o
        INNER JOIN links l ON o.OrderId = l.OrderId
        WHERE l.prevOrderId IS NULL
        
        UNION ALL
        
        -- Órdenes siguientes (recursión)
        SELECT 
            o.OrderId,
            o.OrderNo,
            l.prevOrderId,
            oc.depth + 1,
            CONCAT(oc.chain, ' → ', o.OrderNo)
        FROM Orders o
        INNER JOIN links l ON o.OrderId = l.OrderId
        INNER JOIN OrderChain oc ON l.prevOrderId = oc.OrderId
    )
    SELECT 
        depth AS Position,
        OrderNo,
        chain AS FullChain
    FROM OrderChain
    ORDER BY chain, depth;
END//

DELIMITER ;

-- Ejemplo de uso:
-- CALL GetAllChains();

-- ============================================================================
-- 5. TESTS Y VERIFICACIONES
-- ============================================================================

-- Test 1: Ver todas las órdenes con sus enlaces
SELECT 
    o.OrderId,
    o.OrderNo,
    COALESCE(prev_o.OrderNo, 'N/A') AS PreviousOrder,
    CASE 
        WHEN EXISTS (SELECT 1 FROM links WHERE prevOrderId = o.OrderId) 
        THEN 'Sí' 
        ELSE 'No' 
    END AS HasNextOrder
FROM Orders o
LEFT JOIN links l ON o.OrderId = l.OrderId
LEFT JOIN Orders prev_o ON l.prevOrderId = prev_o.OrderId
ORDER BY o.OrderId;

-- Test 2: Contar órdenes por tipo
SELECT 'Iniciales' AS Type, COUNT(*) AS Count FROM InitialOrders
UNION ALL
SELECT 'Finales', COUNT(*) FROM FinalOrders
UNION ALL
SELECT 'Huérfanas', COUNT(*) FROM OrphanOrders
UNION ALL
SELECT 'Total', COUNT(*) FROM Orders;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
