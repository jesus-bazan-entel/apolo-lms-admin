# Solución Rápida - Actualizar Lecciones

Las lecciones ya fueron creadas pero les falta el campo `lesson_body` que requiere el editor HTML.

## Opción 1: Eliminar y Recargar (Más Fácil)

1. Ve a Firebase Console: https://console.firebase.google.com/project/apololms/firestore
2. Navega a: `courses` → (tu curso de Portugues) → `levels`
3. Elimina cada nivel (esto eliminará todo en cascada)
4. En la app, haz clic de nuevo en "Cargar Datos Portugués"

## Opción 2: Actualizar Manualmente en Firebase Console

1. Ve a Firebase Console
2. Navega a cada lección en: `courses/{courseId}/levels/{levelId}/modules/{moduleId}/sections/{sectionId}/lessons/{lessonId}`
3. Agrega estos campos a cada lección:
   - `lesson_body`: `<p>Contenido pendiente</p>`
   - `duration`: `0`
   - `is_free`: `false`
   - `thumbnail_url`: ``
   - `vimeo_video_id`: ``

## Opción 3: Hot Reload y Recargar (Recomendado)

1. Presiona `R` en la terminal de Flutter para hot restart
2. Elimina los niveles desde la UI de Hierarchy (botón de eliminar en cada nivel)
3. Haz clic de nuevo en "Cargar Datos Portugués"

Ya actualicé el código para que la próxima carga incluya todos los campos necesarios.
