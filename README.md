# Evaluación Técnica TECMADE - SITRAC

## Desarrollador Android - Alfredo Castillo

### 📋 Descripción

Proyecto de evaluación técnica full-stack que incluye:

- **Backend PHP**: API REST con autenticación JWT y gestión de stock
- **Mobile Android**: Aplicación móvil nativa con soporte para tablets
- **MySQL Avanzado**: Sistema de embalado con consultas recursivas y gestión de órdenes enlazadas

---

## 🗂️ Estructura del Proyecto

```
evaluacion-tecmade-sitrac/
├── backend-php/          # API REST en PHP
│   ├── api/             # Endpoints de la API
│   ├── config/          # Configuración y conexión a BD
│   └── models/          # Modelos de datos
├── database/            # Scripts SQL
│   ├── schema.sql      # Esquema base de datos
│   ├── seed.sql        # Datos de prueba
│   ├── embalado.sql    # Sistema de embalado (series/bultos)
│   └── orders.sql      # Sistema de órdenes enlazadas
├── android-app/         # Aplicación Android
│   └── app/
│       └── src/main/java/com/tecmade/stock/
│           ├── data/           # Modelos, repositorios, API
│           ├── ui/             # Pantallas (Compose)
│           └── navigation/     # Navegación
├── docs/                # Documentación adicional
└── README.md           # Este archivo
```

---

## 🚀 Instalación y Ejecución

### Prerequisitos

**Para desarrollo en macOS:**

- PHP 8.3 o superior
- MySQL 8.0 o superior
- MAMP (para desarrollo local)
- Android Studio Otter (2025.2.3) o superior
- JDK 17 o superior

**Para desarrollo en Windows:**

- PHP 8.3 o superior
- MySQL 8.0 o superior
- XAMPP o WAMP (para desarrollo local)
- Android Studio Otter (2025.2.3) o superior
- JDK 17 o superior

---

## 📦 Backend PHP

### 1. Configurar Base de Datos

#### Opción A: Usando MySQL desde terminal (macOS/Linux)

```bash
# Importar esquema y datos
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql

# (Opcional) Importar sistemas avanzados
mysql -u root -p < database/embalado.sql
mysql -u root -p < database/orders.sql
```

#### Opción B: Usando XAMPP/WAMP (Windows)

```powershell
# Iniciar XAMPP/WAMP
# Abrir phpMyAdmin: http://localhost/phpMyAdmin/

# Importar manualmente los archivos .sql desde la interfaz
# O desde PowerShell/CMD:
cd C:\xampp\mysql\bin
.\mysql.exe -u root < ruta\al\proyecto\database\schema.sql
.\mysql.exe -u root < ruta\al\proyecto\database\seed.sql
.\mysql.exe -u root < ruta\al\proyecto\database\embalado.sql
.\mysql.exe -u root < ruta\al\proyecto\database\orders.sql
```

**Nota:** En XAMPP por defecto no hay contraseña para root. Si te pide contraseña, omite el parámetro `-p`.

#### Opción C: Usando MAMP (macOS)

```bash
# Iniciar MAMP
open /Applications/MAMP/MAMP.app

# Click en "Start Servers"
# Desde MySQL client:
/Applications/MAMP/Library/bin/mysql -u root -proot tecmade_db
```

Luego dentro de MySQL:

```sql
source database/schema.sql
source database/seed.sql
source database/embalado.sql
source database/orders.sql
```

### 2. Configurar credenciales

Editar `backend-php/config/database.php`:

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'tecmade_db');
define('DB_USER', 'root');
define('DB_PASS', 'root');  // MAMP: 'root' | XAMPP: '' (vacío) | Ajustar según tu configuración
```

### 3. Levantar servidor

**IMPORTANTE:** Usar `0.0.0.0:8000` para que funcione con emulador Android.

#### macOS (MAMP):

```bash
cd backend-php
/Applications/MAMP/bin/php/php8.3.28/bin/php -S 0.0.0.0:8000 index.php
```

#### Windows (XAMPP):

```cmd
cd backend-php
C:\xampp\php\php.exe -S 0.0.0.0:8000 index.php
```

#### Windows (WAMP):

```cmd
cd backend-php
C:\wamp64\bin\php\php8.3.x\php.exe -S 0.0.0.0:8000 index.php
```

#### PHP estándar (cualquier OS):

```bash
cd backend-php
php -S 0.0.0.0:8000 index.php
```

**La API estará disponible en:** `http://localhost:8000`

