<?php
/**
 * TECMADE - SITRAC: Router principal de la API
 * @author Alex
 */

// Configurar headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Manejar preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Obtener la ruta solicitada
$requestUri = $_SERVER['REQUEST_URI'];
$requestMethod = $_SERVER['REQUEST_METHOD'];

// Remover query string si existe
$requestUri = strtok($requestUri, '?');

// Remover prefijo si existe (ej: /backend-php/)
$basePath = '/api';
if (strpos($requestUri, $basePath) === 0) {
    $requestUri = substr($requestUri, strlen($basePath));
}

// Definir rutas
$routes = [
    'POST:/login' => 'api/login.php',
    'GET:/stock' => 'api/stock.php',
    'POST:/stock/movimiento' => 'api/movimiento.php',
];

$routeKey = $requestMethod . ':' . $requestUri;

// Buscar la ruta correspondiente
if (isset($routes[$routeKey])) {
    require_once $routes[$routeKey];
} else {
    http_response_code(404);
    echo json_encode([
        'error' => 'Endpoint not found',
        'message' => 'The requested endpoint does not exist',
        'requested' => $requestUri,
        'method' => $requestMethod
    ]);
}
