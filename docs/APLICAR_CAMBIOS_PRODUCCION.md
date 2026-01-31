# Cómo Aplicar los Cambios en Producción

**Fecha:** 11 de enero de 2026  
**Versión:** 1.1.0

---

## Resumen de Cambios

Se han implementado nuevas funcionalidades en ApoloLMS:
1. Constructor de Cursos (nueva opción en menú)
2. Modelo de Lesson mejorado con soporte para múltiples tipos de contenido
3. Formulario de lección con generación de contenido con IA

---

## Pasos para Aplicar los Cambios

### Paso 1: Instalar Nuevas Dependencias

Primero, instala las nuevas dependencias agregadas en [`pubspec.yaml`](pubspec.yaml):

```bash
# En la raíz del proyecto
flutter pub get
```

Las nuevas dependencias son:
- `universal_html: ^2.2.4` - Para procesar HTML
- `youtube_player_flutter: ^9.1.1` - Para videos de YouTube
- `video_player: ^2.9.2` - Para videos locales
- `chewie: ^1.8.5` - Controles de video mejorados

### Paso 2: Verificar que Todo Compile

Antes de desplegar, verifica que la aplicación compile correctamente:

```bash
# Limpiar caché
flutter clean

# Obtener dependencias
flutter pub get

# Compilar para web en modo release
flutter build web --release
```

Si hay errores, resuélvelos antes de continuar.

### Paso 3: Probar Localmente (Opcional pero Recomendado)

Es recomendable probar la aplicación localmente antes de desplegar:

```bash
# Ejecutar en modo desarrollo
flutter run -d chrome
```

Verifica que:
- La nueva opción "Constructor" aparezca en el menú lateral
- El formulario de lección tenga las nuevas secciones
- No haya errores en la consola del navegador

### Paso 4: Desplegar a Firebase Hosting

Una vez verificado que todo funciona correctamente, despliega a producción:

```bash
# Desplegar solo hosting
firebase deploy --only hosting

# O desplegar todos los servicios
firebase deploy
```

### Paso 5: Verificar el Despliegue

1. Abre la URL de tu aplicación en producción:
   - `https://apololms.web.app`
   - `https://apololms.firebaseapp.com`

2. Verifica que:
   - La aplicación cargue correctamente
   - La nueva opción "Constructor" esté disponible en el menú
   - No haya errores en la consola del navegador (F12)

---

## Comandos Completos

### Comando de Despliegue Rápido

```bash
# Un solo comando para limpiar, obtener dependencias, compilar y desplegar
flutter clean && flutter pub get && flutter build web --release && firebase deploy --only hosting
```

### Comando con Mensaje de Despliegue

```bash
# Desplegar con mensaje descriptivo
firebase deploy --only hosting --message "v1.1.0 - Constructor de Cursos y soporte ampliado de contenido"
```

---

## Verificación Post-Despliegue

### Checklist de Verificación

- [ ] La aplicación carga sin errores
- [ ] La opción "Constructor" aparece en el menú lateral
- [ ] Al seleccionar un curso en Constructor, se muestra el campo de texto
- [ ] Al pegar el contenido del curso y hacer clic en "Parsear Contenido", se genera la estructura
- [ ] Al hacer clic en "Cargar Estructura", se carga a Firestore
- [ ] Al editar una lección, se muestran las nuevas secciones:
  - [ ] Tipo de contenido
  - [ ] Video URL
  - [ ] Video de YouTube
  - [ ] Documentos y archivos
  - [ ] Generación de contenido con IA
- [ ] No hay errores en la consola del navegador

---

## Solución de Problemas

### Problema: Error al compilar

**Síntoma:** Errores de compilación después de agregar las nuevas dependencias.

**Solución:**
```bash
# Limpiar completamente
flutter clean
flutter pub cache repair

# Volver a obtener dependencias
flutter pub get

# Compilar nuevamente
flutter build web --release
```

### Problema: La nueva opción no aparece en el menú

**Síntoma:** Después del despliegue, la opción "Constructor" no aparece.

**Solución:**
1. Verifica que [`lib/configs/constants.dart`](lib/configs/constants.dart) tenga la entrada correcta:
```dart
const Map<int, List<dynamic>> menuList = {
  0: ['Panel de Control', LineIcons.pieChart],
  1: ['Estudiantes', LineIcons.userGraduate],
  2: ['Cursos', LineIcons.book],
  3: ['Constructor', LineIcons.cogs],  // ← Esta línea
  // ...
};
```

2. Verifica que [`lib/pages/home.dart`](lib/pages/home.dart) incluya `CourseBuilderTab`:
```dart
final List<Widget> _tabList = const [
  Dashboard(),
  StudentsTab(),
  Courses(),
  CourseBuilderTab(),  // ← Esta línea
  // ...
];
```

