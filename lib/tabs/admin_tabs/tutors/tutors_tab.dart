import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/mixins/appbar_mixin.dart';
import 'package:lms_admin/models/user_model.dart';
import 'package:lms_admin/tabs/admin_tabs/tutors/tutor_form_dialog.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/utils/toasts.dart';

/// Pestaña de gestión de tutores
/// Permite crear, editar, ver y eliminar tutores del sistema
class TutorsTab extends ConsumerStatefulWidget {
  const TutorsTab({super.key});

  @override
  ConsumerState<TutorsTab> createState() => _TutorsTabState();
}

class _TutorsTabState extends ConsumerState<TutorsTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Query<Map<String, dynamic>> _buildQuery() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', arrayContains: 'tutor')
        .orderBy('created_at', descending: true);
  }

  void _showAddTutorDialog() {
    showDialog(
      context: context,
      builder: (context) => const TutorFormDialog(),
    ).then((result) {
      if (result == true) {
        setState(() {}); // Refresh list
      }
    });
  }

  void _showEditTutorDialog(UserModel tutor) {
    showDialog(
      context: context,
      builder: (context) => TutorFormDialog(tutor: tutor),
    ).then((result) {
      if (result == true) {
        setState(() {}); // Refresh list
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConfig.scffoldBgColor,
      child: Column(
        children: [
          AppBarMixin.buildTitleBar(
            context,
            title: 'Gestión de Tutores',
            buttons: [
              CustomButtons.customOutlineButton(
                context,
                icon: Icons.file_download_outlined,
                text: 'Exportar',
                bgColor: Colors.white,
                foregroundColor: AppConfig.themeColor,
                onPressed: () => _exportTutors(),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showAddTutorDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Agregar Tutor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          // Barra de búsqueda
          _buildSearchBar(),

          // Lista de Tutores
          Expanded(
            child: _buildTutorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Buscar tutor por nombre o email...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        List<UserModel> tutors = snapshot.data!.docs
            .map((doc) => UserModel.fromFirebase(doc))
            .toList();

        // Filtro de búsqueda local
        if (_searchQuery.isNotEmpty) {
          tutors = tutors
              .where((t) =>
                  t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  t.email.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: tutors.length,
          itemBuilder: (context, index) {
            return _TutorCard(
              tutor: tutors[index],
              onEdit: () => _showEditTutorDialog(tutors[index]),
              onAssignCourses: () => _showAssignCoursesDialog(tutors[index]),
              onToggleStatus: () => _toggleTutorStatus(tutors[index]),
              onDelete: () => _showDeleteConfirmation(tutors[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No hay tutores registrados',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega un nuevo tutor para comenzar',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _exportTutors() {
    openSuccessToast(context, 'Exportación iniciada...');
    // TODO: Implementar exportación a CSV/Excel
  }

  void _showAssignCoursesDialog(UserModel tutor) {
    showDialog(
      context: context,
      builder: (context) => _AssignCoursesDialog(tutor: tutor),
    ).then((result) {
      if (result == true) {
        setState(() {}); // Refresh list
      }
    });
  }

  Future<void> _toggleTutorStatus(UserModel tutor) async {
    final newStatus = !(tutor.disabled == true);
    final statusText = newStatus ? 'deshabilitado' : 'habilitado';

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(tutor.id)
          .update({'disabled': newStatus});

      if (mounted) {
        openSuccessToast(context, 'Tutor $statusText correctamente');
        setState(() {}); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        openFailureToast(context, 'Error al cambiar estado: $e');
      }
    }
  }

  void _showDeleteConfirmation(UserModel tutor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConfig.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppConfig.errorColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Eliminar Tutor',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar a este tutor?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppConfig.themeColor.withOpacity(0.1),
                    backgroundImage: tutor.imageUrl != null
                        ? NetworkImage(tutor.imageUrl!)
                        : null,
                    child: tutor.imageUrl == null
                        ? Text(
                            tutor.name[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: AppConfig.themeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tutor.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          tutor.email,
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConfig.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppConfig.errorColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppConfig.errorColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Esta acción eliminará el rol de tutor. Los cursos asignados serán desvinculados.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppConfig.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _deleteTutor(tutor);
            },
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTutor(UserModel tutor) async {
    try {
      // Remove tutor role instead of deleting the user
      final currentRoles = List<String>.from(tutor.role ?? []);
      currentRoles.remove('tutor');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(tutor.id)
          .update({
        'role': currentRoles,
        'assigned_courses': [],
        'tutor_permissions': null,
      });

      // Remove tutor from all courses
      final coursesWithTutor = await FirebaseFirestore.instance
          .collection('courses')
          .where('tutor_ids', arrayContains: tutor.id)
          .get();

      for (var doc in coursesWithTutor.docs) {
        final tutorIds = List<String>.from(doc.data()['tutor_ids'] ?? []);
        tutorIds.remove(tutor.id);

        final tutors = List<Map<String, dynamic>>.from(doc.data()['tutors'] ?? []);
        tutors.removeWhere((t) => t['id'] == tutor.id);

        await doc.reference.update({
          'tutor_ids': tutorIds,
          'tutors': tutors,
        });
      }

      if (mounted) {
        openSuccessToast(context, 'Rol de tutor eliminado correctamente');
        setState(() {}); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        openFailureToast(context, 'Error al eliminar tutor: $e');
      }
    }
  }
}

class _TutorCard extends StatelessWidget {
  final UserModel tutor;
  final VoidCallback onEdit;
  final VoidCallback onAssignCourses;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _TutorCard({
    required this.tutor,
    required this.onEdit,
    required this.onAssignCourses,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final assignedCount = tutor.assignedCourses?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppConfig.themeColor.withOpacity(0.1),
              backgroundImage: tutor.imageUrl != null
                  ? NetworkImage(tutor.imageUrl!)
                  : null,
              child: tutor.imageUrl == null
                  ? Text(
                      tutor.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: AppConfig.themeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tutor.email,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Cursos asignados
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConfig.themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 16,
                    color: AppConfig.themeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$assignedCount cursos',
                    style: GoogleFonts.poppins(
                      color: AppConfig.themeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (tutor.disabled == true
                        ? AppConfig.errorColor
                        : AppConfig.successColor)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tutor.disabled == true ? 'Inactivo' : 'Activo',
                style: GoogleFonts.poppins(
                  color: tutor.disabled == true
                      ? AppConfig.errorColor
                      : AppConfig.successColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Acciones
            IconButton(
              icon: const Icon(Icons.library_books_outlined),
              color: Colors.blue,
              tooltip: 'Asignar cursos',
              onPressed: onAssignCourses,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppConfig.themeColor,
              tooltip: 'Editar tutor',
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                tutor.disabled == true
                    ? Icons.toggle_off_outlined
                    : Icons.toggle_on,
              ),
              color: tutor.disabled == true
                  ? Colors.grey.shade400
                  : AppConfig.successColor,
              tooltip: tutor.disabled == true
                  ? 'Habilitar tutor'
                  : 'Deshabilitar tutor',
              onPressed: onToggleStatus,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppConfig.errorColor,
              tooltip: 'Eliminar tutor',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo para asignar cursos a un tutor
class _AssignCoursesDialog extends StatefulWidget {
  final UserModel tutor;

  const _AssignCoursesDialog({required this.tutor});

  @override
  State<_AssignCoursesDialog> createState() => _AssignCoursesDialogState();
}

class _AssignCoursesDialogState extends State<_AssignCoursesDialog> {
  List<String> _selectedCourses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCourses = List<String>.from(widget.tutor.assignedCourses ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppConfig.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.library_books,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asignar Cursos',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.tutor.name,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Lista de cursos
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .where('status', isEqualTo: 'live')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final courses = snapshot.data!.docs;

                  if (courses.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay cursos disponibles',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final courseData = course.data() as Map<String, dynamic>;
                      final isSelected = _selectedCourses.contains(course.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedCourses.add(course.id);
                            } else {
                              _selectedCourses.remove(course.id);
                            }
                          });
                        },
                        title: Text(
                          courseData['name'] ?? 'Sin nombre',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${courseData['students'] ?? 0} estudiantes',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        secondary: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            courseData['image_url'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.book, color: Colors.grey),
                            ),
                          ),
                        ),
                        activeColor: AppConfig.themeColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCourseAssignment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Guardar (${_selectedCourses.length})',
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCourseAssignment() async {
    setState(() => _isLoading = true);

    try {
      // Update tutor's assigned courses
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.tutor.id)
          .update({
        'assigned_courses': _selectedCourses,
      });

      // Update courses to include this tutor
      final allCourses = await FirebaseFirestore.instance
          .collection('courses')
          .get();

      for (var course in allCourses.docs) {
        final courseData = course.data();
        final currentTutorIds = List<String>.from(courseData['tutor_ids'] ?? []);
        final currentTutors = List<Map<String, dynamic>>.from(courseData['tutors'] ?? []);

        if (_selectedCourses.contains(course.id)) {
          // Add tutor to course if not already present
          if (!currentTutorIds.contains(widget.tutor.id)) {
            currentTutorIds.add(widget.tutor.id);
            currentTutors.add({
              'id': widget.tutor.id,
              'name': widget.tutor.name,
              'image_url': widget.tutor.imageUrl,
            });

            await course.reference.update({
              'tutor_ids': currentTutorIds,
              'tutors': currentTutors,
            });
          }
        } else {
          // Remove tutor from course if present
          if (currentTutorIds.contains(widget.tutor.id)) {
            currentTutorIds.remove(widget.tutor.id);
            currentTutors.removeWhere((t) => t['id'] == widget.tutor.id);

            await course.reference.update({
              'tutor_ids': currentTutorIds,
              'tutors': currentTutors,
            });
          }
        }
      }

      if (mounted) {
        openSuccessToast(context, 'Cursos asignados correctamente');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        openFailureToast(context, 'Error al asignar cursos: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
