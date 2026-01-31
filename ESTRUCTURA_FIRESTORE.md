/**
 * ESTRUCTURA DE FIRESTORE PARA CURSOS DE IDIOMAS JERÁRQUICOS
 * 
 * Ejemplo: Curso de Portugués
 * 
 * Colección: courses
 *   ├─ courseId (ej: "portugues-completo")
 *   │  ├─ name: "Portugués Completo"
 *   │  ├─ description: "Aprende Portugués desde básico hasta avanzado"
 *   │  └─ ... otros campos
 *   │
 *   └─ Subcolección: levels
 *      ├─ levelId: "nivel-basico"
 *      │  ├─ name: "Nivel Básico"
 *      │  ├─ order: 1
 *      │  ├─ course_id: "portugues-completo"
 *      │  │
 *      │  └─ Subcolección: modules
 *      │     ├─ moduleId: "modulo-1-basico"
 *      │     │  ├─ name: "Módulo 1: Fundamentos del Portugués"
 *      │     │  ├─ order: 1
 *      │     │  ├─ total_classes: 16
 *      │     │  ├─ level_id: "nivel-basico"
 *      │     │  ├─ course_id: "portugues-completo"
 *      │     │  │
 *      │     │  └─ Subcolección: sections
 *      │     │     ├─ sectionId: "seccion-1-modulo-1"
 *      │     │     │  ├─ name: "Clases 1-16"
 *      │     │     │  │
 *      │     │     │  └─ Subcolección: lessons
 *      │     │     │     ├─ lessonId: "leccion-1"
 *      │     │     │     │  ├─ name: "Saludos y presentaciones"
 *      │     │     │     │  ├─ order: 1
 *      │     │     │     │  ├─ content_type: "video|article|quiz"
 *      │     │     │     │  ├─ video_url: "..."
 *      │     │     │     │  ├─ description: "..."
 *      │     │     │     │  ├─ course_id: "portugues-completo"
 *      │     │     │     │  ├─ level_id: "nivel-basico"
 *      │     │     │     │  ├─ module_id: "modulo-1-basico"
 *      │     │     │     │  └─ section_id: "seccion-1-modulo-1"
 *      │     │     │     │
 *      │     │     │     └─ leccion-2, leccion-3... (total 16 lecciones)
 *      │     │     │
 *      │     │     └─ seccion-2... (si hay más secciones por módulo)
 *      │     │
 *      │     └─ modulo-2-basico
 *      │        └─ ... (estructura similar)
 *      │
 *      ├─ levelId: "nivel-intermedio"
 *      │  └─ ... (estructura similar con 2 módulos)
 *      │
 *      └─ levelId: "nivel-avanzado"
 *         └─ ... (estructura similar con 2 módulos)
 * 
 * TOTAL PARA PORTUGUÉS:
 * - 3 Niveles
 * - 6 Módulos (2 por nivel)
 * - 6 Secciones (1 por módulo)
 * - 96 Lecciones (16 por módulo)
 * 
 * ESTRUCTURA EN EL CÓDIGO DART:
 * Course -> Level -> Module -> Section -> Lesson
 */
