import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/services/course_structure_parser.dart';
import 'package:lms_admin/models/level.dart';
import 'package:lms_admin/models/module.dart';
import 'package:lms_admin/utils/toasts.dart';

class CourseStructureUploaderDialog extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;

  const CourseStructureUploaderDialog({
    Key? key,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  ConsumerState<CourseStructureUploaderDialog> createState() =>
      _CourseStructureUploaderDialogState();
}

class _CourseStructureUploaderDialogState
    extends ConsumerState<CourseStructureUploaderDialog> {
  final TextEditingController _textController = TextEditingController();
  String? _fileName;
  String? _fileContent;
  final List<String> _progressMessages = [];
  bool _isProcessing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processAndUpload() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      openToast(context, 'Por favor, ingresa el contenido del curso');
      return;
    }

    setState(() {
      _isProcessing = true;
      _progressMessages.clear();
    });

    try {
      _addProgress('📄 Procesando contenido...');
      
      // Parsear el contenido del archivo
      final parser = CourseStructureParser();
      final structure = await parser.parseText(text);

      if (structure == null) {
        _addProgress('❌ No se pudo parsear el contenido');
        setState(() => _isProcessing = false);
        return;
      }

      _addProgress('✓ Estructura parseada: ${structure.levels.length} niveles encontrados');

      // Crear la estructura en Firestore
      int totalCreated = 0;
      for (var parsedLevel in structure.levels) {
        _addProgress('\n📚 Creando nivel: ${parsedLevel.name}');
        
        // Generar ID para el nivel
        final levelId = 'nivel-${parsedLevel.order.toString().padLeft(2, '0')}';
        
        // Convertir ParsedLevel a Level
        final level = Level(
          id: levelId,
          courseId: widget.courseId,
          name: parsedLevel.name,
          description: '',
          order: parsedLevel.order,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await FirebaseService().saveLevel(widget.courseId, level);
        
        for (var parsedModule in parsedLevel.modules) {
          _addProgress('  📦 Creando módulo: ${parsedModule.name}');
          
          // Generar ID para el módulo
          final moduleId = 'modulo-${parsedModule.order.toString().padLeft(2, '0')}';
          
          // Convertir ParsedModule a Module
          final module = Module(
            id: moduleId,
            levelId: levelId,
            courseId: widget.courseId,
            name: parsedModule.name,
            description: '',
            order: parsedModule.order,
            totalClasses: parsedModule.lessons.length,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await FirebaseService().saveModule(widget.courseId, levelId, module);
          
          // Crear sección por defecto
          final sectionId = 'seccion-$moduleId';
          await _createSection(levelId, moduleId, sectionId, parsedModule.lessons.length);
          
          // Crear lecciones
          for (var lesson in parsedModule.lessons) {
            await _createLesson(levelId, moduleId, sectionId, lesson);
            totalCreated++;
          }
          
          _addProgress('    ✓ ${parsedModule.lessons.length} lecciones creadas');
        }
      }

      _addProgress('\n✅ Proceso completado: $totalCreated lecciones creadas en total');
      
      if (mounted) {
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context, true);
      }
    } catch (e) {
      _addProgress('\n❌ Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _addProgress(String message) {
    if (mounted) {
      setState(() {
        _progressMessages.add(message);
      });
    }
  }

  Future<void> _createSection(String levelId, String moduleId, String sectionId, int totalClasses) async {
    await FirebaseService().firestore
        .collection('courses')
        .doc(widget.courseId)
        .collection('levels')
        .doc(levelId)
        .collection('modules')
        .doc(moduleId)
        .collection('sections')
        .doc(sectionId)
        .set({
      'name': 'Clases 1-$totalClasses',
      'order': 1,
      'module_id': moduleId,
      'level_id': levelId,
      'course_id': widget.courseId,
      'created_at': DateTime.now(),
      'updated_at': DateTime.now(),
    });
  }

  Future<void> _createLesson(
    String levelId,
    String moduleId,
    String sectionId,
    ParsedLesson lessonData,
  ) async {
    final lessonId = 'leccion-$moduleId-${lessonData.order.toString().padLeft(2, '0')}';
    await FirebaseService().firestore
        .collection('courses')
        .doc(widget.courseId)
        .collection('levels')
        .doc(levelId)
        .collection('modules')
        .doc(moduleId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lessonId)
        .set({
      'name': lessonData.name,
      'order': lessonData.order,
      'content_type': 'video',
      'video_url': '',
      'description': '',
      'lesson_body': '<p>Contenido pendiente</p>',
      'course_id': widget.courseId,
      'level_id': levelId,
      'module_id': moduleId,
      'section_id': sectionId,
      'duration': 0,
      'is_free': false,
      'thumbnail_url': '',
      'created_at': DateTime.now(),
      'updated_at': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cargar Estructura del Curso',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.courseName,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            // Instrucciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Formato del contenido',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'El contenido debe seguir esta estructura:\n'
                    'Nivel Básico\n\n'
                    '- Módulo 1: Fundamentos\n'
                    '- Saludos y presentaciones\n'
                    '- El alfabeto portugués\n\n'
                    '- Módulo 2: Ampliando el Vocabulario\n'
                    '- Verbos irregulares comunes en presente\n'
                    '- Preposiciones de lugar y tiempo',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Campo de texto
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Pega aquí el contenido del curso...',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Progreso
            if (_isProcessing || _progressMessages.isNotEmpty) ...[
              const Text(
                'Progreso:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _progressMessages.join('\n'),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ] else
              const Spacer(),

            const Divider(height: 24),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _processAndUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009739),
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Procesar y Cargar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