### 4. Verificar funcionamiento

#### macOS/Linux:

```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@tecmade.com","password":"admin123"}'
```

#### Windows (PowerShell):

```powershell
Invoke-RestMethod -Uri "http://localhost:8000/api/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"email":"admin@tecmade.com","password":"admin123"}'
```

#### Windows (CMD) o usar Postman (recomendado):

```cmd
curl -X POST http://localhost:8000/api/login -H "Content-Type: application/json" -d "{\"email\":\"admin@tecmade.com\",\"password\":\"admin123\"}"
```

Deberías recibir un token en la respuesta.

---

## 📱 Mobile Android

### 1. Abrir en Android Studio

- Abrir la carpeta `android-app`
- Esperar sincronización de Gradle (primera vez puede tardar)

### 2. Configurar URL del Backend

Editar `android-app/app/src/main/java/com/tecmade/stock/data/remote/RetrofitInstance.kt`:

```kotlin
// Para EMULADOR Android
private const val BASE_URL = "http://10.0.2.2:8000/"

// Para DISPOSITIVO FÍSICO (reemplazar con tu IP local)
// private const val BASE_URL = "http://192.168.X.X:8000/"
```

**Para obtener tu IP local:**

#### macOS/Linux:

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

#### Windows (CMD):

```cmd
ipconfig | findstr IPv4
```

#### Windows (PowerShell):

```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*"}
```

Busca una IP que comience con `192.168.` o `10.0.`

### 3. Levantar Backend

Antes de ejecutar la app, asegúrate que el backend esté corriendo:

#### macOS:

```bash
cd backend-php
/Applications/MAMP/bin/php/php8.3.28/bin/php -S 0.0.0.0:8000 index.php
```

#### Windows:

```cmd
cd backend-php
C:\xampp\php\php.exe -S 0.0.0.0:8000 index.php
```

### 4. Ejecutar App

**En Android Studio:**

- Click en Run (▶️)
- Seleccionar emulador o dispositivo físico
- Esperar instalación

**Credenciales de prueba:**

- Email: `admin@tecmade.com`
- Password: `admin123`

### Funcionalidades Implementadas

✅ **Login** con persistencia de sesión (DataStore)  
✅ **Listado de stock** con actualización manual  
✅ **Movimientos de stock** (agregar/restar cantidad)  
✅ **Manejo de errores** robusto (no crashea sin conexión)  
✅ **Logout** con limpieza de sesión  
✅ **Arquitectura MVVM** + Clean Architecture  
✅ **Material 3** con soporte tema claro/oscuro  
✅ **Versión TABLET** con layout adaptativo (dos paneles en horizontal)

### Stack Tecnológico

- **Lenguaje:** Kotlin 2.1.0
- **UI:** Jetpack Compose + Material 3
- **Networking:** Retrofit 2.11.0 + OkHttp 5.3.2
- **Persistencia:** DataStore Preferences 1.2.0
- **Navegación:** Navigation Compose 2.9.6
- **Async:** Coroutines 1.10.2 + Flow
- **Arquitectura:** MVVM + Clean Architecture + Repository Pattern

### Soporte para Tablets

La aplicación detecta automáticamente el tamaño de pantalla y se adapta:

**Phone (o Tablet en vertical):**

- Lista de stock en pantalla completa
- Click en artículo → Dialog de movimiento

**Tablet en horizontal (≥600dp):**

- Lista de stock (40% izquierda)
- Panel de detalle (60% derecha)
- Selección visual del artículo activo
- Sin dialog, todo visible simultáneamente

---

## 🗄️ MySQL Avanzado

### Sistema de Embalado (2 puntos)

Sistema completo para gestión de series y bultos con estructura recursiva.

**Archivo:** `database/embalado.sql`

#### Características principales:

**Tablas:**

- `series`: Productos con código AAA999 (3 letras + 3 números)
- `bultos`: Cajas con etiqueta 999AAA (3 números + 3 letras)
- `series_bultos`: Relación series → bultos
- `bultos_bultos`: Relación recursiva (bultos dentro de bultos)
- `historial_movimientos`: Log automático de cambios

**Funciones autonuméricas:**

