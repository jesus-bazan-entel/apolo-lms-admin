
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AiContentService {
  final String apiKey;

  AiContentService(this.apiKey);

  Future<String?> generateLessonContent(String topic, String level, String language) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt = 'Generate a detailed lesson for a language course. \nTopic: $topic\nLevel: $level\nLanguage: $language\nFormat: HTML (styled for a mobile app, no html/body tags). Include headings, paragraphs, and minimal examples.';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text;
    } catch (e) {
      debugPrint('AI Generation Error: $e');
      return null;
    }
  }

  Future<String?> generateQuiz(String topic, String level, String language) async {
     try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt = 'Generate 3 multiple choice questions for a language course in JSON format. \nTopic: $topic\nLevel: $level\nLanguage: $language. \nStructure: [{"question": "...", "options": ["A", "B", "C", "D"], "correct_index": 0}]';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      // Basic cleanup to ensure we get just the JSON part if the model adds markdown
      String? text = response.text;
      if (text != null && text.contains('```json')) {
        text = text.replaceAll('```json', '').replaceAll('```', '');
      }
      return text;
    } catch (e) {
      debugPrint('AI Generation Error: $e');
      return null;
    }
  }
}