3. Limpia el caché del navegador y recarga la página.

### Problema: Error al subir documentos

**Síntoma:** Error al intentar subir archivos en el formulario de lección.

**Solución:**
1. Verifica que Firebase Storage esté habilitado en Firebase Console
2. Verifica las reglas de seguridad de Storage:
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

3. Verifica que el usuario tenga permisos de escritura.

### Problema: Error al generar contenido con IA

**Síntoma:** Error al intentar generar contenido con Google Gemini.

**Solución:**
1. Verifica que la API Key de Gemini esté configurada en [`lib/configs/app_config.dart`](lib/configs/app_config.dart):
```dart
static const String geminiApiKey = 'TU_API_KEY';
```

2. Verifica que la API Key sea válida y tenga créditos disponibles.

3. Verifica que no haya errores en la consola del navegador.

### Problema: El Constructor no parsea el contenido

**Síntoma:** Al pegar el contenido del curso y hacer clic en "Parsear Contenido", no se genera la estructura.

**Solución:**
1. Verifica que el formato del contenido sea correcto:
   - Los niveles deben empezar con "Nivel" (ej: "Nivel Básico", "Nivel Intermedio", "Nivel Avanzado")
   - Los módulos deben empezar con "- Módulo X:" (ej: "- Módulo 1: Fundamentos del Portugués")
   - Las lecciones deben empezar con "-" (ej: "- Saludos y presentaciones")

2. Ejemplo de formato correcto:
```
Nivel Básico

- Módulo 1: Fundamentos del Portugués
- Saludos y presentaciones
- El alfabeto portugués y pronunciación básica
- Números, colores y vocabulario esencial

- Módulo 2: Ampliando el Vocabulario y la Gramática
- Verbos irregulares comunes en presente
- Preposiciones de lugar y tiempo
```

3. Verifica la consola del navegador (F12) para ver mensajes de error específicos.

---

## Despliegue Automatizado (Opcional)

Si deseas automatizar el despliegue, puedes usar GitHub Actions.

### Crear archivo `.github/workflows/deploy.yml`

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

### Configurar el Token de Firebase

```bash
# Generar token de Firebase
firebase login:ci

# Copiar el token y agregarlo como secreto en GitHub
# Settings → Secrets and variables → Actions → New repository secret
# Name: FIREBASE_TOKEN
# Value: [tu token]
```

---

## Monitoreo Post-Despliegue

### Verificar Logs en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Hosting** → **Logs**
4. Revisa los logs para detectar errores

### Verificar Analytics

1. Ve a **Analytics** → **Eventos en tiempo real**
2. Verifica que los usuarios estén interactuando con la aplicación
3. Revisa los eventos personalizados si los hay

---

## Rollback (Revertir Cambios)

Si necesitas revertir a una versión anterior:

### Opción 1: Desplegar versión anterior

```bash
# Desplegar una versión específica
firebase hosting:rollback
```

### Opción 2: Usar Canales de Preview

```bash
# Crear un canal de preview
firebase hosting:channel:deploy preview --expires 7d

# Promover el canal a producción
firebase hosting:channel:release preview
```

### Opción 3: Revertir código

```bash
# Revertir al commit anterior
git revert HEAD

# Desplegar nuevamente
firebase deploy --only hosting
```

---

## Comandos Útiles

### Firebase

```bash
# Verificar proyectos
firebase projects:list

# Verificar configuración de hosting
firebase hosting:sites:default:config

# Ver archivos desplegados
firebase hosting:sites:default:files:list

# Ver canales de despliegue
firebase hosting:channel:list

# Rollback
firebase hosting:rollback
```

### Flutter

```bash
# Verificar versión
flutter --version

# Verificar dependencias
flutter doctor

# Limpiar caché
flutter clean

# Obtener dependencias
flutter pub get

# Compilar
flutter build web --release

# Ejecutar
flutter run -d chrome
```

---

## Recursos Adicionales

- [Documentación de Firebase Hosting](https://firebase.google.com/docs/hosting)
- [Documentación de Flutter Web](https://flutter.dev/web)
- [Guía de Despliegue Completa](GUIA_DESPLEGUE_COMPLETA.md)
- [Checklist de Despliegue](CHECKLIST_DESPLEGUE.md)
- [Documentación de Nuevas Funcionalidades](NUEVAS_FUNCIONALIDADES.md)

---

## Soporte

Si encuentras problemas:

1. Revisa los logs en Firebase Console
2. Verifica la consola del navegador (F12)
3. Consulta la documentación en [`docs/`](docs/)
4. Revisa el código fuente en [`lib/`](lib/)

---

**Fin del Documento**
