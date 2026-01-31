# Configuración de la API Key de Gemini AI

## ⚠️ Problema Actual

La aplicación muestra el error: **"API key not valid. Please pass a valid API key."**

Esto se debe a que la API key hardcoded en el código no es válida o está expirada.

## ✅ Solución

### Opción 1: Configurar desde la Interfaz Web (Recomendado)

1. **Obtén tu API Key de Gemini:**
   - Ve a [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Inicia sesión con tu cuenta de Google
   - Haz clic en "Get API Key" o "Create API Key"
   - Copia la clave generada

2. **Configura en la aplicación:**
   - Accede a la aplicación web: https://apololms.web.app
   - Inicia sesión como administrador
   - Ve a **Configuración** (Settings) en el menú lateral
   - Busca el campo **"Gemini API Key"**
   - Pega tu clave API
   - Haz clic en **"Guardar Cambios"**

3. **Verifica:**
   - Ve a cualquier lección
   - Haz clic en el botón **"Generar con IA"** ⭐
   - Debería generar contenido exitosamente

---

### Opción 2: Configurar directamente en Firebase Console

1. **Accede a Firestore:**
   - Ve a [Firebase Console](https://console.firebase.google.com/)
   - Selecciona el proyecto **apololms**
   - Ve a **Firestore Database**

2. **Crea/Edita el documento de configuración:**
   - Busca la colección `app_settings`
   - Si existe un documento, edítalo
   - Si no existe, crea un nuevo documento con ID `app_settings`
   - Agrega el campo:
     ```
     Campo: gemini_api_key
     Tipo: string
     Valor: tu_api_key_aqui
     ```

3. **Guarda** y recarga la aplicación

---

### Opción 3: Configurar en el Código (No Recomendado)

Si prefieres hardcodear la clave (solo para desarrollo/testing):

1. Edita `lib/configs/app_config.dart`:
   ```dart
   static const String geminiApiKey = 'TU_API_KEY_AQUI';
   ```

2. Recompila y despliega:
   ```bash
   flutter build web --release
   firebase deploy
   ```

⚠️ **Advertencia:** No subas la API key a repositorios públicos.

---

## 🔑 Obtener una API Key Gratuita

### Google AI Studio (Gemini)

1. Ve a: https://makersuite.google.com/app/apikey
2. Haz clic en "Create API Key"
3. Selecciona tu proyecto de Google Cloud (o crea uno nuevo)
4. Copia la clave generada

### Límites Gratuitos de Gemini 1.5 Flash:
- ✅ 15 solicitudes por minuto
- ✅ 1 millón de tokens por minuto
- ✅ 1,500 solicitudes por día
- ✅ Completamente gratis

---

## 🧪 Probar la Integración

### Desde la interfaz:

1. Navega a **Jerarquía** → Selecciona un curso
2. Abre un módulo → **"Ver Lecciones"**
3. Edita cualquier lección
4. Haz clic en **"Generar con IA"** ⭐
5. Espera ~5 segundos
6. El contenido se generará automáticamente en HTML

### Contenido Generado:

El sistema genera:
- Introducción al tema
- Conceptos clave
- Ejemplos prácticos
- Ejercicios sugeridos
- Todo en formato HTML listo para mostrar

---

## 🐛 Solución de Problemas

### Error: "API key not valid"
✅ **Solución:** Obtén una nueva API key de Google AI Studio y actualízala en Settings

### Error: "La clave API de Gemini no está configurada"
✅ **Solución:** Configura la API key siguiendo la Opción 1 o 2 de arriba

### Error: "Quota exceeded"
✅ **Solución:** Has excedido el límite gratuito. Espera 24 horas o actualiza a un plan de pago

### Error: "assets/images/gemini.png not found"
✅ **Solución:** Ya corregido - ahora usa un ícono de Material Icons en lugar de imagen

---

## 📊 Flujo de Obtención de API Key

```
Aplicación Web (LessonEditorDialog)
    ↓
    ├─→ Intenta obtener desde Firebase Settings
    │       ↓
    │   app_settings.gemini_api_key
    │       ↓
    └─→ Si no existe, usa AppConfig.geminiApiKey (fallback)
            ↓
        AiContentService
            ↓
        Google Gemini API
```

---

## 🔒 Seguridad

### Buenas Prácticas:

1. ✅ **Guarda la API key en Firebase Settings** (no en código)
2. ✅ **Usa reglas de seguridad de Firestore:**
   ```javascript
   match /app_settings/{document} {
     allow read: if request.auth != null;
     allow write: if request.auth.token.role == 'admin';
   }
   ```
3. ✅ **Limita el acceso al botón de IA solo a administradores/autores**
4. ❌ **Nunca subas la API key a GitHub**

---

## 📝 Configuración Recomendada en Firestore

Estructura del documento `app_settings`:

```json
{
  "name": "IDECAP Idiomas",
  "email": "admin@idecap.com",
  "website": "https://apololms.web.app",
  "gemini_api_key": "AIzaSy...",
  "privacy_policy": "https://...",
  "terms_of_service": "https://...",
  "facebook": "https://facebook.com/...",
  "youtube": "https://youtube.com/...",
  "updated_at": "2026-01-05T10:30:00Z"
}
```

---

## ✨ Funciones que Usan la API Key

1. **Generación de Contenido de Lecciones**
   - LessonEditorDialog → "Generar con IA"
   - Genera descripciones detalladas en HTML

2. **Generación de Cuestionarios** (futuro)
   - Genera preguntas de opción múltiple automáticamente

3. **Traducción Automática** (futuro)
   - Traduce contenido entre idiomas

---

## 🎯 Próximos Pasos

Una vez configurada la API key correctamente:

1. ✅ Prueba generando contenido para varias lecciones
2. ✅ Ajusta los prompts en `AiContentService` según tus necesidades
3. ✅ Considera implementar caché para no regenerar el mismo contenido
4. ✅ Monitorea el uso de la API para evitar exceder límites

---

**¿Necesitas más ayuda?**
- Consulta la documentación de Google AI: https://ai.google.dev/docs
- Revisa el código en: `lib/services/ai_content_service.dart`
- Contacta al equipo de desarrollo

---

**Fecha:** 5 de Enero de 2026  
**Versión:** 2.0.1
