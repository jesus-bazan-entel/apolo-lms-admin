# Guía Completa de Despliegue en Firebase y Publicación Web

**Versión:** 1.0  
**Fecha:** 11 de Enero de 2026  
**Proyecto:** ApoloLMS (IDECAP Idiomas)

---

## Tabla de Contenidos

1. [Prerrequisitos](#prerrequisitos)
2. [Configuración Inicial del Proyecto](#configuración-inicial-del-proyecto)
3. [Configuración de Firebase](#configuración-de-firebase)
4. [Compilación de la Aplicación](#compilación-de-la-aplicación)
5. [Despliegue en Firebase Hosting](#despliegue-en-firebase-hosting)
6. [Configuración de Dominio Personalizado](#configuración-de-dominio-personalizado)
7. [Actualización del Despliegue](#actualización-del-despliegue)
8. [Solución de Problemas](#solución-de-problemas)
9. [Buenas Prácticas](#buenas-prácticas)

---

## Prerrequisitos

### 1. Instalar Flutter SDK

**Windows:**
```powershell
# Descargar Flutter desde: https://flutter.dev/docs/get-started/install/windows
# Extraer en C:\flutter
# Agregar C:\flutter\bin al PATH del sistema

# Verificar instalación
flutter doctor
```

**macOS:**
```bash
# Usar Homebrew
brew install --cask flutter

# Verificar instalación
flutter doctor
```

**Linux:**
```bash
# Descargar y extraer
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
tar xf flutter_linux_3.24.5-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Verificar instalación
flutter doctor
```

### 2. Instalar Node.js y npm

**Windows:**
```powershell
# Descargar desde: https://nodejs.org/
# Instalar la versión LTS recomendada

# Verificar instalación
node --version
npm --version
```

**macOS/Linux:**
```bash
# Usar Homebrew
brew install node

# Verificar instalación
node --version
npm --version
```

### 3. Instalar Firebase CLI

```bash
# Instalar globalmente
npm install -g firebase-tools

# Verificar instalación
firebase --version

# Iniciar sesión en Firebase
firebase login
```

### 4. Instalar FlutterFire CLI

```bash
# Instalar globalmente
dart pub global activate flutterfire_cli

# Verificar instalación
flutterfire --version
```

---

## Configuración Inicial del Proyecto

### 1. Clonar el Repositorio

```bash
# Clonar el repositorio
git clone https://github.com/jesus-bazan-entel/apolo-lms-admin.git

# Entrar al directorio del proyecto
cd apolo-lms-admin
```

### 2. Instalar Dependencias de Flutter

```bash
# Limpiar caché anterior
flutter clean

# Obtener dependencias
flutter pub get

# Verificar que no haya errores
flutter doctor
```

### 3. Probar la Aplicación Localmente

```bash
# Ejecutar en modo desarrollo
flutter run -d chrome

# O compilar para web y abrir manualmente
flutter build web --debug
# Luego abrir build/web/index.html en el navegador
```

---

## Configuración de Firebase

### Paso 1: Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en **"Agregar proyecto"**
3. Ingresa el nombre del proyecto (ej: `apololms-prod`)
4. Opcionalmente, habilita Google Analytics
5. Haz clic en **"Crear proyecto"**

### Paso 2: Habilitar Servicios Necesarios

#### Authentication
1. En el menú izquierdo, ve a **Authentication** → **Comenzar**
2. Habilita el proveedor **Email/Password**
3. Habilita el proveedor **Google** (para Google Sign-In)
4. Configura el dominio autorizado:
   - Agrega `localhost` para desarrollo
   - Agrega `tu-proyecto.web.app` para producción

#### Firestore Database
1. Ve a **Firestore Database** → **Crear base de datos**
2. Selecciona la ubicación (ej: `nam5` (us-central) o la más cercana a tus usuarios)
3. Selecciona **Modo de producción** o **Modo de prueba**
4. Configura las reglas de seguridad:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas de ejemplo - AJUSTAR SEGÚN NECESIDAD
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.token.email == 'admin@idecap.com' || 
         request.auth.token.email == 'author@idecap.com');
    }
  }
}
```

#### Storage
1. Ve a **Storage** → **Comenzar**
2. Selecciona **Modo de producción** o **Modo de prueba**
3. Configura las reglas de seguridad:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

#### Cloud Messaging (FCM)
1. Ve a **Cloud Messaging** → **Comenzar**
2. Configura las credenciales de API
3. Copia la clave del servidor para usar en tu aplicación

### Paso 3: Conectar la App con Firebase

#### Opción A: Usar FlutterFire CLI (Recomendado)

```bash
# Ejecutar en la raíz del proyecto
flutterfire configure

# Seleccionar:
# - Tu proyecto de Firebase
# - Plataforma: Web
# - Confirmar sobrescribir firebase_options.dart
```

Esto generará/actualizará el archivo [`lib/firebase_options.dart`](lib/firebase_options.dart) con las credenciales correctas.

#### Opción B: Configuración Manual

1. Ve a **Configuración del proyecto** → **General** → **Tus apps**
2. Agrega una app **Web**
3. Copia el objeto `firebaseConfig`
4. Actualiza [`lib/firebase_options.dart`](lib/firebase_options.dart):

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'TU_API_KEY',
  appId: 'TU_APP_ID',
  messagingSenderId: 'TU_MESSAGING_SENDER_ID',
  projectId: 'TU_PROJECT_ID',
  authDomain: 'TU_PROJECT_ID.firebaseapp.com',
  storageBucket: 'TU_PROJECT_ID.appspot.com',
  measurementId: 'TU_MEASUREMENT_ID',
);
```

### Paso 4: Configurar Firebase Hosting

```bash
# Inicializar hosting
firebase init hosting

# Responder a las preguntas:
# ? What do you want to use as your public directory? build/web
# ? Configure as a single-page app? Yes
# ? Set up automatic builds with GitHub? No (por ahora)
```

Esto creará/actualizará el archivo [`firebase.json`](firebase.json):

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

---

## Compilación de la Aplicación

### Paso 1: Configurar Variables de Entorno

Si tu aplicación usa variables de entorno, configúralas antes de compilar:

```bash
# Windows PowerShell
$env:GEMINI_API_KEY="TU_API_KEY"

# macOS/Linux
export GEMINI_API_KEY="TU_API_KEY"
```

O actualiza directamente en [`lib/configs/app_config.dart`](lib/configs/app_config.dart):

```dart
class AppConfig {
  static const String appName = 'IDECAP Idiomas';
  static const String geminiApiKey = 'TU_API_KEY';
  // ... otras configuraciones
}
```

### Paso 2: Compilar para Producción

```bash
# Limpiar caché
flutter clean

# Obtener dependencias
flutter pub get

# Compilar para web en modo release
flutter build web --release
```

**Opciones adicionales de compilación:**

```bash
# Compilar con renderizado HTML (mejor compatibilidad)
flutter build web --release --web-renderer html

# Compilar con renderizado Canvas (mejor rendimiento)
flutter build web --release --web-renderer canvaskit

# Compilar con tamaño de fuente base personalizado
flutter build web --release --dart-define=FLUTTER_WEB_AUTO_DETECT=false --dart-define=FLUTTER_WEB_USE_SKIA=true
```

### Paso 3: Verificar la Compilación

```bash
# Verificar que se creó la carpeta build/web
ls build/web

# Deberías ver archivos como:
# - index.html
# - main.dart.js
# - assets/
# - canvaskit/
# - flutter.js
```

### Paso 4: Probar Localmente (Opcional)

```bash
# Usar un servidor local para probar
cd build/web
python -m http.server 8080

# O usar Node.js
npx serve .

# Luego abrir http://localhost:8080 en el navegador
```

---

## Despliegue en Firebase Hosting

### Paso 1: Verificar Configuración de Firebase

```bash
# Verificar que estás logueado
firebase login:list

# Verificar proyecto actual
firebase projects:list

# Verificar configuración de hosting
firebase hosting:sites:default:config
```

### Paso 2: Desplegar la Aplicación

```bash
# Desplegar todos los servicios (hosting, firestore, storage, etc.)
firebase deploy

# O desplegar solo hosting
firebase deploy --only hosting

# Desplegar con mensaje de despliegue
firebase deploy --message "Versión 1.0.5 - Actualización de dashboard"
```

### Paso 3: Verificar el Despliegue

```bash
# Verificar archivos desplegados
firebase hosting:sites:default:files:list

# Verificar canales de despliegue
firebase hosting:channel:list
```

### Paso 4: Acceder a la Aplicación

Firebase te proporcionará dos URLs:

1. **URL predeterminada:** `https://tu-proyecto.web.app`
2. **URL personalizada:** `https://tu-proyecto.firebaseapp.com`

Ambas URLs apuntan al mismo sitio.

### Paso 5: Verificar en el Navegador

1. Abre la URL en tu navegador
2. Verifica que la aplicación cargue correctamente
3. Abre las herramientas de desarrollador (F12) para verificar errores en la consola
4. Prueba el inicio de sesión y las funcionalidades principales

---

## Configuración de Dominio Personalizado

### Paso 1: Comprar un Dominio

Compra un dominio en un registrador como:
- Google Domains
- Namecheap
- GoDaddy
- Cloudflare Registrar

### Paso 2: Configurar DNS

En tu registrador de dominios, agrega los siguientes registros DNS:

#### Para dominio principal (ej: `idecap-idiomas.com`)

| Tipo | Nombre | Valor | TTL |
|------|--------|-------|-----|
| A | @ | 199.36.158.100 | 3600 |
| AAAA | @ | 2600:1901:0:1d::1 | 3600 |

#### Para subdominio (ej: `admin.idecap-idiomas.com`)

| Tipo | Nombre | Valor | TTL |
|------|--------|-------|-----|
| A | admin | 199.36.158.100 | 3600 |
| AAAA | admin | 2600:1901:0:1d::1 | 3600 |

### Paso 3: Configurar en Firebase Console

1. Ve a **Hosting** → **Dominios personalizados**
2. Haz clic en **Agregar dominio personalizado**
3. Ingresa tu dominio (ej: `admin.idecap-idiomas.com`)
4. Firebase verificará la propiedad del dominio

### Paso 4: Verificar Propiedad del Dominio

Firebase te pedirá verificar la propiedad de una de estas formas:

#### Opción A: Registro TXT (Recomendada)

Agrega este registro TXT a tu DNS:

| Tipo | Nombre | Valor | TTL |
|------|--------|-------|-----|
| TXT | @ | firebase=proyecto-tu-proyecto | 3600 |

#### Opción B: Archivo HTML

1. Descarga el archivo de verificación que Firebase te proporciona
2. Sube el archivo a la raíz de tu hosting
3. Haz clic en **Verificar**

### Paso 5: Configurar SSL

Firebase proporciona certificados SSL gratuitos automáticamente. Una vez verificado el dominio:

1. Espera a que Firebase genere el certificado SSL (puede tomar hasta 24 horas)
2. Verifica que el candado de seguridad aparezca en tu dominio
3. Configura redirección HTTP a HTTPS (Firebase lo hace automáticamente)

### Paso 6: Actualizar Firebase Auth

Actualiza los dominios autorizados en Firebase Auth:

1. Ve a **Authentication** → **Configuración** → **Dominios autorizados**
2. Agrega tu dominio personalizado
3. Elimina `localhost` si ya no lo necesitas

---

## Actualización del Despliegue

### Flujo de Trabajo Recomendado

```bash
# 1. Hacer cambios en el código
# Editar archivos según sea necesario

# 2. Probar localmente
flutter run -d chrome

# 3. Compilar para producción
flutter clean
flutter pub get
flutter build web --release

# 4. Desplegar a Firebase
firebase deploy --only hosting --message "Descripción de cambios"

# 5. Verificar en el navegador
# Abrir la URL y probar funcionalidades
```

### Despliegue con Canales (Preview)

```bash
# Crear un canal de preview
firebase hosting:channel:deploy preview --expires 7d

# Esto crea una URL temporal para pruebas
# Ej: https://tu-proyecto--preview-abc123.web.app
```

### Despliegue Automatizado con GitHub Actions

Crea el archivo `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches:
      - main

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build web
        run: flutter build web --release
      
      - name: Deploy to Firebase
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only hosting
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

Para configurar el token:

```bash
# Generar token de Firebase
firebase login:ci

# Copiar el token y agregarlo como secreto en GitHub
# Settings → Secrets and variables → Actions → New repository secret
# Name: FIREBASE_TOKEN
# Value: [tu token]
```

---

## Solución de Problemas

### Problema 1: Pantalla blanca al cargar

**Causas posibles:**
- Error en la compilación
- Problema con las rutas
- Error de JavaScript

**Soluciones:**

```bash
# 1. Verificar errores en la consola del navegador (F12)

# 2. Recompilar con renderizado HTML
flutter build web --release --web-renderer html

# 3. Verificar que firebase.json tenga las rewrites correctas
cat firebase.json

# 4. Limpiar caché y recompilar
flutter clean
flutter pub get
flutter build web --release
```

### Problema 2: Error de autenticación

**Causas posibles:**
- Dominio no autorizado en Firebase Auth
- Configuración incorrecta de firebase_options.dart

**Soluciones:**

```bash
# 1. Verificar dominios autorizados en Firebase Console
# Authentication → Configuración → Dominios autorizados

# 2. Verificar configuración en firebase_options.dart
cat lib/firebase_options.dart

# 3. Reconfigurar con FlutterFire CLI
flutterfire configure
```

### Problema 3: Error al desplegar

**Causas posibles:**
- No estás logueado en Firebase
- Proyecto no configurado correctamente
- Permisos insuficientes

**Soluciones:**

```bash
# 1. Verificar login
firebase login:list

# 2. Re-login si es necesario
firebase login

# 3. Verificar proyecto actual
firebase projects:list

# 4. Verificar configuración
firebase use --project tu-proyecto-id
```

### Problema 4: Archivos no actualizados

**Causas posibles:**
- Caché del navegador
- Firebase CDN no actualizado

**Soluciones:**

```bash
# 1. Limpiar caché del navegador (Ctrl+Shift+Delete)

# 2. Forzar actualización con versión
firebase deploy --only hosting --message "v1.0.6 - Force cache refresh"

# 3. Agregar parámetros de caché en firebase.json
{
  "hosting": {
    "public": "build/web",
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache, no-store, must-revalidate"
          }
        ]
      }
    ]
  }
}
```

### Problema 5: Error de CORS

**Causas posibles:**
- Firebase Storage no configurado correctamente
- Reglas de seguridad restrictivas

**Soluciones:**

```javascript
// Actualizar reglas de Storage
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## Buenas Prácticas

### 1. Versionado

Usa versiones semánticas para tus despliegues:

```bash
# Formato: MAJOR.MINOR.PATCH
# MAJOR: Cambios incompatibles
# MINOR: Nuevas funcionalidades
# PATCH: Correcciones de errores

firebase deploy --only hosting --message "v1.2.3 - Nueva función de dashboard"
```

### 2. Testing

Siempre prueba antes de desplegar:

```bash
# 1. Probar en modo desarrollo
flutter run -d chrome

# 2. Probar compilación de producción localmente
flutter build web --release
cd build/web && python -m http.server 8080

# 3. Usar canales de preview
firebase hosting:channel:deploy preview
```

### 3. Monitoreo

Configura monitoreo y analytics:

```bash
# Habilitar Firebase Analytics
# Firebase Console → Analytics → Habilitar

# Verificar eventos en tiempo real
# Firebase Console → Analytics → Eventos en tiempo real
```

### 4. Backup

Haz backup de tu configuración:

```bash
# Exportar configuración de Firebase
firebase firestore:export --backup-path ./firestore-backup

# Exportar reglas de seguridad
firebase firestore:rules > firestore.rules.backup
firebase storage:rules > storage.rules.backup
```

### 5. Documentación

Mantén documentado cada despliegue:

```markdown
## Historial de Despliegues

| Fecha | Versión | Descripción | Autor |
|-------|---------|-------------|-------|
| 2026-01-11 | v1.0.5 | Actualización de dashboard | Juan Pérez |
| 2026-01-10 | v1.0.4 | Corrección de bugs | María García |
```

### 6. Seguridad

- Nunca commits API keys en el repositorio
- Usa variables de entorno para datos sensibles
- Configura reglas de seguridad restrictivas
- Habilita 2FA en tu cuenta de Firebase
- Revisa regularmente los logs de Firebase

---

## Comandos Útiles

### Firebase

```bash
# Login
firebase login
firebase login:ci

# Proyectos
firebase projects:list
firebase use --project project-id

# Hosting
firebase deploy --only hosting
firebase hosting:sites:default:files:list
firebase hosting:channel:list
firebase hosting:channel:deploy preview --expires 7d

# Firestore
firebase firestore:export --backup-path ./backup
firebase firestore:import ./backup

# Reglas
firebase firestore:rules
firebase storage:rules
```

### Flutter

```bash
# Limpieza
flutter clean

# Dependencias
flutter pub get
flutter pub upgrade

# Compilación
flutter build web --release
flutter build web --release --web-renderer html
flutter build web --release --web-renderer canvaskit

# Ejecución
flutter run -d chrome
flutter run -d edge
flutter run -d safari

# Doctor
flutter doctor
flutter doctor -v
```

---

## Recursos Adicionales

- [Documentación de Firebase Hosting](https://firebase.google.com/docs/hosting)
- [Documentación de Flutter Web](https://flutter.dev/web)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [FlutterFire Documentation](https://firebase.flutter.dev)

---

## Soporte

Si encuentras problemas:

1. Revisa los logs de Firebase Console
2. Verifica la consola del navegador (F12)
3. Consulta la documentación oficial
4. Busca en Stack Overflow con etiquetas `firebase`, `flutter`, `flutter-web`

---

**Fin de la Guía**