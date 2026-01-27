<?php
/**
 * TECMADE - SITRAC: Endpoint de Login
 * POST /api/login
 * @author Alex
 */

require_once '../config/database.php';

// Solo aceptar POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJSON(['error' => 'Method not allowed'], 405);
}

// Obtener datos del body JSON
$input = json_decode(file_get_contents('php://input'), true);

// Validar que se recibieron los campos requeridos
if (!isset($input['email']) || !isset($input['password'])) {
    sendJSON([
        'error' => 'Missing required fields',
        'message' => 'Email and password are required'
    ], 400);
}

$email = trim($input['email']);
$password = $input['password'];

// Validar formato de email
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    sendJSON([
        'error' => 'Invalid email format'
    ], 400);
}

try {
    $pdo = getDBConnection();
    
    // Buscar usuario por email
    $stmt = $pdo->prepare("
        SELECT id, email, password_hash, legajo
        FROM usuarios
        WHERE email = :email
    ");
    $stmt->execute(['email' => $email]);
    $user = $stmt->fetch();
    
    // Verificar si el usuario existe
    if (!$user) {
        sendJSON([
            'error' => 'Invalid credentials',
            'message' => 'Email or password is incorrect'
        ], 401);
    }
    
    // Verificar contraseña
    if (!password_verify($password, $user['password_hash'])) {
        sendJSON([
            'error' => 'Invalid credentials',
            'message' => 'Email or password is incorrect'
        ], 401);
    }
    
    // Generar token
    $token = generateToken();
    
    // Calcular fecha de expiración
    $expiresAt = date('Y-m-d H:i:s', time() + TOKEN_EXPIRATION);
    
    // Guardar token en base de datos
    $stmt = $pdo->prepare("
        INSERT INTO tokens (usuario_id, token, expires_at)
        VALUES (:usuario_id, :token, :expires_at)
    ");
    $stmt->execute([
        'usuario_id' => $user['id'],
        'token' => $token,
        'expires_at' => $expiresAt
    ]);
    
    // Preparar respuesta exitosa
    $response = [
        'token' => $token,
        'user' => [
            'email' => $user['email'],
            'legajo' => $user['legajo']
        ]
    ];
    
    sendJSON($response, 200);
    
} catch (PDOException $e) {
    sendJSON([
        'error' => 'Internal server error',
        'message' => 'An error occurred during login'
    ], 500);
}
