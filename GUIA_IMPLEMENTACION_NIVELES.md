# IMPLEMENTACIÓN: ESTRUCTURA JERÁRQUICA PARA CURSOS

## Resumen de Cambios

### 1. **Nuevos Modelos Creados**
- `lib/models/level.dart` - Modelo para Niveles (Básico, Intermedio, Avanzado)
- `lib/models/module.dart` - Modelo para Módulos dentro de un Nivel

### 2. **Modelos Actualizados**
- `lib/models/lesson.dart` - Agregadas referencias a courseId, levelId, moduleId, sectionId

### 3. **Nuevos Providers**
- `lib/providers/hierarchy_providers.dart` - Providers para cargar Levels y Modules

### 4. **Servicio Actualizado**
- `lib/services/firebase_service.dart` - Nuevos métodos para CRUD de Levels y Modules

## Estructura en Firestore

```
courses/{courseId}
├── levels/{levelId}
│   ├── name: "Nivel Básico"
│   ├── order: 1
│   └── modules/{moduleId}
│       ├── name: "Módulo 1: Fundamentos del Portugués"
│       ├── total_classes: 16
│       └── sections/{sectionId}
│           └── lessons/{lessonId}
│               ├── name: "Saludos y presentaciones"
│               ├── level_id: "nivel-basico"
│               └── module_id: "modulo-1-basico"
```

## Pasos para Implementar en tu Proyecto

### 1. **Actualizar la UI del Admin Panel**

Crear nuevas vistas para gestionar Levels y Modules:

```dart
// lib/tabs/admin_tabs/levels/levels.dart
// lib/tabs/admin_tabs/modules/modules.dart
```

### 2. **Cargar Datos para Portugués**

Ejecutar en la Console de Firestore o usar un Cloud Function:

```javascript
// Crear Nivel Básico
db.collection('courses').doc('portugues').collection('levels').doc('nivel-basico').set({
  name: 'Nivel Básico',
  description: 'Aprende los fundamentos del portugués',
  order: 1,
  course_id: 'portugues',
  created_at: new Date()
});

// Crear Módulo 1 bajo Nivel Básico
db.collection('courses').doc('portugues').collection('levels').doc('nivel-basico').collection('modules').doc('modulo-1').set({
  name: 'Módulo 1: Fundamentos del Portugués',
  description: 'Saludos, alfabeto, números y conceptos básicos',
  order: 1,
  total_classes: 16,
  level_id: 'nivel-basico',
  course_id: 'portugues',
  created_at: new Date()
});
```

### 3. **Actualizar Lecciones Existentes**

Asegúrate de agregar los campos `level_id`, `module_id` al guardar nuevas lecciones:

```dart
Lesson lesson = Lesson(
  id: id,
  name: 'Saludos y presentaciones',
  courseId: 'portugues',
  levelId: 'nivel-basico',
  moduleId: 'modulo-1',
  sectionId: 'seccion-1',
  // ... otros campos
);
```

### 4. **Actualizar la Navegación en el Portal del Estudiante**

Modificar la vista de cursos para mostrar:
1. Curso → Niveles disponibles
2. Nivel → Módulos disponibles
3. Módulo → Secciones y Lecciones

```dart
// lib/tabs/student_tabs/course_detail.dart
// Mostrar lista de Levels
// Cuando selecciona un Level, mostrar Modules
// Cuando selecciona un Module, mostrar Sections y Lessons
```

## Datos Para Cargar - Portugués

### Nivel Básico (2 módulos)
**Módulo 1: Fundamentos del Portugués (16 clases)**
1. Saludos y presentaciones
2. El alfabeto portugués y pronunciación básica
3. Números, colores y vocabulario esencial
4. Verbos ser y estar
5. Artículos definidos e indefinidos
6. Género y número de los sustantivos
7. Adjetivos básicos
8. Pronombres personales
9. Estructura de oraciones simples
10. Presente del indicativo (verbos regulares)
11. Preguntas básicas
12. Expresiones de tiempo (días de la semana, meses)
13. Comida y bebida
14. La familia
15. La casa
16. Ropa y accesorios

**Módulo 2: Ampliando el Vocabulario y la Gramática (16 clases)**
1. Verbos irregulares comunes en presente
2. Preposiciones de lugar y tiempo
3. Adverbios de frecuencia
4. Expresar gustos y preferencias
5. El clima
6. Direcciones y transporte
7. Compras
8. Profesiones
9. Partes del cuerpo
10. Salud y bienestar
11. Actividades diarias
12. Pasatiempos e intereses
13. Plurales irregulares
14. Imperativo afirmativo (órdenes simples)
15. Comparativos y superlativos básicos
16. Revisión y consolidación de gramática básica

### Nivel Intermedio (2 módulos)
### Nivel Avanzado (2 módulos)

## Next Steps

1. ✅ Modelos creados
2. ✅ Firebase Service actualizado
3. ⏳ Crear UI para gestionar Levels/Modules en admin panel
4. ⏳ Crear UI para estudiantes para navegar por la jerarquía
5. ⏳ Cargar datos para cada curso de idioma
6. ⏳ Implementar progreso del estudiante por nivel/módulo