- `GenerarSerie()`: Genera códigos AAA999 (capacidad: 1 millón)
- `GenerarEtiquetaBulto()`: Genera códigos 999AAA (capacidad: 1 millón)

**Procedimientos almacenados (10):**

1. `CrearSerie()` - Alta de serie
2. `CrearBulto()` - Alta de bulto
3. `AsignarSerieABulto()` - Asignar serie a bulto
4. `AsignarBultoABulto()` - Meter bulto dentro de otro bulto
5. `MigrarSerie()` - Mover serie entre bultos
6. `EliminarAsignacionSerie()` - Quitar serie de bulto
7. `EliminarAsignacionBulto()` - Quitar bulto de otro bulto
8. `ObtenerUltimoBultoDeSerie()` - Buscar dónde está una serie
9. `ObtenerSeriesEnBulto()` - Ver todas las series en un bulto (recursivo)
10. `ObtenerJerarquiaBultos()` - Ver jerarquía completa de bultos (recursivo)

**Triggers (4):**

- Registro automático en historial de todos los movimientos

#### Ejemplos de uso:

```sql
-- Crear una serie
CALL CrearSerie('Producto X - Lote 1', @id_serie, @codigo_serie);

-- Crear un bulto
CALL CrearBulto('Caja Principal A', @id_bulto, @etiqueta);

-- Asignar serie a bulto
CALL AsignarSerieABulto(1, 1);

-- Meter bulto dentro de otro bulto
CALL AsignarBultoABulto(1, 2);  -- Bulto 2 dentro de Bulto 1

-- Ver todas las series en un bulto (incluyendo bultos internos)
CALL ObtenerSeriesEnBulto(1);

-- Ver jerarquía de bultos recursivamente
CALL ObtenerJerarquiaBultos(1);
```

---

### Sistema de Orders/Links (2 puntos)

Sistema de órdenes enlazadas que permite vincular órdenes en secuencias.

**Archivo:** `database/orders.sql`

#### Características principales:

**Tablas:**

- `Orders`: Almacena órdenes (OrderId, OrderNo)
- `links`: Relaciona órdenes (OrderId, prevOrderId)

**Consultas requeridas (4):**

1. `GetPrevNextOrder()` - Obtener orden previa y siguiente de una orden
2. `InitialOrders` (view) - Órdenes iniciales (sin orden previa)
3. `FinalOrders` (view) - Órdenes finales (sin orden siguiente)
4. `OrphanOrders` (view) - Órdenes huérfanas (sin enlaces)

**Consulta adicional (bonus):**

- `GetAllChains()` - Ver todas las cadenas de órdenes con recursión (CTE)

#### Ejemplos de uso:

```sql
-- Ver orden previa y siguiente
CALL GetPrevNextOrder('ORD-003');

-- Ver órdenes iniciales
SELECT * FROM InitialOrders;

-- Ver órdenes finales
SELECT * FROM FinalOrders;

-- Ver órdenes huérfanas
SELECT * FROM OrphanOrders;

-- Ver todas las cadenas completas
CALL GetAllChains();
```

---

## 📡 API Endpoints

### Autenticación

#### POST `/api/login`

Autenticar usuario y obtener token.

**Request:**

```json
{
  "email": "admin@tecmade.com",
  "password": "admin123"
}
```

**Response (200 OK):**

```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "email": "admin@tecmade.com",
    "legajo": null
  }
}
```

**Response (401 Unauthorized):**

```json
{
  "error": "Credenciales inválidas"
}
```

---

### Stock (requieren autenticación)

#### GET `/api/stock`

Obtener listado de stock.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200 OK):**

```json
[
  {
    "idstock": 1,
    "articulo": "Producto A",
    "cantidad": 150
  },
  {
    "idstock": 2,
    "articulo": "Producto B",
    "cantidad": 75
  }
]
```

**Response (401 Unauthorized):**

```json
{
  "error": "Token inválido o expirado"
}
```

---

#### POST `/api/stock/movimiento`

Realizar movimiento de stock (agregar/restar/crear/eliminar).

**Headers:**

```
Authorization: Bearer {token}
```

**Request:**

```json
{
  "articulo": "Producto A",
  "delta": 10
}
```

**Comportamiento:**

- **delta > 0**: Suma a la cantidad
- **delta < 0**: Resta a la cantidad
- **Si no existe + delta > 0**: Crea el artículo
- **Si cantidad llega a 0**: Elimina el artículo
- **No permite cantidades negativas**

