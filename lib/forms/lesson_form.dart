import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/app_strings.dart';
import 'package:lms_admin/models/lesson.dart';
import 'package:lms_admin/services/ai_content_service.dart';
import 'package:lms_admin/services/firebase_service.dart';

/// Formulario para crear/editar lecciones con soporte ampliado de contenido
class LessonForm extends ConsumerStatefulWidget {
  final String courseDocId;
  final String sectionId;
  final Lesson? lesson;
  final VoidCallback? onSave;

  const LessonForm({
    Key? key,
    required this.courseDocId,
    required this.sectionId,
    this.lesson,
    this.onSave,
  }) : super(key: key);

  @override
  ConsumerState<LessonForm> createState() => _LessonFormState();
}

class _LessonFormState extends ConsumerState<LessonForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtlr = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  final _durationCtlr = TextEditingController();
  final _lessonBodyController = TextEditingController();
  final _aiPromptController = TextEditingController();
  
  String _contentType = 'video';
  bool _isFree = false;
  bool _isGenerating = false;
  bool _isSaving = false;
  List<LessonMaterial> _materials = [];
  YouTubeVideo? _youtubeVideo;
  LocalVideo? _localVideo;
  int _order = 0;

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      _initializeFromLesson(widget.lesson!);
    }
  }

  void _initializeFromLesson(Lesson lesson) {
    _nameCtlr.text = lesson.name;
    _contentType = lesson.contentType;
    _isFree = lesson.isFree;
    _durationCtlr.text = lesson.duration.toString();
    _lessonBodyController.text = lesson.lessonBody ?? '';
    _materials = lesson.materials ?? [];
    _youtubeVideo = lesson.youtubeVideo;
    _localVideo = lesson.localVideo;
    _order = lesson.order;
    
    if (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty) {
      _videoUrlController.text = lesson.videoUrl!;
    }
    
    if (_youtubeVideo != null) {
      _youtubeUrlController.text = _youtubeVideo!.url;
    }
  }

  @override
  void dispose() {
    _nameCtlr.dispose();
    _videoUrlController.dispose();
    _youtubeUrlController.dispose();
    _durationCtlr.dispose();
    _lessonBodyController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  Future<void> _generateContent() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un prompt para generar contenido')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final aiService = AiContentService(AppConfig.geminiApiKey);
      final content = await aiService.generateLessonContent(
        _nameCtlr.text,
        'intermedio',
        'portugués',
      );

      if (mounted) {
        setState(() {
          _lessonBodyController.text = content ?? '';
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Contenido generado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al generar contenido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _parseYouTubeUrl() async {
    final url = _youtubeUrlController.text.trim();
    if (url.isEmpty) return;

    try {
      // Extraer el ID del video de YouTube usando regex
      final regex = RegExp(r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})');
      final match = regex.firstMatch(url);
      
      if (match != null && match.groupCount >= 1) {
        final videoId = match.group(1);
        if (videoId != null && videoId.length == 11) {
          setState(() {
            _youtubeVideo = YouTubeVideo(
              videoId: videoId,
              title: 'Video de YouTube',
              thumbnailUrl: 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Video de YouTube detectado')),
          );
          return;
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL de YouTube inválida')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al parsear URL: $e')),
      );
    }
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final lessonId = widget.lesson?.id ?? FirebaseService.getUID('lessons');
      final duration = _durationCtlr.text.trim().isEmpty ? 0 : int.tryParse(_durationCtlr.text.trim()) ?? 0;
      
      final lesson = Lesson(
        id: lessonId,
        name: _nameCtlr.text.trim(),
        order: _order,
        contentType: _contentType,
        videoUrl: _videoUrlController.text.trim().isEmpty ? null : _videoUrlController.text.trim(),
        lessonBody: _lessonBodyController.text.trim().isEmpty ? null : _lessonBodyController.text.trim(),
        duration: duration,
        isFree: _isFree,
        materials: _materials.isEmpty ? null : _materials,
        youtubeVideo: _youtubeVideo,
        localVideo: _localVideo,
        thumbnailUrl: _youtubeVideo?.thumbnailUrl,
        createdAt: widget.lesson?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseService().saveLesson(
        widget.courseDocId,
        widget.sectionId,
        lesson,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Lección guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSave?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar lección: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson == null ? 'Nueva Lección' : 'Editar Lección'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveLesson,
              child: const Text('Guardar'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildContentTypeDropdown(),
            const SizedBox(height: 16),
            _buildVideoUrlSection(),
            const SizedBox(height: 16),
            _buildYouTubeSection(),
            const SizedBox(height: 16),
            _buildDurationField(),
            const SizedBox(height: 16),
            _buildIsFreeToggle(),
            const SizedBox(height: 16),
            _buildLessonBodySection(),
            const SizedBox(height: 16),
            _buildAIContentSection(),
            const SizedBox(height: 16),
            _buildMaterialsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtlr,
      decoration: const InputDecoration(
        labelText: 'Nombre de la lección',
        hintText: 'Ej: Introducción al Portugués',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, ingresa el nombre de la lección';
        }
        return null;
      },
    );
  }

  Widget _buildContentTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _contentType,
      decoration: const InputDecoration(
        labelText: 'Tipo de contenido',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'video', child: Text('Video')),
        DropdownMenuItem(value: 'article', child: Text('Artículo')),
        DropdownMenuItem(value: 'quiz', child: Text('Cuestionario')),
        DropdownMenuItem(value: 'document', child: Text('Documento')),
        DropdownMenuItem(value: 'youtube', child: Text('YouTube')),
        DropdownMenuItem(value: 'mixed', child: Text('Mixto')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _contentType = value);
        }
      },
    );
  }

  Widget _buildVideoUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video URL',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _videoUrlController,
          decoration: const InputDecoration(
            hintText: 'https://ejemplo.com/video.mp4',
            border: OutlineInputBorder(),
            helperText: 'URL del video (MP4, MPG, MPEG, WebM)',
          ),
        ),
      ],
    );
  }

  Widget _buildYouTubeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video de YouTube',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _youtubeUrlController,
          decoration: InputDecoration(
            hintText: 'https://www.youtube.com/watch?v=...',
            border: const OutlineInputBorder(),
            helperText: 'URL del video de YouTube',
            suffixIcon: IconButton(
              icon: const Icon(Icons.check),
              onPressed: _parseYouTubeUrl,
            ),
          ),
        ),
        if (_youtubeVideo != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Video detectado: ${_youtubeVideo!.videoId}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDurationField() {
    return TextFormField(
      controller: _durationCtlr,
      decoration: const InputDecoration(
        labelText: 'Duración (minutos)',
        hintText: 'Ej: 30',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildIsFreeToggle() {
    return SwitchListTile(
      title: const Text('Lección gratuita'),
      subtitle: const Text('Los usuarios pueden ver esta lección sin suscripción'),
      value: _isFree,
      onChanged: (value) {
        setState(() => _isFree = value);
      },
    );
  }

  Widget _buildLessonBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contenido de la lección',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _lessonBodyController,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Escribe el contenido de la lección aquí...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildAIContentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.05),
            Colors.blue.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generador de Contenido con IA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Genera contenido educativo automáticamente',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _aiPromptController,
            decoration: InputDecoration(
              hintText: 'Describe el tema de la lección (ej: "Verbos regulares en portugués")...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateContent,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isGenerating ? 'Generando contenido...' : 'Generar Contenido con IA',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '💡 El contenido generado se insertará en el campo "Contenido de la lección" arriba.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Materiales adjuntos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Implementar subida de archivos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad de subida de archivos próximamente')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Material'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_materials.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No hay materiales adjuntos',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _materials.length,
            itemBuilder: (context, index) {
              final material = _materials[index];
              return ListTile(
                leading: Icon(_getMaterialIcon(material.type)),
                title: Text(material.name),
                subtitle: Text(material.type.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _materials.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  IconData _getMaterialIcon(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf;
      case DocumentType.word:
        return Icons.description;
      case DocumentType.image:
        return Icons.image;
      case DocumentType.video:
        return Icons.videocam;
      case DocumentType.text:
        return Icons.text_snippet;
    }
  }
}
