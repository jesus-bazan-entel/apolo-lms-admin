import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para el conteo de estudiantes en tiempo real
/// Excluye usuarios con rol 'admin' o 'author'
final usersCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    int count = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (!_isAdminOrAuthor(data['role'])) {
        count++;
      }
    }
    return count;
  });
});

/// Provider para estudiantes activos en tiempo real
final activeStudentsCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    int count = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final disabled = data['disabled'] as bool? ?? false;
      if (!_isAdminOrAuthor(data['role']) && !disabled) {
        count++;
      }
    }
    return count;
  });
});

/// Provider para conteo de reseñas en tiempo real
final reviewsCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('reviews')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Provider para conteo de cursos en tiempo real
final coursesCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('courses')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Provider para conteo de compras en tiempo real
final purchasesCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('purchases')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Provider para conteo de notificaciones en tiempo real
final notificationsCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Provider para usuarios suscritos en tiempo real
final subscriberCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    int count = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['subscription'] != null) {
        count++;
      }
    }
    return count;
  });
});

/// Provider para usuarios con cursos inscritos en tiempo real
final enrolledCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    int count = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final enrolled = data['enrolled'] as List?;
      if (enrolled != null && enrolled.isNotEmpty) {
        count++;
      }
    }
    return count;
  });
});

/// Provider para conteo de autores en tiempo real
final authorsCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    int count = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final role = data['role'];
      if (role is List && role.contains('author')) {
        count++;
      } else if (role is String && role == 'author') {
        count++;
      }
    }
    return count;
  });
});

/// Helper para verificar si es admin o author
bool _isAdminOrAuthor(dynamic role) {
  if (role == null) return false;
  if (role is String) {
    return role.toLowerCase() == 'admin' || role.toLowerCase() == 'author';
  }
  if (role is List) {
    return role.any((r) =>
        r.toString().toLowerCase() == 'admin' ||
        r.toString().toLowerCase() == 'author');
  }
  return false;
}
