import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lms_admin/services/firebase_service.dart';

/// Modelo para representar la estructura de un curso parseado
class ParsedCourseStructure {
  final String courseName;
  final List<ParsedLevel> levels;

  ParsedCourseStructure({
    required this.courseName,
    required this.levels,
  });

  Map<String, dynamic> toJson() {
    return {
      'courseName': courseName,
      'levels': levels.map((l) => l.toJson()).toList(),
    };
  }
}

/// Modelo para representar un nivel parseado
class ParsedLevel {
  final String name;
  final int order;
  final List<ParsedModule> modules;

  ParsedLevel({
    required this.name,
    required this.order,
    required this.modules,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'order': order,
      'modules': modules.map((m) => m.toJson()).toList(),
    };
  }
}

/// Modelo para representar un módulo parseado
class ParsedModule {
  final String name;
  final int order;
  final List<ParsedLesson> lessons;

  ParsedModule({
    required this.name,
    required this.order,
    required this.lessons,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'order': order,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }
}

/// Modelo para representar una lección parseada
class ParsedLesson {
  final String name;
  final int order;

  ParsedLesson({
    required this.name,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'order': order,
    };
  }
}

/// Servicio para parsear texto y construir estructuras de cursos
class CourseStructureParser {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<String> _progressController = StreamController<String>.broadcast();

  Stream<String> get progressStream => _progressController.stream;

  void _updateProgress(String message) {
    debugPrint(message);
    if (!_progressController.isClosed) {
      _progressController.add(message);
    }
  }

  /// Parsea texto y extrae la estructura del curso
  Future<ParsedCourseStructure?> parseText(String text) async {
    try {
      _updateProgress('📄 Leyendo contenido del texto...');
      
      // Dividir el texto en líneas
      final lines = text.split('\n').map((line) => line.trim()).toList();
      
      _updateProgress('📝 Extrayendo estructura del contenido...');
      
      // Parsear la estructura
      final structure = _parseStructureFromText(lines);
      
      _updateProgress('✅ Estructura parseada exitosamente');
      _progressController.close();
      
      return structure;
    } catch (e, stackTrace) {
      _updateProgress('❌ Error al parsear texto: $e');
      _updateProgress('Stack trace: $stackTrace');
      _progressController.close();
      rethrow;
    }
  }

  /// Parsea la estructura desde una lista de texto
  ParsedCourseStructure _parseStructureFromText(List<String> lines) {
    final levels = <ParsedLevel>[];
    ParsedLevel? currentLevel;
    ParsedModule? currentModule;
    int levelOrder = 0;
    int moduleOrder = 0;
    int lessonOrder = 0;

    for (var line in lines) {
      final trimmedLine = line.trim();
      
      if (trimmedLine.isEmpty) continue;

      // Detectar nivel (ej: "Nivel Básico", "Nivel Intermedio", "Nivel Avanzado")
      if (_isLevelHeader(trimmedLine)) {
        if (currentLevel != null) {
          levels.add(currentLevel);
        }
        levelOrder++;
        currentLevel = ParsedLevel(
          name: trimmedLine,
          order: levelOrder,
          modules: [],
        );
        moduleOrder = 0;
        _updateProgress('  📚 Nivel detectado: $trimmedLine');
      }
      // Detectar módulo (ej: "- Módulo 1: Fundamentos del Portugués")
      else if (_isModuleHeader(trimmedLine) && currentLevel != null) {
        if (currentModule != null) {
          currentLevel.modules.add(currentModule);
        }
        moduleOrder++;
        final moduleName = _extractModuleName(trimmedLine);
        currentModule = ParsedModule(
          name: moduleName,
          order: moduleOrder,
          lessons: [],
        );
        lessonOrder = 0;
        _updateProgress('    📦 Módulo detectado: $moduleName');
      }
      // Detectar lección (ej: "- Saludos y presentaciones.")
      else if (_isLesson(trimmedLine) && currentModule != null) {
        lessonOrder++;
        final lessonName = _extractLessonName(trimmedLine);
        currentModule.lessons.add(ParsedLesson(
          name: lessonName,
          order: lessonOrder,
        ));
        _updateProgress('      📖 Lección detectada: $lessonName');
      }
    }

    // Agregar el último nivel y módulo
    if (currentModule != null && currentLevel != null) {
      currentLevel.modules.add(currentModule);
    }
    if (currentLevel != null) {
      levels.add(currentLevel);
    }

    return ParsedCourseStructure(
      courseName: 'Curso Parseado',
      levels: levels,
    );
  }

  /// Verifica si una línea es un encabezado de nivel
  bool _isLevelHeader(String line) {
    final levelPatterns = [
      RegExp(r'^Nivel\s+(Básico|Intermedio|Avanzado)', caseSensitive: false),
      RegExp(r'^NIVEL\s+(BÁSICO|INTERMEDIO|AVANZADO)'),
    ];
    
    return levelPatterns.any((pattern) => pattern.hasMatch(line));
  }

  /// Verifica si una línea es un encabezado de módulo
  bool _isModuleHeader(String line) {
    return RegExp(r'^-\s*Módulo\s+\d+:\s*.+', caseSensitive: false).hasMatch(line);
  }

  /// Verifica si una línea es una lección
  bool _isLesson(String line) {
    // Excluir encabezados de módulo
    if (_isModuleHeader(line)) return false;
    
    // Verificar que empiece con guion y tenga contenido
    return RegExp(r'^-\s*[A-ZÁÉÍÓÚÑ].+', caseSensitive: false).hasMatch(line);
  }

