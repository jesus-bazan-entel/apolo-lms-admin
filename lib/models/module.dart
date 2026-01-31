import 'package:cloud_firestore/cloud_firestore.dart';

class Module {
  final String id;
  final String levelId;
  final String courseId;
  final String name; // "Módulo 1: Fundamentos del Portugués"
  final String description;
  final int order;
  int totalClasses; // 16 clases por módulo
  final DateTime? createdAt;
  final DateTime? updatedAt;
  List<Map<String, dynamic>> lessons; // Para uso en parseo de estructura

  Module({
    required this.id,
    required this.levelId,
    required this.courseId,
    required this.name,
    required this.description,
    required this.order,
    required this.totalClasses,
    this.createdAt,
    this.updatedAt,
    this.lessons = const [],
  });

  factory Module.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<String, dynamic>;
    return Module(
      id: snap.id,
      levelId: d['level_id'] ?? '',
      courseId: d['course_id'] ?? '',
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      order: d['order'] ?? 0,
      totalClasses: d['total_classes'] ?? 16,
      createdAt: d['created_at'] == null ? null : (d['created_at'] as Timestamp).toDate().toLocal(),
      updatedAt: d['updated_at'] == null ? null : (d['updated_at'] as Timestamp).toDate().toLocal(),
    );
  }

  static Map<String, dynamic> getMap(Module module) {
    return {
      'level_id': module.levelId,
      'course_id': module.courseId,
      'name': module.name,
      'description': module.description,
      'order': module.order,
      'total_classes': module.totalClasses,
      'created_at': module.createdAt,
      'updated_at': module.updatedAt,
    };
  }
}