**Response (200 OK):**

```json
{
  "success": true,
  "articulo": {
    "idstock": 1,
    "articulo": "Producto A",
    "cantidad": 160
  }
}
```

---

## 🧪 Testing

### Testing con cURL

#### macOS/Linux:

```bash
# 1. Login
TOKEN=$(curl -s -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@tecmade.com","password":"admin123"}' \
  | jq -r '.token')

# 2. Obtener stock
curl -X GET http://localhost:8000/api/stock \
  -H "Authorization: Bearer $TOKEN"

# 3. Agregar 10 unidades
curl -X POST http://localhost:8000/api/stock/movimiento \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"articulo":"Producto A","delta":10}'

# 4. Restar 5 unidades
curl -X POST http://localhost:8000/api/stock/movimiento \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"articulo":"Producto A","delta":-5}'
```

#### Windows (PowerShell):

```powershell
# 1. Login
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"email":"admin@tecmade.com","password":"admin123"}'
$token = $response.token

# 2. Obtener stock
Invoke-RestMethod -Uri "http://localhost:8000/api/stock" -Method GET -Headers @{"Authorization"="Bearer $token"}

# 3. Agregar 10 unidades
Invoke-RestMethod -Uri "http://localhost:8000/api/stock/movimiento" -Method POST -Headers @{"Authorization"="Bearer $token";"Content-Type"="application/json"} -Body '{"articulo":"Producto A","delta":10}'
```

### Testing MySQL Avanzado

#### macOS (MAMP):

```bash
# Conectar a MySQL
/Applications/MAMP/Library/bin/mysql -u root -proot tecmade_db

# Probar sistema de embalado
CALL CrearSerie('Test Serie', @id, @codigo);
CALL CrearBulto('Test Bulto', @id_b, @etiqueta);
CALL AsignarSerieABulto(@id, @id_b);
CALL ObtenerSeriesEnBulto(@id_b);

# Probar sistema de órdenes
CALL GetPrevNextOrder('ORD-003');
SELECT * FROM InitialOrders;
SELECT * FROM FinalOrders;
```

#### Windows (XAMPP):

```cmd
# Conectar a MySQL
cd C:\xampp\mysql\bin
mysql.exe -u root tecmade_db

# Luego ejecutar los mismos comandos SQL
```

---

## 📝 Respuestas a Preguntas Teóricas

### 1. ¿Qué método(s) HTTP usaste para login y para obtener el listado? ¿Por qué?

**Respuesta:**

- **POST para login**: Porque estamos enviando credenciales sensibles en el body y el servidor crea un nuevo token de sesión (recurso). POST es el método apropiado para operaciones que crean recursos o tienen efectos secundarios. Además, POST no cachea las credenciales en logs o historial del navegador.
- **GET para listado**: Porque estamos solicitando datos sin modificar el estado del servidor. Es una operación idempotente y segura, características fundamentales de GET. Múltiples llamadas idénticas devuelven el mismo resultado.

### 2. ¿Cómo protegés credenciales durante el envío?

**Respuesta:**

- **HTTPS en producción**: Todas las comunicaciones deben usar TLS/SSL para cifrar datos en tránsito. Esto previene ataques man-in-the-middle.
- **Hash en servidor**: Las contraseñas nunca se almacenan en texto plano, solo su hash usando `password_hash()` con bcrypt (algoritmo de costo adaptativo resistente a fuerza bruta).
- **No logging de credenciales**: Los sistemas de log nunca deben registrar contraseñas o tokens completos. En caso de logs, solo los últimos 4 caracteres del token.
- **Token Bearer**: Después del login, se usa un token JWT o de sesión en el header Authorization, evitando enviar credenciales repetidamente.
- **Validación de entrada**: Sanitización de inputs para prevenir inyección SQL y XSS.
- **Rate limiting**: Limitar intentos de login para prevenir ataques de fuerza bruta.

### 3. ¿Cómo evitás inyección SQL y qué validaciones aplicás del lado servidor?

**Respuesta:**

**Prevención de SQL Injection:**

- **Prepared Statements**: Uso exclusivo de consultas preparadas con PDO, separando completamente el código SQL de los datos del usuario. Los parámetros se escapan automáticamente.
- **No concatenación directa**: Nunca construir queries concatenando strings con datos del usuario.

