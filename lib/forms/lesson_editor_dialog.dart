import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/models/lesson.dart';
import 'package:lms_admin/models/module.dart';
import 'package:lms_admin/services/ai_content_service.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/utils/toasts.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:image_picker/image_picker.dart';

class LessonEditorDialog extends ConsumerStatefulWidget {
  final Lesson lesson;
  final Module module;
  final String courseId;
  final String levelId;

  const LessonEditorDialog({
    Key? key,
    required this.lesson,
    required this.module,
    required this.courseId,
    required this.levelId,
  }) : super(key: key);

  @override
  ConsumerState<LessonEditorDialog> createState() => _LessonEditorDialogState();
}

class _LessonEditorDialogState extends ConsumerState<LessonEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _saveController = RoundedLoadingButtonController();
  final _aiController = RoundedLoadingButtonController();
  
  String _contentType = 'video';
  bool _isGeneratingAI = false;
  List<String> _pdfLinks = [];

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.lesson.description ?? '';
    _videoUrlController.text = widget.lesson.videoUrl ?? '';
    _contentType = widget.lesson.contentType;
    _pdfLinks = widget.lesson.pdfLinks ?? [];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _generateAIContent() async {
    setState(() => _isGeneratingAI = true);
    
    try {
      // Obtener la API key desde Firebase Settings
      final settings = await FirebaseService().getAppSettings();
      final apiKey = settings?.geminiApiKey ?? AppConfig.geminiApiKey;
      
      if (apiKey.isEmpty) {
        throw Exception('La clave API de Gemini no está configurada');
      }
      
      final aiService = AiContentService(apiKey);
      final content = await aiService.generateLessonContent(
        widget.lesson.name,
        widget.module.name,
        'Portugués',
      );
      
      if (mounted && content != null) {
        setState(() {
          _descriptionController.text = content;
          _isGeneratingAI = false;
        });
        _aiController.success();
        openToast(context, 'Contenido generado con IA exitosamente');
      } else {
        throw Exception('No se pudo generar contenido');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingAI = false);
        _aiController.error();
        openToast(context, 'Error al generar contenido: $e');
      }
    }
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _aiController.reset();
    });
  }

  Future<void> _uploadPDF() async {
    final ImagePicker picker = ImagePicker();
    // Note: ImagePicker para web puede manejar PDFs también
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    
    if (file != null) {
      try {
        final url = await FirebaseService().uploadImageToFirebaseHosting(
          file,
          'course_materials',
        );
        
        if (url != null) {
          setState(() {
            _pdfLinks.add(url);
          });
          if (mounted) {
            openToast(context, 'Archivo cargado exitosamente');
          }
        }
      } catch (e) {
        if (mounted) {
          openToast(context, 'Error al cargar archivo: $e');
        }
      }
    }
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) {
      _saveController.error();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _saveController.reset();
      });
      return;
    }

    try {
      String? videoUrl = _videoUrlController.text.trim();
      
      // Si hay URL de YouTube, convertirla al formato embed
      if (_youtubeUrlController.text.trim().isNotEmpty) {
        final youtubeUrl = _youtubeUrlController.text.trim();
        if (youtubeUrl.contains('youtube.com') || youtubeUrl.contains('youtu.be')) {
          // Extraer ID del video
          String? videoId;
          if (youtubeUrl.contains('v=')) {
            videoId = youtubeUrl.split('v=')[1].split('&')[0];
          } else if (youtubeUrl.contains('youtu.be/')) {
            videoId = youtubeUrl.split('youtu.be/')[1].split('?')[0];
          }
          
          if (videoId != null) {
            videoUrl = 'https://www.youtube.com/embed/$videoId';
          }
        }
      }

      // Buscar la sección de la lección
      final sectionId = widget.lesson.sectionId ?? 'seccion-${widget.module.id}';

      await FirebaseService().firestore
          .collection('courses')
          .doc(widget.courseId)
          .collection('levels')
          .doc(widget.levelId)
          .collection('modules')
          .doc(widget.module.id)
          .collection('sections')
          .doc(sectionId)
          .collection('lessons')
          .doc(widget.lesson.id)
          .update({
        'description': _descriptionController.text.trim(),
        'video_url': videoUrl,
        'content_type': _contentType,
        'pdf_links': _pdfLinks,
        'updated_at': DateTime.now(),
      });

      _saveController.success();
      
      if (mounted) {
        openToast(context, 'Lección actualizada exitosamente');
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      _saveController.error();
      if (mounted) {
        openToast(context, 'Error al guardar: $e');
      }
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _saveController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
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
                        Text(
                          'Editar Lección',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.lesson.name,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
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
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo de contenido
                      const Text(
                        'Tipo de Contenido',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _contentType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'video', child: Text('Video')),
                          DropdownMenuItem(value: 'article', child: Text('Artículo')),
                          DropdownMenuItem(value: 'quiz', child: Text('Quiz')),
                        ],
                        onChanged: (value) {
                          setState(() => _contentType = value!);
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Descripción con botón de IA
                      Row(
                        children: [
                          const Text(
                            'Descripción',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          RoundedLoadingButton(
                            controller: _aiController,
                            onPressed: _generateAIContent,
                            color: Colors.purple,
                            height: 36,
                            width: 180,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text(
                                  'Generar con IA',
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Describe los objetivos y contenido de esta lección...',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La descripción es requerida';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // URL de Video
                      const Text(
                        'URL de Video (directo)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _videoUrlController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'https://ejemplo.com/video.mp4',
                          prefixIcon: Icon(Icons.video_library),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // URL de YouTube
                      const Text(
                        'URL de YouTube',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _youtubeUrlController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'https://www.youtube.com/watch?v=...',
                          prefixIcon: Icon(Icons.play_circle, color: Colors.red),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Materiales (PDFs, Word, etc.)
                      Row(
                        children: [
                          const Text(
                            'Materiales Educativos',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _uploadPDF,
                            icon: const Icon(Icons.upload_file, size: 18),
                            label: const Text('Subir Archivo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      if (_pdfLinks.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'No hay archivos cargados',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...List.generate(_pdfLinks.length, (index) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                              title: Text('Archivo ${index + 1}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _pdfLinks.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              
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
                  RoundedLoadingButton(
                    controller: _saveController,
                    onPressed: _saveLesson,
                    color: Theme.of(context).primaryColor,
                    child: const Text(
                      'Guardar Cambios',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
