import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms_admin/configs/constants.dart';
import 'package:lms_admin/models/notification_model.dart';
import 'package:lms_admin/models/app_settings_model.dart';
import 'package:lms_admin/models/category.dart';
import 'package:lms_admin/models/lesson.dart';
import 'package:lms_admin/models/level.dart';
import 'package:lms_admin/models/module.dart';
import 'package:lms_admin/models/purchase_history.dart';
import 'package:lms_admin/models/review.dart';
import 'package:lms_admin/models/tag.dart';
import 'package:lms_admin/models/chart_model.dart';
import '../models/course.dart';
import '../models/section.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static String getUID(String collectionName) => FirebaseFirestore.instance.collection(collectionName).doc().id;

  Future deleteContent(String collectionName, String documentName) async {
    await firestore.collection(collectionName).doc(documentName).delete();
  }

  Future updateUserAccess({required String userId, required bool shouldDisable}) async {
    return await firestore.collection('users').doc(userId).update({'disabled': shouldDisable});
  }

  Future updateAuthorAccess({required String userId, required bool shouldAssign}) async {
    final Map<String, dynamic> data = shouldAssign
        ? {
            'role': ['author']
          }
        : {'role': null};
    return await firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  Future updateUserQrHash({required String userId, required String hash}) async {
    return await firestore.collection('users').doc(userId).update({'qr_code_hash': hash});
  }

  Future updateUserPaymentStatus({required String userId, required bool isPaid}) async {
    return await firestore.collection('users').doc(userId).update({'payment_status': isPaid ? 'paid' : 'unpaid'});
  }

  Future updateUserLevelSection({required String userId, String? level, String? section}) async {
    return await firestore.collection('users').doc(userId).update({
      'student_level': level,
      'student_section': section,
    });
  }

  Future removeCategoryFromFeatured(String documentName) async {
    return firestore.collection('categories').doc(documentName).update({'featured': false});
  }

  Future addCategoryToFeatured(String documentName) async {
    return firestore.collection('categories').doc(documentName).update({'featured': true});
  }

  Future<String?> uploadImageToFirebaseHosting(XFile image, String folderName) async {
    //return download link
    Uint8List imageData = await XFile(image.path).readAsBytes();
    final Reference storageReference = FirebaseStorage.instance.ref().child('$folderName/${image.name}.png');
    final SettableMetadata metadata = SettableMetadata(contentType: 'image/png');
    final UploadTask uploadTask = storageReference.putData(imageData, metadata);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    String? imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<UserModel?> getUserData() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot snap = await firestore.collection('users').doc(userId).get();
    UserModel? user = UserModel.fromFirebase(snap);
    return user;
  }

  Future saveCategory(Category category) async {
    const String collectionName = 'categories';
    Map<String, dynamic> data = Category.getMap(category);
    await firestore.collection(collectionName).doc(category.id).set(data, SetOptions(merge: true));
  }

  Future saveCourse(Course course) async {
    final Map<String, dynamic> data = Course.getMap(course);
    await firestore.collection('courses').doc(course.id).set(data, SetOptions(merge: true));
  }

  Future saveSection(String courseId, Section section) async {
    final Map<String, dynamic> data = Section.getMap(section);
    await firestore.collection('courses').doc(courseId).collection('sections').doc(section.id).set(data, SetOptions(merge: true));
  }

  Future saveLesson(String courseId, String sectionId, Lesson lesson) async {
    final Map<String, dynamic> data = Lesson.getMap(lesson);
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lesson.id)
        .set(data, SetOptions(merge: true));
  }

  Future saveNotification(NotificationModel notification) async {
    final Map<String, dynamic> data = NotificationModel.getMap(notification);
    await firestore.collection('notifications').doc(notification.id).set(data);
  }

  Future<List<Category>> getCategories() async {
    List<Category> data = [];
    await firestore.collection('categories').orderBy('index', descending: false).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Category.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Course>> getTopCourses(int limit) async {
    List<Course> data = [];
    await firestore.collection('courses').orderBy('students', descending: true).limit(limit).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Course.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Course>> getAllCourses() async {
    List<Course> data = [];
    await firestore.collection('courses').orderBy('created_at', descending: true).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Course.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<UserModel>> getLatestUsers(int limit) async {
    List<UserModel> data = [];
    await firestore.collection('users').orderBy('created_at', descending: true).limit(limit).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => UserModel.fromFirebase(e)).toList();
    });
    return data;
  }

  Future<List<Review>> getLatestReviews(int limit) async {
    List<Review> data = [];
    await firestore.collection('reviews').orderBy('created_at', descending: true).limit(limit).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Review.fromFirebase(e)).toList();
    });
    return data;
  }

  Future<List<PurchaseHistory>> getLatestPurchases(int limit) async {
    List<PurchaseHistory> data = [];
    await firestore.collection('purchases').orderBy('purchase_at', descending: true).limit(limit).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => PurchaseHistory.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<UserModel>> getAuthors() async {
    List<UserModel> data = [];
    await firestore.collection('users').where('role', arrayContains: 'author').get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => UserModel.fromFirebase(e)).toList();
    });
    return data;
  }

  Future<AppSettingsModel?> getAppSettings() async {
    AppSettingsModel? settings;
    try {
      final DocumentSnapshot snap = await firestore.collection('settings').doc('app').get();
      settings = AppSettingsModel.fromFirestore(snap);
    } catch (e) {
      debugPrint('no settings data');
    }

    return settings;
  }

  Future<List<Tag>> getTags() async {
    List<Tag> data = [];
    await firestore.collection('tags').orderBy('created_at', descending: true).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Tag.fromFirestore(e)).toList();
    });
    return data;
  }

  Future saveTag(Tag tag) async {
    const String collectionName = 'tags';
    Map<String, dynamic> data = Tag.getMap(tag);
    await firestore.collection(collectionName).doc(tag.id).set(data, SetOptions(merge: true));
  }

  Future deleteSection(String courseDocId, String sectionId) async {
    await FirebaseFirestore.instance.collection('courses').doc(courseDocId).collection('sections').doc(sectionId).delete();
  }

  Future deleteLesson(String courseDocId, String sectionId, String lessonId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseDocId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lessonId)
        .delete();
  }

  static Query sectionsQuery(String courseDocId) {
    return FirebaseFirestore.instance.collection('courses').doc(courseDocId).collection('sections').orderBy('order', descending: false);
  }

  static Query notificationsQuery() {
    return FirebaseFirestore.instance.collection('notifications').orderBy('sent_at', descending: true);
  }

  static Query reviewsQuery() {
    return FirebaseFirestore.instance.collection('reviews').orderBy('created_at', descending: true);
  }

  static Query authorCourseReviewsQuery(String courseAuthorId) {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('course_author_id', isEqualTo: courseAuthorId)
        .orderBy('created_at', descending: true);
  }

  static Query lessonsQuery(String courseDocId, String sectionId) {
    return FirebaseFirestore.instance
        .collection('courses')
        .doc(courseDocId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .orderBy('order', descending: false);
  }

  Future updateSectionsOrder(List<Section> sections, String courseDocId) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < sections.length; i++) {
      final docRef = FirebaseFirestore.instance.collection('courses').doc(courseDocId).collection('sections').doc(sections[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  Future updateCategoriesOrder(List<Category> categories) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < categories.length; i++) {
      final docRef = FirebaseFirestore.instance.collection('categories').doc(categories[i].id);
      batch.update(docRef, {'index': i});
    }
    await batch.commit();
  }

  Future updateLessonsOrder(List<Lesson> lessons, String courseDocId, String sectionId) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < lessons.length; i++) {
      final docRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(courseDocId)
          .collection('sections')
          .doc(sectionId)
          .collection('lessons')
          .doc(lessons[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  Future updateLessonCountInCourse(String courseId, {required int count}) async {
    final DocumentReference docRef = firestore.collection('courses').doc(courseId);
    await docRef.set({'lessons_count': FieldValue.increment(count)}, SetOptions(merge: true));
  }

  Future updateUserProfile(UserModel user, Map<String, dynamic> data) async {
    await firestore.collection('users').doc(user.id).update(data);
  }

  Future updateFeaturedCourse(Course course, bool value) async {
    await firestore.collection('courses').doc(course.id).update({'featured': value});
  }

  Future updateAppSettings(Map<String, dynamic> data) async {
    await firestore.collection('settings').doc('app').set(data, SetOptions(merge: true));
  }

  Future<List<Course>> getUserCourses(List coursesIds) async {
    List<Course> courses = [];
    final CollectionReference colRef = firestore.collection('courses');
    final QuerySnapshot snapshot = await colRef.where(FieldPath.documentId, whereIn: coursesIds).get();
    courses = snapshot.docs.map((e) => Course.fromFirestore(e)).toList();
    return courses;
  }

  //New way for gettings counts
  Future<int> getCount(String path) async {
    final CollectionReference collectionReference = firestore.collection(path);
    AggregateQuerySnapshot snap = await collectionReference.count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getCourseCount() async {
    // Contar todos los cursos (sin filtrar por status)
    final CollectionReference collectionReference = firestore.collection('courses');
    AggregateQuerySnapshot snap = await collectionReference.count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getAuthorsCount() async {
    final CollectionReference collectionReference = firestore.collection('users');
    AggregateQuerySnapshot snap = await collectionReference.where('role', arrayContains: 'author').count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getStudentsCount() async {
    // Contar todos los usuarios menos los que son admin
    final CollectionReference collectionReference = firestore.collection('users');
    final QuerySnapshot allUsers = await collectionReference.get();
    int studentCount = 0;
    for (var doc in allUsers.docs) {
      final data = doc.data() as Map<String, dynamic>;
      // Manejar role como String o List
      if (!_isAdmin(data['role'])) {
        studentCount++;
      }
    }
    return studentCount;
  }

  Future<int> getActiveStudentsCount() async {
    // Contar usuarios activos que no son admin
    final CollectionReference collectionReference = firestore.collection('users');
    final QuerySnapshot allUsers = await collectionReference.get();
    int activeCount = 0;
    for (var doc in allUsers.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final disabled = data['disabled'] as bool? ?? false;
      // Si no tiene rol admin y no está deshabilitado
      if (!_isAdmin(data['role']) && !disabled) {
        activeCount++;
      }
    }
    return activeCount;
  }

  // Helper para verificar si es admin (maneja String o List)
  bool _isAdmin(dynamic role) {
    if (role == null) return false;
    if (role is String) return role == 'admin';
    if (role is List) return role.contains('admin');
    return false;
  }

  Future<int> getSubscribedUsersCount() async {
    final CollectionReference collectionReference = firestore.collection('users');
    AggregateQuerySnapshot snap = await collectionReference.where('subscription', isNull: false).count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getEnrolledUsersCount() async {
    final CollectionReference collectionReference = firestore.collection('users');
    AggregateQuerySnapshot snap = await collectionReference.where('enrolled', isNull: false).count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getAuthorCoursesCount(String authorId) async {
    final CollectionReference collectionReference = firestore.collection('courses');
    AggregateQuerySnapshot snap =
        await collectionReference.where('status', isEqualTo: courseStatus.keys.elementAt(2)).where('author.id', isEqualTo: authorId).count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getAuthorReviewsCount(String authorId) async {
    final CollectionReference collectionReference = firestore.collection('reviews');
    AggregateQuerySnapshot snap = await collectionReference.where('course_author_id', isEqualTo: authorId).count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future deleteCategoryRelatedCourses(String categoryId) async {
    WriteBatch batch = firestore.batch();
    final QuerySnapshot snapshot = await firestore.collection('courses').where('cat_id', isEqualTo: categoryId).get();
    if (snapshot.size != 0) {
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<List<ChartModel>> getUserStats(int days) async {
    List<ChartModel> stats = [];
    DateTime startDate = DateTime.now().subtract(Duration(days: days));
    
    // Primero intentar obtener de user_stats
    final QuerySnapshot snapshot = await firestore.collection('user_stats').where('timestamp', isGreaterThanOrEqualTo: startDate).get();
    
    if (snapshot.docs.isNotEmpty) {
      stats = snapshot.docs.map((e) => ChartModel.fromFirestore(e)).toList();
    } else {
      // Si no hay datos en user_stats, generar desde created_at de usuarios
      final QuerySnapshot usersSnapshot = await firestore.collection('users')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();
      
      // Agrupar por día
      Map<String, int> countByDay = {};
      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Solo contar si no es admin (usando helper que maneja String o List)
        if (!_isAdmin(data['role'])) {
          final createdAt = data['created_at'] as Timestamp?;
          if (createdAt != null) {
            final date = createdAt.toDate();
            final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            countByDay[dayKey] = (countByDay[dayKey] ?? 0) + 1;
          }
        }
      }
      
      // Convertir a ChartModel
      countByDay.forEach((key, count) {
        final parts = key.split('-');
        final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        stats.add(ChartModel(timestamp: date, count: count));
      });
      
      // Ordenar por fecha
      stats.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    
    return stats;
  }

  Future<List<ChartModel>> getPurchaseStats(int days) async {
    List<ChartModel> stats = [];
    DateTime lastWeek = DateTime.now().subtract(Duration(days: days));
    final QuerySnapshot snapshot = await firestore.collection('purchase_stats').where('timestamp', isGreaterThanOrEqualTo: lastWeek).get();
    stats = snapshot.docs.map((e) => ChartModel.fromFirestore(e)).toList();
    return stats;
  }

  Future<double> getCourseAverageRating(String courseId) async {
    double averageRating = 0.0;
    final CollectionReference collectionReference = firestore.collection('reviews');
    final QuerySnapshot snapshot = await collectionReference.where('course_id', isEqualTo: courseId).get();
    final List<Review> reviews = snapshot.docs.map((e) => Review.fromFirebase(e)).toList();

    if (reviews.isEmpty) {
      averageRating = 0.0;
    } else if (reviews.length <= 1) {
      averageRating = reviews.first.rating;
    } else {
      final int totalRatingCount = reviews.length;
      double totalRatingValue = 0;
      for (var element in reviews) {
        totalRatingValue = totalRatingValue + element.rating;
      }
      averageRating = totalRatingValue / totalRatingCount;
    }

    return averageRating;
  }

  Future saveCourseRating(String courseId, double rating) async {
    final CollectionReference collectionReference = firestore.collection('courses');
    await collectionReference.doc(courseId).update({'rating': rating});
  }

  Future<int> getLessonsCountInSection(String courseId, String sectionId) async {
    final CollectionReference collectionReference =
        firestore.collection('courses').doc(courseId).collection('sections').doc(sectionId).collection('lessons');
    AggregateQuerySnapshot snap = await collectionReference.count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getLessonsCountFromCourse(String courseId) async {
    final DocumentReference documentReference = firestore.collection('courses').doc(courseId);
    final DocumentSnapshot snapshot = await documentReference.get();
    final Course course = Course.fromFirestore(snapshot);
    final int count = course.lessonsCount;
    return count;
  }

  // ============= LEVELS =============
  Future<List<Level>> getLevels(String courseId) async {
    final QuerySnapshot snap = await firestore
        .collection('courses')
        .doc(courseId)
        .collection('levels')
        .orderBy('order')
        .get();
    
    return snap.docs.map((doc) => Level.fromFirestore(doc)).toList();
  }

  Future saveLevel(String courseId, Level level) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('levels')
        .doc(level.id)
        .set(Level.getMap(level));
  }

  Future deleteLevel(String courseId, String levelId) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('levels')
        .doc(levelId)
        .delete();
  }

  // ============= MODULES =============
  Future<List<Module>> getModules(String levelId, {String? courseId}) async {
    List<Module> data = [];
    
    if (courseId != null) {
      // Búsqueda específica por ruta
      await firestore
          .collection('courses')
          .doc(courseId)
          .collection('levels')
          .doc(levelId)
          .collection('modules')
          .orderBy('order')
          .get()
          .then((QuerySnapshot snapshot) {
        data = snapshot.docs.map((e) => Module.fromFirestore(e)).toList();
      });
    } else {
      // Búsqueda por collection group (backward compatibility)
      final QuerySnapshot snap = await firestore
          .collectionGroup('modules')
          .where('level_id', isEqualTo: levelId)
          .orderBy('order')
          .get();
      data = snap.docs.map((doc) => Module.fromFirestore(doc)).toList();
    }
    
    return data;
  }

  Future saveModule(String courseId, String levelId, Module module) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('levels')
        .doc(levelId)
        .collection('modules')
        .doc(module.id)
        .set(Module.getMap(module));
  }

  Future deleteModule(String courseId, String levelId, String moduleId) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('levels')
        .doc(levelId)
        .collection('modules')
        .doc(moduleId)
        .delete();
  }
}
