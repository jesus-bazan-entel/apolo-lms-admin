import 'package:cloud_firestore/cloud_firestore.dart';

import 'author_info.dart';
import 'subscription.dart';

class UserModel {
  final String id, email, name;
  DateTime? createdAt;
  DateTime? updatedAt;
  final String? imageUrl;
  List? role;
  List? enrolledCourses;
  List? wishList;
  bool? isDisbaled;
  AuthorInfo? authorInfo;
  Subscription? subscription;
  List? completedLessons;
  final String? platform;
  final String? qrCodeHash;
  final String? paymentStatus;
  final String? studentLevel;
  final String? studentSection;

  /// Cursos asignados al tutor (solo para rol tutor)
  List? assignedCourses;

  /// Permisos específicos del tutor
  Map<String, dynamic>? tutorPermissions;

  // Getter for disabled (alias for isDisbaled with typo)
  bool? get disabled => isDisbaled;

  /// Indica si el usuario es un tutor
  bool get isTutor => role?.contains('tutor') ?? false;

  /// Indica si el usuario es un administrador
  bool get isAdmin => role?.contains('admin') ?? false;

  UserModel({
    required this.id,
    required this.email,
    this.imageUrl,
    required this.name,
    this.role,
    this.wishList,
    this.enrolledCourses,
    this.isDisbaled,
    this.createdAt,
    this.updatedAt,
    this.authorInfo,
    this.subscription,
    this.completedLessons,
    this.platform,
    this.qrCodeHash,
    this.paymentStatus,
    this.studentLevel,
    this.studentSection,
    this.assignedCourses,
    this.tutorPermissions,
  });

  factory UserModel.fromFirebase(DocumentSnapshot snap) {
    Map d = snap.data() as Map<String, dynamic>;
    
    // Handle role field - can be String or List
    dynamic roleData = d['role'];
    List? roleList;
    if (roleData is String) {
      roleList = [roleData];
    } else if (roleData is List) {
      roleList = roleData;
    } else {
      roleList = [];
    }
    
    return UserModel(
      id: snap.id,
      email: d['email'],
      imageUrl: d['image_url'],
      name: d['name'],
      role: roleList,
      isDisbaled: d['disabled'] ?? false,
      createdAt: d['created_at'] == null ? null : (d['created_at'] as Timestamp).toDate().toLocal(),
      updatedAt: d['updated_at'] == null ? null : (d['updated_at'] as Timestamp).toDate().toLocal(),
      authorInfo: d['author_info'] == null ? null : AuthorInfo.fromMap(d['author_info']),
      enrolledCourses: d['enrolled'] ?? [],
      wishList: d['wishlist'] ?? [],
      subscription: d['subscription'] == null ? null : Subscription.fromFirestore(d['subscription']),
      completedLessons: d['completed_lessons'] ?? [],
      platform: d['platform'],
      qrCodeHash: d['qr_code_hash'],
      paymentStatus: d['payment_status'],
      studentLevel: d['student_level'],
      studentSection: d['student_section'],
      assignedCourses: d['assigned_courses'] ?? [],
      tutorPermissions: d['tutor_permissions'] != null
          ? Map<String, dynamic>.from(d['tutor_permissions'])
          : null,
    );
  }

  static Map<String, dynamic> getMap(UserModel user) {
    return {
      'email': user.email,
      'name': user.name,
      'image_url': user.imageUrl,
      'created_at': user.createdAt,
      'qr_code_hash': user.qrCodeHash,
      'payment_status': user.paymentStatus,
      'student_level': user.studentLevel,
      'student_section': user.studentSection,
    };
  }
}
