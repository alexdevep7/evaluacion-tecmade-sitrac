<?php
/**
 * TECMADE - SITRAC: Endpoint de Movimiento de Stock
 * POST /api/stock/movimiento
 * @author Alex
 */

require_once '../config/database.php';

// Solo aceptar POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJSON(['error' => 'Method not allowed'], 405);
}

// Verificar token de autenticación
$user = verifyToken();

// Obtener datos del body JSON
$input = json_decode(file_get_contents('php://input'), true);

// Validar que se recibieron los campos requeridos
if (!isset($input['articulo']) || !isset($input['delta'])) {
    sendJSON([
        'error' => 'Missing required fields',
        'message' => 'articulo and delta are required'
    ], 400);
}

$articulo = trim($input['articulo']);
$delta = $input['delta'];

// Validar que delta sea numérico
if (!is_numeric($delta)) {
    sendJSON([
        'error' => 'Invalid delta value',
        'message' => 'delta must be a numeric value'
    ], 400);
}

$delta = (int)$delta;

// Validar que el artículo no esté vacío
if (empty($articulo)) {
    sendJSON([
        'error' => 'Invalid articulo',
        'message' => 'articulo cannot be empty'
    ], 400);
}

try {
    $pdo = getDBConnection();
    
    // Iniciar transacción
    $pdo->beginTransaction();
    
    // Buscar el artículo
    $stmt = $pdo->prepare("
        SELECT idstock, articulo, cantidad
        FROM stock
        WHERE articulo = :articulo
        FOR UPDATE
    ");
    $stmt->execute(['articulo' => $articulo]);
    $item = $stmt->fetch();
    
    if ($item) {
        // El artículo existe, calcular nueva cantidad
        $nuevaCantidad = $item['cantidad'] + $delta;
        
        // Validar que la cantidad no sea negativa
        if ($nuevaCantidad < 0) {
            $pdo->rollBack();
            sendJSON([
                'error' => 'Invalid operation',
                'message' => 'Stock quantity cannot be negative',
                'current_quantity' => $item['cantidad'],
                'attempted_delta' => $delta
            ], 400);
        }
        
        if ($nuevaCantidad == 0) {
            // Si la cantidad llega a 0, eliminar el artículo
            $stmt = $pdo->prepare("DELETE FROM stock WHERE idstock = :idstock");
            $stmt->execute(['idstock' => $item['idstock']]);
            
            $pdo->commit();
            
            sendJSON([
                'success' => true,
                'message' => 'Article deleted (quantity reached 0)',
                'articulo' => $articulo,
                'previous_quantity' => $item['cantidad'],
                'delta' => $delta,
                'final_quantity' => 0,
                'deleted' => true
            ], 200);
        } else {
            // Actualizar cantidad
            $stmt = $pdo->prepare("
                UPDATE stock
                SET cantidad = :cantidad
                WHERE idstock = :idstock
            ");
            $stmt->execute([
                'cantidad' => $nuevaCantidad,
                'idstock' => $item['idstock']
            ]);
            
            $pdo->commit();
            
            sendJSON([
                'success' => true,
                'message' => 'Stock updated successfully',
                'articulo' => [
                    'idstock' => $item['idstock'],
                    'articulo' => $articulo,
                    'previous_quantity' => $item['cantidad'],
                    'delta' => $delta,
                    'cantidad' => $nuevaCantidad
                ]
            ], 200);
        }
    } else {
        // El artículo no existe
        
        if ($delta <= 0) {
            // No se puede crear un artículo con delta negativo o cero
            $pdo->rollBack();
            sendJSON([
                'error' => 'Invalid operation',
                'message' => 'Cannot create article with non-positive delta',
                'articulo' => $articulo,
                'delta' => $delta
            ], 400);
        }
        
        // Crear nuevo artículo
        $stmt = $pdo->prepare("
            INSERT INTO stock (articulo, cantidad)
            VALUES (:articulo, :cantidad)
        ");
        $stmt->execute([
            'articulo' => $articulo,
            'cantidad' => $delta
        ]);
        
        $newId = $pdo->lastInsertId();
        
        $pdo->commit();
        
        sendJSON([
            'success' => true,
            'message' => 'New article created successfully',
            'articulo' => [
                'idstock' => $newId,
                'articulo' => $articulo,
                'cantidad' => $delta
            ],
            'created' => true
        ], 201);
    }
    
} catch (PDOException $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    
    sendJSON([
        'error' => 'Internal server error',
        'message' => 'An error occurred while processing stock movement'
    ], 500);
}
