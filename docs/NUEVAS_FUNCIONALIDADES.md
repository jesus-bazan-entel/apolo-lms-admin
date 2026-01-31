# Nuevas Funcionalidades Implementadas

**Fecha:** 11 de Enero de 2026  
**Versión:** 1.1.0

---

## Resumen

Se han implementado nuevas funcionalidades para mejorar la gestión de cursos en ApoloLMS, incluyendo:

1. **Constructor de Cursos** - Nueva opción en el menú lateral para crear estructuras de cursos desde documentos Word
2. **Soporte Ampliado de Contenido** - El modelo de Lesson ahora soporta múltiples tipos de contenido
3. **Generación de Contenido con IA** - Integración con Google Gemini para generar contenido educativo

---

## 1. Constructor de Cursos

### Descripción
Nueva pestaña en el menú lateral que permite construir la estructura completa de un curso (niveles, módulos y lecciones) a partir de un documento Word (.docx).

### Archivos Creados/Modificados

| Archivo | Descripción |
|---------|-------------|
| [`lib/services/course_structure_parser.dart`](lib/services/course_structure_parser.dart) | Servicio para parsear documentos Word y extraer estructura de cursos |
| [`lib/tabs/admin_tabs/course_builder/course_builder_tab.dart`](lib/tabs/admin_tabs/course_builder/course_builder_tab.dart) | UI del Constructor de Cursos |
| [`lib/configs/constants.dart`](lib/configs/constants.dart) | Agregada opción "Constructor" al menú |
| [`lib/pages/home.dart`](lib/pages/home.dart) | Agregada CourseBuilderTab a la lista de pestañas |

### Funcionalidades

#### Parseo de Documentos Word
- Detecta automáticamente niveles (ej: "Nivel Básico", "Nivel Intermedio", "Nivel Avanzado")
- Detecta módulos (ej: "- Módulo 1: Fundamentos del Portugués")
- Detecta lecciones (ej: "- Saludos y presentaciones")
- Muestra progreso en tiempo real durante el parseo

#### Carga a Firestore
- Crea automáticamente la estructura jerárquica en Firestore
- Genera IDs consistentes para niveles, módulos y lecciones
- Crea secciones por defecto para cada módulo
- Muestra progreso detallado durante la carga

#### Interfaz de Usuario
- Vista de selección de cursos
- Vista de carga de documentos
- Vista de previsualización de estructura
- Panel de progreso en tiempo real

### Formato del Documento Word

El documento debe seguir este formato:

```
Nivel Básico

- Módulo 1: Fundamentos del Portugués
- Saludos y presentaciones
- El alfabeto portugués y pronunciación básica
- Números, colores y vocabulario esencial
...

- Módulo 2: Ampliando el Vocabulario y la Gramática
- Verbos irregulares comunes en presente
- Preposiciones de lugar y tiempo
...

Nivel Intermedio

- Módulo 3: Profundizando en la Gramática y la Cultura
- Pretérito perfecto simple
- Pretérito imperfecto
...
```

### Uso

1. Ir al menú lateral → **Constructor**
2. Seleccionar un curso existente
3. Hacer clic en **"Seleccionar Documento"**
4. Elegir un archivo .docx con la estructura del curso
5. Revisar la previsualización de la estructura
6. Hacer clic en **"Cargar Estructura"**

---

## 2. Modelo de Lesson Mejorado

### Descripción
El modelo [`Lesson`](lib/models/lesson.dart) ha sido actualizado para soportar múltiples tipos de contenido y materiales.

### Nuevos Modelos

#### LessonMaterial
Representa un material adjunto a una lección:

```dart
class LessonMaterial {
  final String id;
  final String name;
  final DocumentType type; // word, pdf, text, image, video
  final String url;
  final int? fileSize;
  final String? mimeType;
  final DateTime? uploadedAt;
}
```

#### YouTubeVideo
Representa un video de YouTube:

```dart
class YouTubeVideo {
  final String videoId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final int? duration;
  
  String get url => 'https://www.youtube.com/watch?v=$videoId';
  String get embedUrl => 'https://www.youtube.com/embed/$videoId';
}
```

#### LocalVideo
Representa un video local/subido:

```dart
class LocalVideo {
  final String url;
  final String? title;
  final String? description;
  final int? duration;
  final String? thumbnailUrl;
}
```

### Nuevos Campos en Lesson

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `lessonBody` | String? | Cuerpo de la lección en HTML |
| `materials` | List<LessonMaterial>? | Lista de materiales adjuntos |
| `youtubeVideo` | YouTubeVideo? | Video de YouTube |
| `localVideo` | LocalVideo? | Video local |
| `duration` | int | Duración en minutos |
| `isFree` | bool | Si la lección es gratuita |
| `thumbnailUrl` | String? | URL de la miniatura |
| `vimeoVideoId` | String? | ID de video de Vimeo |
| `createdAt` | DateTime? | Fecha de creación |
| `updatedAt` | DateTime? | Fecha de actualización |

### Nuevos Tipos de Contenido

