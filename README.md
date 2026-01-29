# Evaluación Técnica TECMADE - SITRAC

## Desarrollador Android - Alex

### 📋 Descripción

Proyecto de evaluación técnica que incluye:

- **Backend PHP**: API REST con autenticación y gestión de stock
- **Mobile Android**: Aplicación móvil que consume la API
- **MySQL Avanzado**: Consultas complejas y procedimientos almacenados

---

## 🗂️ Estructura del Proyecto

```
evaluacion-tecmade-sitrac/
├── backend-php/          # API REST en PHP
│   ├── api/             # Endpoints de la API
│   ├── config/          # Configuración y conexión a BD
│   └── models/          # Modelos de datos
├── database/            # Scripts SQL
├── android-app/         # Aplicación Android
├── docs/                # Documentación adicional
└── README.md           # Este archivo
```

---

## 🚀 Instalación y Ejecución

### Prerequisitos

- PHP 7.4 o superior
- MySQL 5.7 o superior
- Composer (opcional)
- Android Studio (para la app móvil)

### Backend PHP

#### 1. Configurar Base de Datos

```bash
# Importar el script SQL
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql
```

#### 2. Configurar credenciales

Editar el archivo `backend-php/config/database.php` con tus credenciales de MySQL:

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'tecmade_db');
define('DB_USER', 'tu_usuario');
define('DB_PASS', 'tu_password');
```

#### 3. Levantar servidor

```bash
cd backend-php
# Para que funcione con emulador Android, usar 0.0.0.0
php -S 0.0.0.0:8000 index.php
```

La API estará disponible en: `http://localhost:8000`

---

### Mobile Android

#### 1. Abrir en Android Studio

- Abrir la carpeta `android-app` en Android Studio
- Esperar sincronización de Gradle

#### 2. Configurar URL del Backend

Editar `android-app/app/src/main/java/com/tecmade/stock/data/remote/RetrofitInstance.kt`:

```kotlin
// Para emulador Android
private const val BASE_URL = "http://10.0.2.2:8000/"

// Para dispositivo físico (reemplazar con tu IP local)
// private const val BASE_URL = "http://192.168.X.X:8000/"
```

#### 3. Levantar Backend

**IMPORTANTE:** Usar `0.0.0.0:8000` para que el emulador pueda conectarse:

```bash
cd backend-php
php -S 0.0.0.0:8000 index.php
```

#### 4. Ejecutar App

- Click en Run (▶️) en Android Studio
- Seleccionar emulador o dispositivo físico
- Credenciales: `admin@tecmade.com` / `admin123`

#### Funcionalidades Implementadas

✅ **Login** con persistencia de sesión (DataStore)  
✅ **Listado de stock** con pull-to-refresh  
✅ **Movimientos de stock** (agregar/restar cantidad)  
✅ **Manejo de errores** robusto (no crashea sin conexión)  
✅ **Logout** con limpieza de sesión  
✅ **Arquitectura MVVM** + Clean Architecture  
✅ **Material 3** con soporte tema claro/oscuro

#### Stack Tecnológico

- **Lenguaje:** Kotlin
- **UI:** Jetpack Compose + Material 3
- **Networking:** Retrofit 2.11.0 + OkHttp
- **Persistencia:** DataStore Preferences
- **Navegación:** Navigation Compose
- **Async:** Coroutines + Flow
- **Arquitectura:** MVVM + Clean Architecture

---

## 📡 API Endpoints

### Autenticación

- **POST** `/api/login`
  - Body: `{ "email": "user@example.com", "password": "123456" }`
  - Response: `{ "token": "...", "user": { "email": "...", "legajo": ... } }`

### Stock (requieren autenticación)

- **GET** `/api/stock`

  - Header: `Authorization: Bearer {token}`
  - Response: `[{ "idstock": 1, "articulo": "...", "cantidad": 10 }]`

- **POST** `/api/stock/movimiento`
  - Header: `Authorization: Bearer {token}`
  - Body: `{ "articulo": "XYZ", "delta": 5 }`
  - Response: `{ "success": true, "articulo": {...} }`

---

## 🧪 Testing con Postman

Importar la colección ubicada en: `docs/postman_collection.json`

O usar los siguientes ejemplos con curl:

```bash
# Login
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@tecmade.com","password":"admin123"}'

# Obtener stock
curl -X GET http://localhost:8000/api/stock \
  -H "Authorization: Bearer TU_TOKEN_AQUI"

# Movimiento de stock
curl -X POST http://localhost:8000/api/stock/movimiento \
  -H "Authorization: Bearer TU_TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{"articulo":"Producto A","delta":10}'
```

---

## 📝 Respuestas a Preguntas Teóricas

### 1. ¿Qué método(s) HTTP usaste para login y para obtener el listado? ¿Por qué?

**Respuesta:**

- **POST para login**: Porque estamos enviando credenciales sensibles en el body y el servidor crea un nuevo token de sesión (recurso). POST es el método apropiado para operaciones que crean recursos o tienen efectos secundarios.
- **GET para listado**: Porque estamos solicitando datos sin modificar el estado del servidor. Es una operación idempotente y segura, características fundamentales de GET.

### 2. ¿Cómo protegés credenciales durante el envío?

**Respuesta:**

- **HTTPS en producción**: Todas las comunicaciones deben usar TLS/SSL para cifrar datos en tránsito.
- **Hash en servidor**: Las contraseñas nunca se almacenan en texto plano, solo su hash usando `password_hash()` con bcrypt.
- **No logging de credenciales**: Los sistemas de log nunca deben registrar contraseñas o tokens.
- **Token Bearer**: Después del login, se usa un token JWT en el header Authorization, evitando enviar credenciales repetidamente.

### 3. ¿Cómo evitás inyección SQL y qué validaciones aplicás del lado servidor?

**Respuesta:**

- **Prepared Statements**: Uso exclusivo de consultas preparadas con PDO, separando código SQL de datos.
- **Validaciones de entrada**:
  - Validación de formato de email
  - Validación de tipos de datos (ej: delta debe ser numérico)
  - Sanitización de strings
  - Validación de longitud de campos
- **Validaciones de negocio**:
  - No permitir cantidades negativas en stock
  - Verificar existencia de registros antes de operaciones
  - Validar que el token sea válido y no haya expirado

### 4. ¿Cómo manejarías expiración/renovación del token en un entorno productivo?

**Respuesta:**

- **JWT con expiración**: Implementar tokens JWT con claim `exp` (ej: 1 hora de vida).
- **Refresh tokens**: Sistema de dos tokens:
  - Access token (corta duración, 15-60 min)
  - Refresh token (larga duración, 7-30 días, almacenado en DB)
- **Endpoint de renovación**: `POST /api/refresh` que valida el refresh token y emite un nuevo access token.
- **Revocación**: Mantener lista negra de tokens revocados en Redis/DB.
- **Rotación de refresh tokens**: Al renovar, emitir nuevo refresh token y invalidar el anterior.

---

## 👨‍💻 Autor

**Alex** - Desarrollador Android  
Evaluación técnica para TECMADE S.A. - SITRAC

---

## 📄 Licencia

Este proyecto es de uso exclusivo para evaluación técnica.