**Validaciones de entrada:**

- **Validación de formato de email**: Uso de `filter_var($email, FILTER_VALIDATE_EMAIL)`
- **Validación de tipos de datos**: Verificar que `delta` sea numérico con `is_numeric()`
- **Sanitización de strings**: Uso de `htmlspecialchars()` para prevenir XSS
- **Validación de longitud de campos**: Limitar tamaño de inputs
- **Whitelist de caracteres**: Validar que solo contengan caracteres permitidos

**Validaciones de negocio:**

- **No permitir cantidades negativas en stock**: Validación antes de UPDATE
- **Verificar existencia de registros**: Comprobar que el artículo existe antes de operaciones
- **Validar que el token sea válido y no haya expirado**: Verificación en cada request protegido
- **Transacciones atómicas**: Uso de BEGIN/COMMIT para operaciones críticas

### 4. ¿Cómo manejarías expiración/renovación del token en un entorno productivo?

**Respuesta:**

**Estrategia de dos tokens:**

- **JWT con expiración**: Implementar tokens JWT con claim `exp` (ej: 15-60 minutos de vida para el access token).
- **Refresh tokens**: Sistema de dos tokens:
  - **Access token** (corta duración, 15-60 min): Para acceso a recursos protegidos
  - **Refresh token** (larga duración, 7-30 días): Almacenado en base de datos, para renovar access tokens

**Flujo de renovación:**

1. Cliente detecta que access token está por expirar (basándose en claim `exp`)
2. Envía refresh token a endpoint `POST /api/refresh`
3. Servidor valida refresh token contra BD (no revocado, no expirado)
4. Emite nuevo access token y opcionalmente nuevo refresh token
5. Invalida refresh token anterior (rotación)

**Implementación de seguridad:**

- **Endpoint de renovación**: `POST /api/refresh` que valida el refresh token y emite un nuevo access token
- **Revocación**: Mantener lista negra de tokens revocados en Redis (rápido) o DB para logout forzado
- **Rotación de refresh tokens**: Al renovar, emitir nuevo refresh token y invalidar el anterior (previene robo)
- **Almacenamiento seguro**:
  - Access token: memoria o sessionStorage (nunca localStorage)
  - Refresh token: httpOnly cookie (seguro contra XSS)
- **Detección de anomalías**: Registrar IP y user-agent, alertar en cambios sospechosos
- **Límite de sesiones**: Máximo N refresh tokens activos por usuario

**Mejoras adicionales:**

- **JWT Claims útiles**: `iat` (issued at), `exp` (expiration), `jti` (JWT ID único)
- **Sliding sessions**: Extender sesión automáticamente si el usuario está activo
- **Multi-device support**: Permitir múltiples refresh tokens simultáneos (móvil, web, tablet)
- **Revocación por dispositivo**: Poder invalidar sesiones específicas

---

## 🏗️ Arquitectura del Proyecto

### Backend (PHP)

```
MVC simplificado:
- Models: Clases para Usuario y Stock
- Controllers: API endpoints (login, stock, movimiento)
- Config: Database connection, constantes
```

### Android (MVVM + Clean Architecture)

```
Presentation Layer:
├── UI (Compose)
│   ├── LoginScreen
│   ├── StockListScreen (adaptativo)
│   └── StockDetailPane (tablet)
│
Domain Layer:
├── Models (StockItem, LoginRequest/Response)
│
Data Layer:
├── Repository (StockRepository)
├── Remote (ApiService, RetrofitInstance)
└── Local (TokenManager con DataStore)
```

### Base de Datos

```
- usuarios: Autenticación
- tokens: Sesiones activas
- stock: Inventario base
- series/bultos: Sistema de embalado recursivo
- Orders/links: Órdenes enlazadas
```

---

## 👨‍💻 Autor

**Alfredo Castillo** - Desarrollador Android  
Evaluación técnica para TECMADE S.A. - SITRAC  
Enero 2026

---

## 📄 Licencia

Este proyecto es de uso exclusivo para evaluación técnica.

---

## 🔗 Enlaces Útiles

- **Repositorio:** https://github.com/alexdevep7/evaluacion-tecmade-sitrac
- **Android Docs:** https://developer.android.com/compose
- **Retrofit:** https://square.github.io/retrofit/
- **Jetpack Compose:** https://developer.android.com/jetpack/compose