| Tipo | Descripción |
|------|-------------|
| `video` | Video URL tradicional |
| `article` | Artículo de texto |
| `quiz` | Cuestionario |
| `document` | Documentos adjuntos |
| `youtube` | Video de YouTube |
| `mixed` | Contenido mixto |

### Métodos Útiles

```dart
// Verificar si tiene materiales
bool get hasMaterials

// Verificar si tiene video de YouTube
bool get hasYouTubeVideo

// Verificar si tiene video local
bool get hasLocalVideo

// Verificar si tiene cuestionario
bool get hasQuiz

// Obtener URL del video principal
String? get primaryVideoUrl

// Copiar con campos actualizados
Lesson copyWith({...})
```

---

## 3. Formulario de Lección Mejorado

### Descripción
El formulario [`LessonForm`](lib/forms/lesson_form.dart) ha sido completamente rediseñado para soportar todas las nuevas funcionalidades.

### Archivos Modificados

| Archivo | Descripción |
|---------|-------------|
| [`lib/forms/lesson_form.dart`](lib/forms/lesson_form.dart) | Formulario mejorado con soporte para múltiples tipos de contenido |

### Nuevas Secciones

#### 1. Tipo de Contenido
Dropdown para seleccionar el tipo de contenido de la lección:
- Video
- Artículo
- Cuestionario
- Documento
- YouTube
- Mixto

#### 2. Video URL
Campo para ingresar la URL de video tradicional (MP4, MPG, MPEG, WebM).

#### 3. Video de YouTube
- Campo para ingresar URL de YouTube
- Botón "Detectar" para extraer el ID del video automáticamente
- Vista previa del video detectado
- Botón para eliminar el video

#### 4. Documentos y Archivos
- Botón para subir archivos
- Soporta múltiples formatos:
  - **Word**: .doc, .docx
  - **PDF**: .pdf
  - **Texto**: .txt
  - **Imágenes**: .jpg, .jpeg, .png, .gif
  - **Videos**: .mp4, .mpg, .mpeg, .webm
- Lista de archivos subidos con:
  - Icono según tipo de archivo
  - Nombre del archivo
  - Tamaño del archivo
  - Botón para eliminar

#### 5. Generación de Contenido con IA
- Botón "Generar con IA" para usar Google Gemini
- Genera contenido educativo basado en:
  - Nombre de la lección
  - Nivel (Básico, Intermedio, Avanzado)
  - Idioma (Portugués, Inglés, Español)
- Vista previa del contenido generado
- Indicador de carga durante la generación

### Estado del Formulario

El formulario usa Riverpod para gestionar el estado:

```dart
class LessonFormState {
  final String contentType;
  final List<LessonMaterial> materials;
  final YouTubeVideo? youtubeVideo;
  final LocalVideo? localVideo;
  final String? lessonBody;
  final bool isUploading;
  final bool isGeneratingAI;
  final String? errorMessage;
}
```

### Funcionalidades

#### Subida de Archivos
- Usa Firebase Storage para almacenar archivos
- Genera URLs de descarga automáticamente
- Muestra progreso durante la subida
- Maneja errores de subida

#### Detección de YouTube
- Usa el paquete `youtube_parser` para extraer IDs
- Valida URLs de YouTube
- Genera URLs de embed y miniaturas

#### Generación con IA
- Usa el servicio [`AiContentService`](lib/services/ai_content_service.dart)
- Genera contenido en formato HTML
- Maneja errores de la API
- Muestra indicador de carga

---

## 4. Dependencias Agregadas

### pubspec.yaml

```yaml
dependencies:
  docx: ^5.0.0                    # Para leer documentos Word
  youtube_player_flutter: ^9.1.1  # Para reproducir videos de YouTube
  video_player: ^2.9.2            # Para reproducir videos locales
  chewie: ^1.8.5                  # Controles de video mejorados
```

---

## 5. Flujo de Trabajo Recomendado

### Crear un Nuevo Curso con Estructura Completa

1. **Crear el Curso**
   - Ir a **Cursos** → **Create Course**
   - Completar el formulario del curso

2. **Construir la Estructura**
   - Ir a **Constructor** en el menú lateral
   - Seleccionar el curso creado
   - Subir el documento Word con la estructura
   - Revisar la previsualización
   - Cargar la estructura a Firestore

3. **Editar el Contenido de las Lecciones**
   - Ir a **Jerarquía** → Seleccionar el curso
   - Navegar por niveles, módulos y lecciones
   - Editar cada lección para agregar:
     - Videos (URL, YouTube o local)
     - Documentos (Word, PDF, imágenes)
     - Contenido generado con IA
     - Cuestionarios

---

## 6. Ejemplo de Documento Word

Basado en el documento proporcionado:

