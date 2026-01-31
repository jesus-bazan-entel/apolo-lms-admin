
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AiContentService {
  static const List<String> _modelFallbackOrder = [
    'gemini-2.0-flash-exp',
    'gemini-2.0-flash-latest',
    'gemini-2.0-flash',
    'gemini-1.5-pro-latest',
    'gemini-1.5-pro',
    'gemini-1.5-flash-latest',
    'gemini-1.5-flash',
    'gemini-1.0-pro-latest',
    'gemini-1.0-pro',
    'gemini-pro',
  ];

  final String apiKey;

  AiContentService(this.apiKey);

  /// Genera contenido de lección con HTML formateado
  Future<String?> generateLessonContent(String topic, String level, String language) async {
    final prompt = '''
Generate a detailed lesson for a language course.
Topic: $topic
Level: $level
Language: $language

Format: HTML (styled for a mobile app, no html/body tags).
Include:
- Clear headings (h2, h3)
- Well-structured paragraphs
- Practical examples with <code> tags
- Key vocabulary highlighted with <strong>
- Tips in <blockquote> tags

Keep the content educational and engaging.
''';
    return _generateWithFallback(prompt);
  }

  /// Genera un cuestionario en formato JSON
  Future<String?> generateQuiz(String topic, String level, String language) async {
    final prompt = '''
Generate 5 multiple choice questions for a language course.
Topic: $topic
Level: $level
Language: $language

Return ONLY a valid JSON array with this exact structure:
[
  {
    "question": "Question text here",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct_index": 0
  }
]

Make questions progressively harder. Include grammar, vocabulary, and comprehension questions.
''';
    return _generateWithFallback(prompt, cleanupJson: true);
  }

  /// Genera descripción del curso
  Future<String?> generateCourseDescription(String courseName, String level, String language) async {
    final prompt = '''
Write a compelling course description in $language.
Course: $courseName
Level: $level

Requirements:
- 2-3 engaging paragraphs
- Highlight what students will learn
- Mention the teaching methodology
- Include target audience
- Use professional but accessible tone

Do NOT include HTML tags, just plain text with paragraph breaks.
''';
    return _generateWithFallback(prompt);
  }

  /// Genera resumen corto del curso
  Future<String?> generateCourseSummary(String courseName, String level, String language) async {
    final prompt = '''
Write a brief course summary in $language (max 150 characters).
Course: $courseName
Level: $level

This will be used for course cards/previews. Be concise but compelling.
''';
    return _generateWithFallback(prompt);
  }

  /// Genera requisitos del curso
  Future<String?> generateCourseRequirements(String courseName, String level, String language) async {
    final prompt = '''
List course prerequisites in $language.
Course: $courseName
Level: $level

Return 3-5 bullet points with prerequisites students should have.
Format: One requirement per line starting with "•"
Be specific about knowledge level needed.
''';
    return _generateWithFallback(prompt);
  }

  /// Genera lista de aprendizajes
  Future<String?> generateCourseLearnings(String courseName, String level, String language) async {
    final prompt = '''
Write "What you'll learn" outcomes in $language.
Course: $courseName
Level: $level

Return 4-6 bullet points with learning outcomes.
Format: One outcome per line starting with "•"
Use action verbs (Build, Create, Understand, Apply, etc.)
Be specific and measurable.
''';
    return _generateWithFallback(prompt);
  }

  /// Genera estructura de módulos
  Future<String?> generateCourseStructure(String courseName, String level, String language, int moduleCount) async {
    final prompt = '''
Generate a course structure in $language.
Course: $courseName
Level: $level
Number of modules: $moduleCount

Return a JSON array with this structure:
[
  {
    "name": "Module name",
    "description": "Brief module description",
    "lessons": ["Lesson 1 title", "Lesson 2 title", "Lesson 3 title"]
  }
]

Make modules progressively build on each other. Each module should have 3-5 lessons.
''';
    return _generateWithFallback(prompt, cleanupJson: true);
  }

  /// Genera ejercicios prácticos
  Future<String?> generateExercises(String topic, String level, String language) async {
    final prompt = '''
Generate 3 practical exercises in $language.
Topic: $topic
Level: $level

Return as numbered list with:
1. Exercise description
2. Expected outcome
3. Hints or tips

Format in plain text with clear separations.
''';
    return _generateWithFallback(prompt);
  }

  Future<String?> _generateWithFallback(String prompt, {bool cleanupJson = false}) async {
    for (final modelName in _modelFallbackOrder) {
      try {
        final model = GenerativeModel(model: modelName, apiKey: apiKey);
        final response = await model.generateContent([Content.text(prompt)]);
        String? text = response.text;

        if (text == null || text.trim().isEmpty) {
          continue;
        }

        if (cleanupJson && text.contains('```')) {
          text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        }

        debugPrint('AI Generation succeeded with model: $modelName');
        return text;
      } catch (e) {
        final message = e.toString();
        final isModelUnsupported = message.contains('is not found') || 
            message.contains('not supported for generateContent') ||
            message.contains('models/');

        if (isModelUnsupported) {
          debugPrint('AI model $modelName unavailable. Trying next model.');
          continue;
        }

        debugPrint('AI Generation Error using $modelName: $e');
        return null;
      }
    }

    debugPrint('AI Generation Error: No compatible Gemini model available.');
    return null;
  }
}
