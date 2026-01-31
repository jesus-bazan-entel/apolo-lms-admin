import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_admin/services/firebase_service.dart';

class PortugueseDataLoader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<String> _progressController = StreamController<String>.broadcast();
  
  Stream<String> get progressStream => _progressController.stream;

  void _updateProgress(String message) {
    print(message);
    if (!_progressController.isClosed) {
      _progressController.add(message);
    }
  }

  Future<void> loadAllData(String courseId) async {
    _updateProgress('🚀 Iniciando carga de datos para Portugués...');
    _updateProgress('📝 Course ID: $courseId');

    try {
      // Niveles y sus módulos
      final levels = _getLevelsData(courseId);
      _updateProgress('📚 Niveles a crear: ${levels.length}');

      for (var levelData in levels) {
        _updateProgress('\n--- Procesando nivel: ${levelData['name']} ---');
        await _createLevel(courseId, levelData);
      }

      _updateProgress('\n✅ Datos de Portugués cargados exitosamente!');
      _progressController.close();
    } catch (e, stackTrace) {
      _updateProgress('❌ Error en loadAllData: $e');
      _updateProgress('Stack trace: $stackTrace');
      _progressController.close();
      rethrow;
    }
  }

  Future<void> _createLevel(String courseId, Map<String, dynamic> levelData) async {
    try {
      final levelRef = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('levels')
          .doc(levelData['id']);

      await levelRef.set({
        'name': levelData['name'],
        'description': levelData['description'],
        'order': levelData['order'],
        'course_id': courseId,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      _updateProgress('  ✓ Nivel creado: ${levelData['name']}');
      _updateProgress('  📦 Módulos a crear: ${levelData['modules'].length}');

      // Crear módulos
      int moduleIndex = 0;
      for (var moduleData in levelData['modules']) {
        moduleIndex++;
        _updateProgress('    📦 Módulo $moduleIndex/${levelData['modules'].length}: ${moduleData['name']}');
        await _createModule(courseId, levelData['id'], moduleData);
      }
      
      _updateProgress('  ✅ Nivel completado con todos sus módulos');
    } catch (e, stackTrace) {
      _updateProgress('  ❌ Error en _createLevel (${levelData['name']}): $e');
      _updateProgress('  Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _createModule(
    String courseId,
    String levelId,
    Map<String, dynamic> moduleData,
  ) async {
    try {
      final moduleRef = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('levels')
          .doc(levelId)
          .collection('modules')
          .doc(moduleData['id']);
      
      await moduleRef.set({
        'name': moduleData['name'],
        'description': moduleData['description'],
        'order': moduleData['order'],
        'total_classes': moduleData['totalClasses'],
        'level_id': levelId,
        'course_id': courseId,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      _updateProgress('      ✓ Módulo guardado en Firestore');

      // Crear sección por defecto
      final sectionId = 'seccion-${moduleData['id']}';
      _updateProgress('      📂 Creando sección para ${moduleData['totalClasses']} lecciones...');
      await _createSection(courseId, levelId, moduleData['id'], sectionId, moduleData['totalClasses']);

      // Crear lecciones
      int lessonCount = moduleData['lessons'].length;
      _updateProgress('      📚 Creando $lessonCount lecciones...');
      
      int progress = 0;
      for (var lessonData in moduleData['lessons']) {
        progress++;
        if (progress % 5 == 0 || progress == lessonCount) {
          _updateProgress('         → $progress/$lessonCount lecciones creadas');
        }
        await _createLesson(
          courseId,
          levelId,
          moduleData['id'],
          sectionId,
          lessonData,
        );
      }

      _updateProgress('      ✅ Módulo completado con $lessonCount lecciones');
    } catch (e, stackTrace) {
      _updateProgress('      ❌ Error: $e');
      rethrow;
    }
  }

  Future<void> _createSection(
    String courseId,
    String levelId,
    String moduleId,
    String sectionId,
    int totalClasses,
  ) async {
    final sectionRef = _firestore
        .collection('courses')
        .doc(courseId)
        .collection('levels')
        .doc(levelId)
        .collection('modules')
        .doc(moduleId)
        .collection('sections')
        .doc(sectionId);

    await sectionRef.set({
      'name': 'Clases 1-$totalClasses',
      'order': 1,
      'module_id': moduleId,
      'level_id': levelId,
      'course_id': courseId,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _createLesson(
    String courseId,
    String levelId,
    String moduleId,
    String sectionId,
    Map<String, dynamic> lessonData,
  ) async {
    final lessonId = 'leccion-$moduleId-${lessonData['order']}';
    final lessonRef = _firestore
        .collection('courses')
        .doc(courseId)
        .collection('levels')
        .doc(levelId)
        .collection('modules')
        .doc(moduleId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lessonId);

    await lessonRef.set({
      'name': lessonData['name'],
      'order': lessonData['order'],
      'content_type': 'video',
      'video_url': '',
      'description': '',
      'lesson_body': '<p>Contenido de la lección pendiente</p>',
      'course_id': courseId,
      'level_id': levelId,
      'module_id': moduleId,
      'section_id': sectionId,
      'duration': 0,
      'is_free': false,
      'thumbnail_url': '',
      'vimeo_video_id': '',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  List<Map<String, dynamic>> _getLevelsData(String courseId) {
    return [
      {
        'id': 'nivel-basico',
        'name': 'Nivel Básico',
        'description': 'Aprende los fundamentos del portugués',
        'order': 1,
        'modules': [
          {
            'id': 'modulo-1-basico',
            'name': 'Módulo 1: Fundamentos del Portugués',
            'description': 'Saludos, alfabeto, números y conceptos básicos',
            'order': 1,
            'totalClasses': 17,
            'lessons': [
              {'name': 'Saludos y presentaciones', 'order': 1},
              {'name': 'El alfabeto portugués y pronunciación básica', 'order': 2},
              {'name': 'Números, colores y vocabulario esencial', 'order': 3},
              {'name': 'Verbos ser y estar', 'order': 4},
              {'name': 'Artículos definidos e indefinidos', 'order': 5},
              {'name': 'Género y número de los sustantivos', 'order': 6},
              {'name': 'Adjetivos básicos', 'order': 7},
              {'name': 'Pronombres personales', 'order': 8},
              {'name': 'Estructura de oraciones simples', 'order': 9},
              {'name': 'Presente del indicativo (verbos regulares)', 'order': 10},
              {'name': 'Preguntas básicas', 'order': 11},
              {'name': 'Expresiones de tiempo (días de la semana, meses)', 'order': 12},
              {'name': 'Comida y bebida', 'order': 13},
              {'name': 'La familia', 'order': 14},
              {'name': 'La casa', 'order': 15},
              {'name': 'Ropa y accesorios', 'order': 16},
              {'name': 'Clase de Práctica: Conversación básica y ejercicios de pronunciación', 'order': 17},
            ],
          },
          {
            'id': 'modulo-2-basico',
            'name': 'Módulo 2: Ampliando el Vocabulario y la Gramática',
            'description': 'Verbos irregulares, preposiciones y vocabulario avanzado',
            'order': 2,
            'totalClasses': 17,
            'lessons': [
              {'name': 'Verbos irregulares comunes en presente', 'order': 1},
              {'name': 'Preposiciones de lugar y tiempo', 'order': 2},
              {'name': 'Adverbios de frecuencia', 'order': 3},
              {'name': 'Expresar gustos y preferencias', 'order': 4},
              {'name': 'El clima', 'order': 5},
              {'name': 'Direcciones y transporte', 'order': 6},
              {'name': 'Compras', 'order': 7},
              {'name': 'Profesiones', 'order': 8},
              {'name': 'Partes del cuerpo', 'order': 9},
              {'name': 'Salud y bienestar', 'order': 10},
              {'name': 'Actividades diarias', 'order': 11},
              {'name': 'Pasatiempos e intereses', 'order': 12},
              {'name': 'Plurales irregulares', 'order': 13},
              {'name': 'Imperativo afirmativo (órdenes simples)', 'order': 14},
              {'name': 'Comparativos y superlativos básicos', 'order': 15},
              {'name': 'Revisión y consolidación de gramática básica', 'order': 16},
              {'name': 'Clase de Práctica: Diálogos situacionales y juegos de vocabulario', 'order': 17},
            ],
          },
        ],
      },
      {
        'id': 'nivel-intermedio',
        'name': 'Nivel Intermedio',
        'description': 'Profundiza en gramática y cultura portuguesa',
        'order': 2,
        'modules': [
          {
            'id': 'modulo-3-intermedio',
            'name': 'Módulo 3: Profundizando en la Gramática y la Cultura',
            'description': 'Tiempos verbales avanzados y cultura',
            'order': 3,
            'totalClasses': 17,
            'lessons': [
              {'name': 'Pretérito perfecto simple', 'order': 1},
              {'name': 'Pretérito imperfecto', 'order': 2},
              {'name': 'Futuro simple', 'order': 3},
              {'name': 'Condicional simple', 'order': 4},
              {'name': 'Uso de "por" y "para"', 'order': 5},
              {'name': 'Pronombres posesivos', 'order': 6},
              {'name': 'Pronombres demostrativos', 'order': 7},
              {'name': 'Oraciones con "se"', 'order': 8},
              {'name': 'Estilo indirecto (reporte de información)', 'order': 9},
              {'name': 'Vocabulario sobre viajes', 'order': 10},
              {'name': 'Historia y geografía de Brasil y Portugal', 'order': 11},
              {'name': 'Música y danza (samba, fado)', 'order': 12},
              {'name': 'Festivales y celebraciones', 'order': 13},
              {'name': 'Comida típica', 'order': 14},
              {'name': 'Arte y literatura', 'order': 15},
              {'name': 'Personalidades importantes', 'order': 16},
              {'name': 'Clase de Práctica: Debates sobre temas culturales y redacción de textos cortos', 'order': 17},
            ],
          },
          {
            'id': 'modulo-4-intermedio',
            'name': 'Módulo 4: Expresión Oral y Escrita',
            'description': 'Subjuntivo y escritura avanzada',
            'order': 4,
            'totalClasses': 17,
            'lessons': [
              {'name': 'Subjuntivo presente (introducción)', 'order': 1},
              {'name': 'Pretérito perfecto compuesto', 'order': 2},
              {'name': 'Pluscuamperfecto', 'order': 3},
              {'name': 'Futuro del subjuntivo', 'order': 4},
              {'name': 'Oraciones condicionales', 'order': 5},
              {'name': 'Conectores discursivos', 'order': 6},
              {'name': 'Vocabulario sobre tecnología', 'order': 7},
              {'name': 'Medio ambiente', 'order': 8},
              {'name': 'Noticias y actualidad', 'order': 9},
              {'name': 'Educación', 'order': 10},
              {'name': 'Trabajo y economía', 'order': 11},
              {'name': 'Relaciones personales', 'order': 12},
              {'name': 'Cartas formales e informales', 'order': 13},
              {'name': 'Correos electrónicos', 'order': 14},
              {'name': 'Narración de historias y anécdotas', 'order': 15},
              {'name': 'Descripción de personas y lugares', 'order': 16},
              {'name': 'Clase de Práctica: Presentaciones orales y escritura de ensayos cortos', 'order': 17},
            ],
          },
        ],
      },
      {
        'id': 'nivel-avanzado',
        'name': 'Nivel Avanzado',
        'description': 'Dominio del idioma portugués',
        'order': 3,
        'modules': [
          {
            'id': 'modulo-5-avanzado',
            'name': 'Módulo 5: Perfeccionamiento Gramatical y Estilístico',
            'description': 'Gramática avanzada y análisis literario',
            'order': 5,
            'totalClasses': 17,
            'lessons': [
              {'name': 'Subjuntivo imperfecto y pluscuamperfecto', 'order': 1},
              {'name': 'Voz pasiva', 'order': 2},
              {'name': 'Concordancia verbal y nominal avanzada', 'order': 3},
              {'name': 'Estilo indirecto libre', 'order': 4},
              {'name': 'Figuras retóricas', 'order': 5},
              {'name': 'Análisis de textos literarios', 'order': 6},
              {'name': 'Vocabulario especializado (ej. derecho, medicina)', 'order': 7},
              {'name': 'Jerga y modismos', 'order': 8},
              {'name': 'Regionalismos lingüísticos', 'order': 9},
              {'name': 'Evolución del idioma portugués', 'order': 10},
              {'name': 'Influencias africanas e indígenas', 'order': 11},
              {'name': 'Literatura contemporánea', 'order': 12},
              {'name': 'Cine portugués y brasileño', 'order': 13},
              {'name': 'Teatro', 'order': 14},
              {'name': 'Poesía', 'order': 15},
              {'name': 'Crítica literaria', 'order': 16},
              {'name': 'Clase de Práctica: Análisis de textos complejos y debates académicos', 'order': 17},
            ],
          },
          {
            'id': 'modulo-6-avanzado',
            'name': 'Módulo 6: Dominio Lingüístico y Cultural',
            'description': 'Traducción, interpretación y uso profesional',
            'order': 6,
            'totalClasses': 17,
            'lessons': [
              {'name': 'Traducción de textos literarios y técnicos', 'order': 1},
              {'name': 'Interpretación simultánea y consecutiva', 'order': 2},
              {'name': 'Redacción de informes y documentos profesionales', 'order': 3},
              {'name': 'Negociación y comunicación intercultural', 'order': 4},
              {'name': 'Política y sociedad en países de habla portuguesa', 'order': 5},
              {'name': 'Desarrollo sostenible', 'order': 6},
              {'name': 'Globalización', 'order': 7},
              {'name': 'Ética y responsabilidad social', 'order': 8},
              {'name': 'Planificación de proyectos', 'order': 9},
              {'name': 'Gestión de equipos multiculturales', 'order': 10},
              {'name': 'Liderazgo', 'order': 11},
              {'name': 'Emprendimiento', 'order': 12},
              {'name': 'Innovación', 'order': 13},
              {'name': 'Investigación académica', 'order': 14},
              {'name': 'Elaboración de tesis y disertaciones', 'order': 15},
              {'name': 'Presentación de resultados de investigación', 'order': 16},
              {'name': 'Clase de Práctica: Simulación de situaciones profesionales y proyectos de investigación', 'order': 17},
            ],
          },
        ],
      },
    ];
  }
}
