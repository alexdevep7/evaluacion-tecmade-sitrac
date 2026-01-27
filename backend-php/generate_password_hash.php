<?php
/**
 * TECMADE - SITRAC: Generador de hash de contraseñas
 * Uso: php generate_password_hash.php
 * @author Alex
 */

echo "=== Generador de Hash de Contraseñas ===\n\n";

// Contraseñas a hashear
$passwords = [
    'admin123',
    'user123',
    'test123'
];

foreach ($passwords as $password) {
    $hash = password_hash($password, PASSWORD_DEFAULT);
    echo "Password: $password\n";
    echo "Hash: $hash\n";
    echo str_repeat("-", 80) . "\n";
}

echo "\nPara generar un hash personalizado desde terminal:\n";
echo "php -r \"echo password_hash('tu_password', PASSWORD_DEFAULT);\"\n";
