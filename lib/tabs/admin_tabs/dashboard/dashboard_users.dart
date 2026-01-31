import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/components/side_menu.dart';
import 'package:lms_admin/mixins/user_mixin.dart';
import 'package:lms_admin/models/user_model.dart';
import '../../../pages/home.dart';

/// Provider para los últimos usuarios (estudiantes) en tiempo real
/// Excluye administradores y autores
final dashboardUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('created_at', descending: true)
      .limit(10) // Traer más para filtrar después
      .snapshots()
      .map((snapshot) {
    final users = snapshot.docs
        .map((doc) => UserModel.fromFirebase(doc))
        .where((user) {
      // Excluir si tiene rol admin o author
      if (user.role == null || user.role!.isEmpty) return true;
      final hasAdminRole = user.role!.any((r) =>
          r.toString().toLowerCase() == 'admin' ||
          r.toString().toLowerCase() == 'author');
      return !hasAdminRole;
    }).toList();

    // Retornar máximo 5 usuarios
    return users.take(5).toList();
  });
});

class DashboardUsers extends ConsumerWidget {
  const DashboardUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(dashboardUsersProvider);
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.shade300,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Users',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  ref.read(menuIndexProvider.notifier).update((state) => 1);
                  ref.read(pageControllerProvider.notifier).state.jumpToPage(1);
                },
                child: const Text('View All'),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: users.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No hay estudiantes registrados',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return Column(
                  children: data.map((user) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      leading: UserMixin.getUserImageByUrl(imageUrl: user.imageUrl),
                      title: Text(user.name),
                      subtitle: Text('Enrolled Courses: ${user.enrolledCourses?.length ?? 0}'),
                    );
                  }).toList(),
                );
              },
              error: (a, b) => Center(
                child: Text('Error: $a', style: const TextStyle(color: Colors.red)),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