```
CONTENIDO PLATAFORMA DEL IDIOMA PORTUGÜES

Nivel Básico

- Módulo 1: Fundamentos del Portugués
- Saludos y presentaciones.
- El alfabeto portugués y pronunciación básica.
- Números, colores y vocabulario esencial.
- Verbos ser y estar.
- Artículos definidos e indefinidos.
- Género y número de los sustantivos.
- Adjetivos básicos.
- Pronombres personales.
- Estructura de oraciones simples.
- Presente del indicativo (verbos regulares).
- Preguntas básicas.
- Expresiones de tiempo (días de la semana, meses).
- Comida y bebida.
- La familia.
- La casa.
- Ropa y accesorios.
- Clase de Práctica: Conversación básica y ejercicios de pronunciación.

- Módulo 2: Ampliando el Vocabulario y la Gramática
- Verbos irregulares comunes en presente.
- Preposiciones de lugar y tiempo.
- Adverbios de frecuencia.
- Expresar gustos y preferencias.
- El clima.
- Direcciones y transporte.
- Compras.
- Profesiones.
- Partes del cuerpo.
- Salud y bienestar.
- Actividades diarias.
- Pasatiempos e intereses.
- Plurales irregulares.
- Imperativo afirmativo (órdenes simples).
- Comparativos y superlativos básicos.
- Revisión y consolidación de gramática básica.
- Clase de Práctica: Diálogos situacionales y juegos de vocabulario.

Nivel Intermedio

- Módulo 3: Profundizando en la Gramática y la Cultura
- Pretérito perfecto simple.
- Pretérito imperfecto.
- Futuro simple.
- Condicional simple.
- Uso de "por" y "para".
- Pronombres posesivos.
- Pronombres demostrativos.
- Oraciones con "se".
- Estilo indirecto (reporte de información).
- Vocabulario sobre viajes.
- Historia y geografía de Brasil y Portugal.
- Música y danza (samba, fado).
- Festivales y celebraciones.
- Comida típica.
- Arte y literatura.
- Personalidades importantes.
- Clase de Práctica: Debates sobre temas culturales y redacción de textos cortos.

- Módulo 4: Expresión Oral y Escrita
- Subjuntivo presente (introducción).
- Pretérito perfecto compuesto.
- Pluscuamperfecto.
- Futuro del subjuntivo.
- Oraciones condicionales.
- Conectores discursivos.
- Vocabulario sobre tecnología.
- Medio ambiente.
- Noticias y actualidad.
- Educación.
- Trabajo y economía.
- Relaciones personales.
- Cartas formales e informales.
- Correos electrónicos.
- Narración de historias y anégonas.
- Descripción de personas y lugares.
- Clase de Práctica: Presentaciones orales y escritura de ensayos cortos.

Nivel Avanzado

- Módulo 5: Perfeccionamiento Gramatical y Estilístico
- Subjuntivo imperfecto y pluscuamperfecto.
- Voz pasiva.
- Concordancia verbal y nominal avanzada.
- Estilo indirecto libre.
- Figuras retóricas.
- Análisis de textos literarios.
- Vocabulario especializado (ej. derecho, medicina).
- Jerga y modismos.
- Regionalismos lingüísticos.
- Evolución del idioma portugués.
- Influencias africanas e indígenas.
- Literatura contemporánea.
- Cine portugués y brasileño.
- Teatro.
- Poesía.
- Crítica literaria.
- Clase de Práctica: Análisis de textos complejos y debates académicos.

- Módulo 6: Dominio Lingüístico y Cultural
- Traducción de textos literarios y técnicos.
- Interpretación simultánea y consecutiva.
- Redacción de informes y documentos profesionales.
- Negociación y comunicación intercultural.
- Política y sociedad en países de habla portuguesa.
- Desarrollo sostenible.
- Globalización.
- Ética y responsabilidad social.
- Planificación de proyectos.
- Gestión de equipos multiculturales.
- Liderazgo.
- Emprendimiento.
- Innovación.
- Investigación académica.
- Elaboración de tesis y disertaciones.
- Presentación de resultados de investigación.
- Clase de Práctica: Simulación de situaciones profesionales y proyectos de investigación.
```

---

## 7. Próximos Pasos

### Mejoras Futuras

1. **Editor Visual para Lecciones**
   - Editor WYSIWYG mejorado
   - Vista previa en tiempo real
   - Soporte para imágenes y videos incrustados

2. **Gestión de Cuestionarios**
   - Editor visual de preguntas
   - Soporte para diferentes tipos de preguntas
   - Puntuación y retroalimentación

3. **Importación/Exportación**
   - Exportar estructura a JSON
   - Importar estructura desde JSON
   - Plantillas de cursos

4. **Validación de Documentos**
   - Validar formato antes de parsear
   - Mostrar errores específicos
   - Sugerencias de corrección

5. **Historial de Cambios**
   - Registrar cambios en lecciones
   - Revertir a versiones anteriores
   - Comparar versiones

---

## 8. Soporte

Para problemas o preguntas sobre las nuevas funcionalidades:

1. Revisar la documentación en [`docs/`](docs/)
2. Consultar el código fuente en [`lib/`](lib/)
3. Verificar los logs en Firebase Console
4. Revisar la consola del navegador (F12)

---

**Fin del Documento**