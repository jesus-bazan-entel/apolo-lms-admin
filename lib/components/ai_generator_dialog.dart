import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/services/ai_content_service.dart';
import 'package:lms_admin/utils/toasts.dart';

enum AiContentType {
  description,
  summary,
  requirements,
  learnings,
  lessonContent,
  quiz,
}

class AiGeneratorDialog extends ConsumerStatefulWidget {
  final String courseName;
  final String? topic;
  final String level;
  final String language;
  final AiContentType contentType;
  final Function(String) onGenerated;

  const AiGeneratorDialog({
    Key? key,
    required this.courseName,
    this.topic,
    required this.level,
    required this.language,
    required this.contentType,
    required this.onGenerated,
  }) : super(key: key);

  @override
  ConsumerState<AiGeneratorDialog> createState() => _AiGeneratorDialogState();
}

class _AiGeneratorDialogState extends ConsumerState<AiGeneratorDialog> {
  bool _isGenerating = false;
  String? _generatedContent;
  String? _error;
  final _customPromptController = TextEditingController();
  bool _useCustomPrompt = false;

  @override
  void dispose() {
    _customPromptController.dispose();
    super.dispose();
  }

  String get _contentTypeLabel {
    switch (widget.contentType) {
      case AiContentType.description:
        return 'Descripción del Curso';
      case AiContentType.summary:
        return 'Resumen del Curso';
      case AiContentType.requirements:
        return 'Requisitos del Curso';
      case AiContentType.learnings:
        return 'Lo que Aprenderás';
      case AiContentType.lessonContent:
        return 'Contenido de la Lección';
      case AiContentType.quiz:
        return 'Cuestionario';
    }
  }