  /// Extrae el nombre del módulo de una línea
  String _extractModuleName(String line) {
    // Remover el guion inicial y "Módulo X:"
    final cleaned = line.replaceFirst(RegExp(r'^-\s*Módulo\s+\d+:\s*', caseSensitive: false), '');
    return cleaned.trim();
  }

  /// Extrae el nombre de la lección de una línea
  String _extractLessonName(String line) {
    // Remover el guion inicial y el punto final
    final cleaned = line.replaceFirst(RegExp(r'^-\s*'), '').replaceAll(RegExp(r'\.$'), '');
    return cleaned.trim();
  }

  /// Carga la estructura parseada a Firestore
  Future<void> loadStructureToFirestore(
    String courseId,
    ParsedCourseStructure structure,
  ) async {
    try {
      _updateProgress('🚀 Iniciando carga de estructura a Firestore...');
      _updateProgress('📝 Course ID: $courseId');

      for (var levelData in structure.levels) {
        _updateProgress('\n--- Procesando nivel: ${levelData.name} ---');
        await _createLevel(courseId, levelData);
      }

      _updateProgress('\n✅ Estructura cargada exitosamente a Firestore!');
      _progressController.close();
    } catch (e, stackTrace) {
      _updateProgress('❌ Error al cargar estructura: $e');
      _updateProgress('Stack trace: $stackTrace');
      _progressController.close();
      rethrow;
    }
  }

  /// Crea un nivel en Firestore
  Future<void> _createLevel(String courseId, ParsedLevel levelData) async {
    try {
      final levelId = 'nivel-${levelData.order.toString().padLeft(2, '0')}';
      final levelRef = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('levels')
          .doc(levelId);

      await levelRef.set({
        'name': levelData.name,
        'description': _generateLevelDescription(levelData.name),
        'order': levelData.order,
        'course_id': courseId,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      _updateProgress('  ✓ Nivel creado: ${levelData.name}');
      _updateProgress('  📦 Módulos a crear: ${levelData.modules.length}');

      // Crear módulos
      for (var moduleData in levelData.modules) {
        await _createModule(courseId, levelId, moduleData);
      }

      _updateProgress('  ✅ Nivel completado con todos sus módulos');
    } catch (e, stackTrace) {
      _updateProgress('  ❌ Error en _createLevel (${levelData.name}): $e');
      _updateProgress('  Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Crea un módulo en Firestore
  Future<void> _createModule(
    String courseId,
    String levelId,
    ParsedModule moduleData,
  ) async {
    try {
      final moduleId = 'modulo-${moduleData.order.toString().padLeft(2, '0')}';
      final moduleRef = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('levels')
          .doc(levelId)
          .collection('modules')
          .doc(moduleId);

      await moduleRef.set({
        'name': moduleData.name,
        'description': _generateModuleDescription(moduleData.name),
        'order': moduleData.order,
        'total_classes': moduleData.lessons.length,
        'level_id': levelId,
        'course_id': courseId,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      _updateProgress('    ✓ Módulo guardado en Firestore');

      // Crear sección por defecto
      final sectionId = 'seccion-$moduleId';
      await _createSection(courseId, levelId, moduleId, sectionId, moduleData.lessons.length);

      // Crear lecciones
      int lessonCount = moduleData.lessons.length;
      _updateProgress('    📚 Creando $lessonCount lecciones...');

      int progress = 0;
      for (var lessonData in moduleData.lessons) {
        progress++;
        if (progress % 5 == 0 || progress == lessonCount) {
          _updateProgress('       → $progress/$lessonCount lecciones creadas');
        }
        await _createLesson(
          courseId,
          levelId,
          moduleId,
          sectionId,
          lessonData,
        );
      }

      _updateProgress('    ✅ Módulo completado con $lessonCount lecciones');
    } catch (e, stackTrace) {
      _updateProgress('    ❌ Error: $e');
      rethrow;
    }
  }

  /// Crea una sección en Firestore
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

  /// Crea una lección en Firestore
  Future<void> _createLesson(
    String courseId,
    String levelId,
    String moduleId,
    String sectionId,
    ParsedLesson lessonData,
  ) async {
    final lessonId = 'leccion-$moduleId-${lessonData.order.toString().padLeft(2, '0')}';
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
      'name': lessonData.name,
      'order': lessonData.order,
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

  /// Genera una descripción para un nivel
  String _generateLevelDescription(String levelName) {
    switch (levelName.toLowerCase()) {
      case 'nivel básico':
        return 'Aprende los fundamentos del idioma portugués';
      case 'nivel intermedio':
        return 'Profundiza en gramática y cultura portuguesa';
      case 'nivel avanzado':
        return 'Dominio del idioma portugués';
      default:
        return 'Nivel de aprendizaje del idioma portugués';
    }
  }

  /// Genera una descripción para un módulo
  String _generateModuleDescription(String moduleName) {
    // Extraer palabras clave del nombre del módulo
    final keywords = moduleName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((word) => word.length > 3)
        .take(3)
        .join(', ');
    
    return 'Módulo enfocado en: $keywords';
  }

  /// Libera recursos
  void dispose() {
    if (!_progressController.isClosed) {
      _progressController.close();
    }
  }
}
