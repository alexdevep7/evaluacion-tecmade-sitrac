<?php
/**
 * TECMADE - SITRAC: Configuración de Base de Datos - EJEMPLO
 * @author Alex
 * 
 * IMPORTANTE: 
 * 1. Copiar este archivo como database.php
 * 2. Modificar las credenciales con tus datos reales
 * 3. El archivo database.php NO se subirá a Git (está en .gitignore)
 */

// Configuración de base de datos
define('DB_HOST', 'localhost');
define('DB_NAME', 'tecmade_db');
define('DB_USER', 'TU_USUARIO_MYSQL');           // ← Cambiar
define('DB_PASS', 'TU_PASSWORD_MYSQL');          // ← Cambiar
define('DB_CHARSET', 'utf8mb4');

// Configuración de JWT/Token
define('JWT_SECRET', 'GENERAR_CLAVE_SECRETA_AQUI');  // ← Cambiar en producción
define('TOKEN_EXPIRATION', 3600); // 1 hora en segundos

// Configuración de API
define('API_VERSION', 'v1');

/**
 * Obtiene conexión PDO a la base de datos
 * @return PDO
 */
function getDBConnection() {
    try {
        $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];
        
        $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        return $pdo;
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'error' => 'Database connection failed',
            'message' => $e->getMessage()
        ]);
        exit;
    }
}

/**
 * Genera un token aleatorio seguro
 * @return string
 */
function generateToken() {
    return bin2hex(random_bytes(32));
}

/**
 * Envía respuesta JSON
 * @param array $data
 * @param int $statusCode
 */
function sendJSON($data, $statusCode = 200) {
    http_response_code($statusCode);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

/**
 * Verifica el token Bearer en el header Authorization
 * @return array|null Retorna los datos del usuario si el token es válido
 */
function verifyToken() {
    $headers = getallheaders();
    
    if (!isset($headers['Authorization'])) {
        sendJSON(['error' => 'Authorization header missing'], 401);
    }
    
    $authHeader = $headers['Authorization'];
    
    if (!preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
        sendJSON(['error' => 'Invalid authorization format'], 401);
    }
    
    $token = $matches[1];
    
    try {
        $pdo = getDBConnection();
        
        // Verificar token en base de datos
        $stmt = $pdo->prepare("
            SELECT u.id, u.email, u.legajo, t.expires_at
            FROM tokens t
            INNER JOIN usuarios u ON t.usuario_id = u.id
            WHERE t.token = :token
        ");
        $stmt->execute(['token' => $token]);
        $result = $stmt->fetch();
        
        if (!$result) {
            sendJSON(['error' => 'Invalid token'], 401);
        }
        
        // Verificar expiración si está configurada
        if ($result['expires_at'] && strtotime($result['expires_at']) < time()) {
            sendJSON(['error' => 'Token expired'], 401);
        }
        
        return $result;
    } catch (PDOException $e) {
        sendJSON(['error' => 'Token verification failed'], 500);
    }
}

// Configurar headers CORS para desarrollo
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Manejar preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
