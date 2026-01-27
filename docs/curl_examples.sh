# TECMADE - SITRAC: Ejemplos de prueba con cURL
# Desarrollador: Alex

# Variables
BASE_URL="http://localhost:8000"

# =====================================================
# 1. LOGIN
# =====================================================
echo "=== 1. LOGIN ==="
curl -X POST "$BASE_URL/api/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@tecmade.com",
    "password": "admin123"
  }'

# Guardar el token retornado en una variable:
# TOKEN="tu_token_aqui"

echo -e "\n\n"

# =====================================================
# 2. OBTENER STOCK (requiere token)
# =====================================================
echo "=== 2. OBTENER STOCK ==="
# Reemplazar YOUR_TOKEN_HERE con el token obtenido del login
curl -X GET "$BASE_URL/api/stock" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

echo -e "\n\n"

# =====================================================
# 3. AGREGAR STOCK (delta positivo)
# =====================================================
echo "=== 3. AGREGAR STOCK ==="
curl -X POST "$BASE_URL/api/stock/movimiento" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "articulo": "Tornillo M8x20",
    "delta": 10
  }'

echo -e "\n\n"

# =====================================================
# 4. REDUCIR STOCK (delta negativo)
# =====================================================
echo "=== 4. REDUCIR STOCK ==="
curl -X POST "$BASE_URL/api/stock/movimiento" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "articulo": "Tornillo M8x20",
    "delta": -5
  }'

echo -e "\n\n"

# =====================================================
# 5. CREAR NUEVO ARTÍCULO (delta positivo + artículo no existe)
# =====================================================
echo "=== 5. CREAR NUEVO ARTÍCULO ==="
curl -X POST "$BASE_URL/api/stock/movimiento" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "articulo": "Nuevo Producto XYZ",
    "delta": 50
  }'

echo -e "\n\n"

# =====================================================
# 6. ELIMINAR ARTÍCULO (llevar cantidad a 0)
# =====================================================
echo "=== 6. ELIMINAR ARTÍCULO (cantidad a 0) ==="
# Primero verificar cuántas unidades tiene "Grasa lubricante"
# Tiene 30 según seed.sql
curl -X POST "$BASE_URL/api/stock/movimiento" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "articulo": "Grasa lubricante (tubos)",
    "delta": -30
  }'

echo -e "\n\n"

# =====================================================
# CASOS DE ERROR
# =====================================================

# Error 1: Login con credenciales inválidas
echo "=== ERROR 1: LOGIN INVÁLIDO (debe retornar 401) ==="
curl -X POST "$BASE_URL/api/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "wrong@tecmade.com",
    "password": "wrongpassword"
  }'

echo -e "\n\n"

# Error 2: Acceso sin token
echo "=== ERROR 2: SIN TOKEN (debe retornar 401) ==="
curl -X GET "$BASE_URL/api/stock"

echo -e "\n\n"

# Error 3: Token inválido
echo "=== ERROR 3: TOKEN INVÁLIDO (debe retornar 401) ==="
curl -X GET "$BASE_URL/api/stock" \
  -H "Authorization: Bearer token_falso_123"

echo -e "\n\n"

# Error 4: Intentar cantidad negativa
echo "=== ERROR 4: CANTIDAD NEGATIVA (debe retornar 400) ==="
curl -X POST "$BASE_URL/api/stock/movimiento" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "articulo": "Tornillo M8x20",
    "delta": -99999
  }'

echo -e "\n\n"

# Error 5: Crear artículo con delta negativo o cero
echo "=== ERROR 5: CREAR CON DELTA NEGATIVO (debe retornar 400) ==="
curl -X POST "$BASE_URL/api/stock/movimiento" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "articulo": "Artículo Inexistente",
    "delta": -10
  }'

echo -e "\n\n"