  IconData get _contentTypeIcon {
    switch (widget.contentType) {
      case AiContentType.description:
        return Icons.description_outlined;
      case AiContentType.summary:
        return Icons.summarize_outlined;
      case AiContentType.requirements:
        return Icons.checklist_outlined;
      case AiContentType.learnings:
        return Icons.lightbulb_outline;
      case AiContentType.lessonContent:
        return Icons.article_outlined;
      case AiContentType.quiz:
        return Icons.quiz_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildCustomPromptSection(),
                    const SizedBox(height: 20),
                    if (_isGenerating) _buildLoadingState(),
                    if (_error != null) _buildErrorState(),
                    if (_generatedContent != null) _buildGeneratedContent(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppConfig.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_contentTypeIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generador con IA',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _contentTypeLabel,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Contexto',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Curso', widget.courseName),
          if (widget.topic != null) _buildInfoRow('Tema', widget.topic!),
          _buildInfoRow('Nivel', widget.level),
          _buildInfoRow('Idioma', widget.language),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPromptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _useCustomPrompt,
              onChanged: (v) => setState(() => _useCustomPrompt = v ?? false),
              activeColor: AppConfig.themeColor,
            ),
            Text(
              'Usar instrucciones personalizadas',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
        if (_useCustomPrompt) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _customPromptController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escribe instrucciones adicionales para la IA...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppConfig.themeColor),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppConfig.themeColor),
          ),
          const SizedBox(height: 20),
          Text(
            'Generando contenido con IA...',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto puede tomar unos segundos',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConfig.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppConfig.errorColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: GoogleFonts.poppins(
                color: AppConfig.errorColor,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: _generateContent,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: AppConfig.successColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Contenido Generado',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          constraints: const BoxConstraints(maxHeight: 250),
          child: SingleChildScrollView(
            child: SelectableText(
              _generatedContent!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 12),
          if (_generatedContent == null)
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateContent,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                'Generar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          else
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _generatedContent = null;
                      _error = null;
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Regenerar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConfig.themeColor,
                    side: const BorderSide(color: AppConfig.themeColor),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _useGeneratedContent,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(
                    'Usar este contenido',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _generateContent() async {
    setState(() {
      _isGenerating = true;
      _error = null;
      _generatedContent = null;
    });

    try {
      final aiService = AiContentService(AppConfig.geminiApiKey);
      String? result;

      final customInstructions = _useCustomPrompt && _customPromptController.text.isNotEmpty
          ? _customPromptController.text
          : null;

      switch (widget.contentType) {
        case AiContentType.description:
          result = await _generateDescription(aiService, customInstructions);
          break;
        case AiContentType.summary:
          result = await _generateSummary(aiService, customInstructions);
          break;
        case AiContentType.requirements:
          result = await _generateRequirements(aiService, customInstructions);
          break;
        case AiContentType.learnings:
          result = await _generateLearnings(aiService, customInstructions);
          break;
        case AiContentType.lessonContent:
          result = await aiService.generateLessonContent(
            widget.topic ?? widget.courseName,
            widget.level,
            widget.language,
          );
          break;
        case AiContentType.quiz:
          result = await aiService.generateQuiz(
            widget.topic ?? widget.courseName,
            widget.level,
            widget.language,
          );
          break;
      }

      if (result != null && result.isNotEmpty) {
        setState(() => _generatedContent = result);
      } else {
        setState(() => _error = 'No se pudo generar el contenido. Intenta de nuevo.');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<String?> _generateDescription(AiContentService service, String? custom) async {
    // Usar el método existente del servicio o crear uno nuevo
    final prompt = '''
Generate a compelling course description in ${widget.language}.
Course: ${widget.courseName}
Level: ${widget.level}
${custom != null ? 'Additional instructions: $custom' : ''}

Write a professional, engaging description (2-3 paragraphs) that:
- Explains what the course covers
- Highlights the benefits for students
- Uses persuasive language
''';
    return service.generateLessonContent(prompt, widget.level, widget.language);
  }

  Future<String?> _generateSummary(AiContentService service, String? custom) async {
    final prompt = '''
Generate a brief course summary in ${widget.language}.
Course: ${widget.courseName}
Level: ${widget.level}
${custom != null ? 'Additional instructions: $custom' : ''}

Write a concise summary (1-2 sentences) suitable for a course card or preview.
''';
    return service.generateLessonContent(prompt, widget.level, widget.language);
  }

  Future<String?> _generateRequirements(AiContentService service, String? custom) async {
    final prompt = '''
Generate course requirements/prerequisites in ${widget.language}.
Course: ${widget.courseName}
Level: ${widget.level}
${custom != null ? 'Additional instructions: $custom' : ''}

List 3-5 prerequisites as bullet points that students should have before taking this course.
Format: One requirement per line starting with "•"
''';
    return service.generateLessonContent(prompt, widget.level, widget.language);
  }

  Future<String?> _generateLearnings(AiContentService service, String? custom) async {
    final prompt = '''
Generate "What you'll learn" section in ${widget.language}.
Course: ${widget.courseName}
Level: ${widget.level}
${custom != null ? 'Additional instructions: $custom' : ''}

List 4-6 learning outcomes as bullet points.
Format: One learning outcome per line starting with "•"
Be specific and action-oriented (e.g., "Build...", "Understand...", "Create...")
''';
    return service.generateLessonContent(prompt, widget.level, widget.language);
  }

  void _useGeneratedContent() {
    if (_generatedContent != null) {
      widget.onGenerated(_generatedContent!);
      Navigator.pop(context);
      openSuccessToast(context, 'Contenido aplicado exitosamente');
    }
  }
}

// Helper function to show the dialog
void showAiGeneratorDialog({
  required BuildContext context,
  required String courseName,
  String? topic,
  required String level,
  required String language,
  required AiContentType contentType,
  required Function(String) onGenerated,
}) {
  showDialog(
    context: context,
    builder: (context) => AiGeneratorDialog(
      courseName: courseName,
      topic: topic,
      level: level,
      language: language,
      contentType: contentType,
      onGenerated: onGenerated,
    ),
  );
}
