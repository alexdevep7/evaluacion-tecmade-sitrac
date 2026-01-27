# 🚀 Guía de Instalación Rápida

## Para los Evaluadores

Esta es una guía paso a paso para ejecutar el proyecto completo.

---

## 📋 Pre-requisitos

- PHP 7.4+
- MySQL 5.7+
- Android Studio (para la app móvil)
- Git

---

## ⚡ Instalación en 5 pasos

### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/TU-USUARIO/evaluacion-tecmade-sitrac.git
cd evaluacion-tecmade-sitrac
```

### 2️⃣ Configurar Base de Datos

```bash
# Acceder a MySQL
mysql -u root -p

# Ejecutar scripts (desde la raíz del proyecto)
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql

# Salir de MySQL
exit
```

### 3️⃣ Configurar Backend

```bash
# Ir a la carpeta del backend
cd backend-php/config

# Copiar el archivo de configuración de ejemplo
cp database.example.php database.php

# Editar database.php y cambiar las credenciales
# DB_USER y DB_PASS con tus credenciales de MySQL
```

### 4️⃣ Levantar el Backend

```bash
# Desde la carpeta backend-php
cd backend-php
php -S localhost:8000
```

El backend estará disponible en: `http://localhost:8000`

### 5️⃣ Probar la API

**Opción A: Con cURL**
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@tecmade.com","password":"admin123"}'
```

**Opción B: Con Postman**
- Importar `docs/postman_collection.json`
- Ejecutar la request "1. Login"

---

## 📱 Android App (siguiente paso)

Ver instrucciones en `android-app/README.md` (próximamente)

---

## 🧪 Credenciales de Prueba

```
Email: admin@tecmade.com
Password: admin123
```

---

## ❓ Problemas Comunes

### "Database connection failed"
- Verificar que MySQL esté corriendo
- Verificar credenciales en `backend-php/config/database.php`

### "404 Not Found" en endpoints
- Asegurarse de que el servidor PHP esté corriendo
- Verificar la URL: `http://localhost:8000/api/login`

### No se puede importar la base de datos
```bash
# Verificar que los archivos SQL existan
ls database/

# Crear la base de datos manualmente
mysql -u root -p
CREATE DATABASE tecmade_db;
exit

# Volver a intentar
mysql -u root -p tecmade_db < database/schema.sql
mysql -u root -p tecmade_db < database/seed.sql
```

---

## 📞 Contacto

Alex - Evaluación TECMADE SITRAC
