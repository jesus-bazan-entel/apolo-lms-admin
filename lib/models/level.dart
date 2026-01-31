import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_admin/models/module.dart';

class Level {
  final String id;
  final String courseId;
  final String name; // "Nivel Básico", "Nivel Intermedio", etc.
  final String description;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  List<Module> modules; // Para uso en parseo de estructura

  Level({
    required this.id,
    required this.courseId,
    required this.name,
    required this.description,
    required this.order,
    this.createdAt,
    this.updatedAt,
    this.modules = const [],
  });

  factory Level.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<String, dynamic>;
    return Level(
      id: snap.id,
      courseId: d['course_id'] ?? '',
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      order: d['order'] ?? 0,
      createdAt: d['created_at'] == null ? null : (d['created_at'] as Timestamp).toDate().toLocal(),
      updatedAt: d['updated_at'] == null ? null : (d['updated_at'] as Timestamp).toDate().toLocal(),
    );
  }

  static Map<String, dynamic> getMap(Level level) {
    return {
      'course_id': level.courseId,
      'name': level.name,
      'description': level.description,
      'order': level.order,
      'created_at': level.createdAt,
      'updated_at': level.updatedAt,
    };
  }
}
