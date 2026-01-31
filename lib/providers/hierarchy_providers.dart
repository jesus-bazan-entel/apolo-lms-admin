import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/models/level.dart';
import 'package:lms_admin/models/module.dart';
import 'package:lms_admin/services/firebase_service.dart';

// Provider para obtener todos los niveles de un curso
final levelsProvider = FutureProvider.family<List<Level>, String>((ref, courseId) async {
  final levels = await FirebaseService().getLevels(courseId);
  return levels;
});

// Provider para obtener todos los módulos de un nivel
final modulesProvider = FutureProvider.family<List<Module>, Map<String, String>>((ref, params) async {
  final modules = await FirebaseService().getModules(
    params['levelId']!,
    courseId: params['courseId'],
  );
  return modules;
});

// Provider para estados de UI
final selectedLevelProvider = StateProvider<String?>((ref) => null);
final selectedModuleProvider = StateProvider<String?>((ref) => null);
