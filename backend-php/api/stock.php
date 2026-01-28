<?php
/**
 * TECMADE - SITRAC: Endpoint de Stock
 * GET /api/stock
 * @author Alex
 */

require_once __DIR__ . '/../config/database.php';

// Solo aceptar GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJSON(['error' => 'Method not allowed'], 405);
}

// Verificar token de autenticación
$user = verifyToken();

try {
    $pdo = getDBConnection();
    
    // Obtener todos los artículos de stock
    $stmt = $pdo->prepare("
        SELECT idstock, articulo, cantidad
        FROM stock
        ORDER BY articulo ASC
    ");
    $stmt->execute();
    $stock = $stmt->fetchAll();
    
    // Enviar respuesta con el listado
    sendJSON($stock, 200);
    
} catch (PDOException $e) {
    sendJSON([
        'error' => 'Internal server error',
        'message' => 'An error occurred while fetching stock'
    ], 500);
}
