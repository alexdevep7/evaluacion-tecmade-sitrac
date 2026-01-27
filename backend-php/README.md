# Backend PHP - TECMADE SITRAC

## 📋 Requisitos
- PHP 7.4 o superior
- MySQL 5.7 o superior
- Extensión PDO de PHP habilitada
- Apache o servidor web con soporte para `.htaccess` (opcional)

## 🚀 Instalación

### 1. Configurar Base de Datos

```bash
# Acceder a MySQL
mysql -u root -p

# Ejecutar scripts SQL (desde la raíz del proyecto)
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql
```

### 2. Configurar Credenciales

Editar el archivo `config/database.php` y ajustar las credenciales:

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'tecmade_db');
define('DB_USER', 'tu_usuario');
define('DB_PASS', 'tu_password');
```

### 3. Levantar el Servidor

#### Opción A: PHP Built-in Server (Desarrollo)
```bash
cd backend-php
php -S localhost:8000
```

#### Opción B: Apache/XAMPP
- Copiar el directorio `backend-php` a tu carpeta `htdocs`
- Acceder a `http://localhost/backend-php/api/login`

#### Opción C: Nginx
Configurar el server block para apuntar a `backend-php/index.php`

## 🔌 Endpoints Disponibles

### POST /api/login
**Descripción:** Autenticación de usuario

**Request:**
```json
{
  "email": "admin@tecmade.com",
  "password": "admin123"
}
```

**Response (200):**
```json
{
  "token": "abc123...",
  "user": {
    "email": "admin@tecmade.com",
    "legajo": "LEG001"
  }
}
```

**Response (401):**
```json
{
  "error": "Invalid credentials",
  "message": "Email or password is incorrect"
}
```

---

### GET /api/stock
**Descripción:** Obtiene listado de stock

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200):**
```json
[
  {
    "idstock": 1,
    "articulo": "Tornillo M8x20",
    "cantidad": 150
  },
  {
    "idstock": 2,
    "articulo": "Tuerca M8",
    "cantidad": 200
  }
]
```

**Response (401):**
```json
{
  "error": "Invalid token"
}
```

---

### POST /api/stock/movimiento
**Descripción:** Realiza movimiento de stock (agregar/reducir/crear/eliminar)

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request:**
```json
{
  "articulo": "Tornillo M8x20",
  "delta": 10
}
```

**Casos de uso:**

1. **Agregar stock** (delta positivo + artículo existe):
   - Incrementa la cantidad

2. **Reducir stock** (delta negativo + artículo existe):
   - Decrementa la cantidad
   - Si llega a 0, elimina el artículo

3. **Crear artículo** (delta positivo + artículo NO existe):
   - Crea nuevo artículo con cantidad = delta

4. **Error: cantidad negativa** (resultado final < 0):
   - Retorna 400 Bad Request

5. **Error: crear con delta negativo** (delta <= 0 + artículo NO existe):
   - Retorna 400 Bad Request

**Response (200) - Actualización exitosa:**
```json
{
  "success": true,
  "message": "Stock updated successfully",
  "articulo": {
    "idstock": 1,
    "articulo": "Tornillo M8x20",
    "previous_quantity": 150,
    "delta": 10,
    "cantidad": 160
  }
}
```

**Response (201) - Artículo creado:**
```json
{
  "success": true,
  "message": "New article created successfully",
  "articulo": {
    "idstock": 11,
    "articulo": "Nuevo Producto",
    "cantidad": 50
  },
  "created": true
}
```

**Response (400) - Cantidad negativa:**
```json
{
  "error": "Invalid operation",
  "message": "Stock quantity cannot be negative",
  "current_quantity": 10,
  "attempted_delta": -20
}
```

## 🧪 Pruebas

### Con cURL
```bash
# Login
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@tecmade.com","password":"admin123"}'

# Obtener stock (reemplazar TOKEN)
curl -X GET http://localhost:8000/api/stock \
  -H "Authorization: Bearer TOKEN"
```

Ver más ejemplos en `docs/curl_examples.sh`

### Con Postman
Importar la colección: `docs/postman_collection.json`

## 🔐 Seguridad Implementada

✅ **Contraseñas hasheadas** con `password_hash()` y `password_verify()`  
✅ **Prepared statements** (PDO) para prevenir SQL Injection  
✅ **Validación de entrada** (email, tipos de datos, longitudes)  
✅ **Tokens Bearer** almacenados en base de datos  
✅ **Headers CORS** configurados  
✅ **Códigos HTTP apropiados** (200, 201, 400, 401, 500)  
✅ **Respuestas JSON consistentes** en todos los endpoints  
✅ **Transacciones** para operaciones críticas  

## 🛠️ Troubleshooting

### Error: "Database connection failed"
- Verificar que MySQL esté corriendo
- Comprobar credenciales en `config/database.php`
- Verificar que la base de datos `tecmade_db` exista

### Error: "Call to undefined function password_hash"
- Verificar versión de PHP (debe ser >= 5.5)
- Habilitar extensión de PHP

### Error: 404 en endpoints
- Verificar que el archivo `.htaccess` exista
- Asegurarse de que `mod_rewrite` esté habilitado en Apache
- O usar routing manual: `http://localhost:8000/index.php`

## 📚 Estructura de Archivos

```
backend-php/
├── api/
│   ├── login.php          # POST /api/login
│   ├── stock.php          # GET /api/stock
│   └── movimiento.php     # POST /api/stock/movimiento
├── config/
│   └── database.php       # Configuración BD + utilidades
├── .htaccess              # Rewrite rules
├── index.php              # Router principal
└── generate_password_hash.php  # Utilidad para generar hashes
```

## 📝 Credenciales de Prueba

```
Email: admin@tecmade.com
Password: admin123

Email: user@tecmade.com
Password: admin123

Email: test@tecmade.com
Password: admin123
```
