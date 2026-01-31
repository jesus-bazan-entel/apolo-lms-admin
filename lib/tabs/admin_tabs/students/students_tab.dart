import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/constants.dart';
import 'package:lms_admin/mixins/appbar_mixin.dart';
import 'package:lms_admin/models/user_model.dart';
import 'package:lms_admin/services/qr_generator_service.dart';
import 'package:lms_admin/tabs/admin_tabs/students/student_detail_view.dart';
import 'package:lms_admin/tabs/admin_tabs/students/student_form_dialog.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/utils/toasts.dart';

class StudentsTab extends ConsumerStatefulWidget {
  const StudentsTab({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends ConsumerState<StudentsTab> {
  String _selectedLevel = 'all';
  String _selectedStatus = 'all';
  String _selectedPayment = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Limpiar duplicados automáticamente al cargar
    _autoCleanDuplicates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Limpia automáticamente estudiantes duplicados (mismo email)
  /// Mantiene el registro más reciente
  Future<void> _autoCleanDuplicates() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();

      // Agrupar por email (solo estudiantes, no admins/authors)
      final Map<String, List<QueryDocumentSnapshot>> emailGroups = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final email = data['email']?.toString().toLowerCase() ?? '';
        if (email.isEmpty) continue;

        // Excluir admins y autores
        final role = data['role'];
        if (role != null && role is List) {
          final hasAdminRole = role.any((r) =>
              r.toString().toLowerCase() == 'admin' ||
              r.toString().toLowerCase() == 'author');
          if (hasAdminRole) continue;
        }

        emailGroups.putIfAbsent(email, () => []).add(doc);
      }

      // Eliminar duplicados (mantener el más reciente)
      for (final entry in emailGroups.entries) {
        if (entry.value.length > 1) {
          // Ordenar por fecha de creación (más reciente primero)
          entry.value.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>?;
            final bData = b.data() as Map<String, dynamic>?;
            final aCreated = aData?['created_at'];
            final bCreated = bData?['created_at'];
            if (aCreated == null && bCreated == null) return 0;
            if (aCreated == null) return 1;
            if (bCreated == null) return -1;
            return (bCreated as Timestamp).compareTo(aCreated as Timestamp);
          });

          // Eliminar todos excepto el más reciente
          for (int i = 1; i < entry.value.length; i++) {
            await entry.value[i].reference.delete();
            debugPrint('Duplicado eliminado: ${entry.key}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error limpiando duplicados: $e');
    }
  }

  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('users');

    if (_selectedLevel != 'all') {
      query = query.where('student_level', isEqualTo: _selectedLevel);
    }

    if (_selectedStatus != 'all') {
      query = query.where('disabled', isEqualTo: _selectedStatus == 'inactive');
    }

    if (_selectedPayment != 'all') {
      query = query.where('payment_status', isEqualTo: _selectedPayment);
    }

    return query.orderBy('created_at', descending: true);
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => const StudentFormDialog(),
    ).then((result) {
      if (result == true) {
        setState(() {}); // Refresh list
      }
    });
  }

  void _showEditStudentDialog(UserModel student) {
    showDialog(
      context: context,
      builder: (context) => StudentFormDialog(student: student),
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
            title: 'Gestión de Estudiantes',
            buttons: [
              CustomButtons.customOutlineButton(
                context,
                icon: Icons.file_download_outlined,
                text: 'Exportar',
                bgColor: Colors.white,
                foregroundColor: AppConfig.themeColor,
                onPressed: () => _exportStudents(),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showAddStudentDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Agregar Estudiante'),
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

          // Filtros
          _buildFiltersSection(),

          // Lista de Estudiantes
          Expanded(
            child: _buildStudentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Barra de búsqueda
          Container(
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
                hintText: 'Buscar estudiante por nombre o email...',
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

          const SizedBox(height: 16),

          // Filtros en fila
          Row(
            children: [
              Expanded(
                  child: _buildFilterDropdown(
                label: 'Nivel',
                description: 'Filtrar estudiantes por nivel de conocimiento',
                value: _selectedLevel,
                items: {'all': 'Todos', ...studentLevels},
                onChanged: (v) => setState(() => _selectedLevel = v!),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildFilterDropdown(
                label: 'Estado',
                description: 'Filtrar por estado de cuenta (activo/inactivo)',
                value: _selectedStatus,
                items: {
                  'all': 'Todos',
                  'active': 'Activos',
                  'inactive': 'Inactivos'
                },
                onChanged: (v) => setState(() => _selectedStatus = v!),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildFilterDropdown(
                label: 'Estado de Pago',
                description: 'Filtrar por estado de pago de suscripciones',
                value: _selectedPayment,
                items: {'all': 'Todos', ...paymentStatuses},
                onChanged: (v) => setState(() => _selectedPayment = v!),
              )),
              const SizedBox(width: 12),
              _buildResetButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required Function(String?) onChanged,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(label, style: GoogleFonts.poppins(fontSize: 14)),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade800),
              items: items.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return TextButton.icon(
      onPressed: () {
        setState(() {
          _selectedLevel = 'all';
          _selectedStatus = 'all';
          _selectedPayment = 'all';
          _searchQuery = '';
          _searchController.clear();
        });
      },
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text('Limpiar'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildStudentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        List<UserModel> students = snapshot.data!.docs
            .map((doc) => UserModel.fromFirebase(doc))
            .toList();

        // Excluir administradores y autores (solo mostrar estudiantes)
        students = students.where((s) {
          if (s.role == null || s.role!.isEmpty) return true; // Sin rol = estudiante
          // Excluir si tiene rol admin o author
          final hasAdminRole = s.role!.any((r) =>
              r.toString().toLowerCase() == 'admin' ||
              r.toString().toLowerCase() == 'author');
          return !hasAdminRole;
        }).toList();

        // Filtro de búsqueda local
        if (_searchQuery.isNotEmpty) {
          students = students
              .where((s) =>
                  s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  s.email.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: students.length,
          itemBuilder: (context, index) {
            return _StudentCard(
              student: students[index],
              onTap: () => _showStudentDetail(students[index]),
              onEdit: () => _showEditStudentDialog(students[index]),
              onShowQR: () => _showStudentQR(students[index]),
              onToggleStatus: () => _toggleStudentStatus(students[index]),
              onDelete: () => _showDeleteConfirmation(students[index]),
            );
          },
        );
      },
    );
  }

  Future<void> _ensureQrAuthSync(UserModel student) async {
    if (student.qrCodeHash == null || student.qrCodeHash!.isEmpty) return;

    try {
      // Verificar si ya existe el documento en qr_auth
      final qrAuthDoc = await FirebaseFirestore.instance
          .collection('qr_auth')
          .doc(student.qrCodeHash)
          .get();

      // Si no existe o los datos están desactualizados, crear/actualizar
      if (!qrAuthDoc.exists) {
        await FirebaseFirestore.instance
            .collection('qr_auth')
            .doc(student.qrCodeHash)
            .set({
          'email': student.email,
          'name': student.name,
          'user_id': student.id,
          'disabled': student.disabled ?? false,
          'updated_at': FieldValue.serverTimestamp(),
        });
        debugPrint('QR auth document created for ${student.name}');
      } else {
        // Verificar si el email o disabled cambió
        final data = qrAuthDoc.data();
        if (data != null &&
            (data['email'] != student.email ||
             data['disabled'] != (student.disabled ?? false) ||
             data['name'] != student.name)) {
          await FirebaseFirestore.instance
              .collection('qr_auth')
              .doc(student.qrCodeHash)
              .update({
            'email': student.email,
            'name': student.name,
            'disabled': student.disabled ?? false,
            'updated_at': FieldValue.serverTimestamp(),
          });
          debugPrint('QR auth document updated for ${student.name}');
        }
      }
    } catch (e) {
      debugPrint('Error syncing QR auth: $e');
    }
  }

  void _showStudentQR(UserModel student) async {
    if (student.qrCodeHash == null || student.qrCodeHash!.isEmpty) {
      openFailureToast(context, 'Este estudiante no tiene un código QR generado');
      return;
    }

    // Asegurar que el QR esté sincronizado con qr_auth
    await _ensureQrAuthSync(student);

    // Generar el contenido del QR con el nuevo formato JSON
    final String qrContent = QrGeneratorService.generateQrContent(
      student.email,
      student.qrCodeHash!,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppConfig.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Código QR de Acceso',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Student name
              Text(
                student.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                student.email,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // QR Code Image con el nuevo formato
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrContent,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Access code display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clave de acceso:',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                student.qrCodeHash!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'Copiar clave',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: student.qrCodeHash!));
                            openSuccessToast(context, 'Clave copiada al portapapeles');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Información del QR
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConfig.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppConfig.successColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppConfig.successColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Este QR permite inicio de sesión automático desde la app IDECAP',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppConfig.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Cerrar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementar impresión
                        openSuccessToast(context, 'Función de impresión próximamente');
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Imprimir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No se encontraron estudiantes',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetail(UserModel student) {
    showDialog(
      context: context,
      builder: (context) => StudentDetailView(student: student),
    );
  }

  void _exportStudents() {
    openSuccessToast(context, 'Exportación iniciada...');
    // TODO: Implementar exportación a CSV/Excel
  }

  Future<void> _toggleStudentStatus(UserModel student) async {
    final newStatus = !(student.disabled == true);
    final statusText = newStatus ? 'deshabilitado' : 'habilitado';

    try {
      // Actualizar el documento del usuario
      await FirebaseFirestore.instance
          .collection('users')
          .doc(student.id)
          .update({'disabled': newStatus});

      // También actualizar el documento en qr_auth si existe
      if (student.qrCodeHash != null && student.qrCodeHash!.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('qr_auth')
              .doc(student.qrCodeHash)
              .update({
            'disabled': newStatus,
            'updated_at': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          // Si el documento no existe, crearlo
          await FirebaseFirestore.instance
              .collection('qr_auth')
              .doc(student.qrCodeHash)
              .set({
            'email': student.email,
            'name': student.name,
            'user_id': student.id,
            'disabled': newStatus,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }

      if (mounted) {
        openSuccessToast(context, 'Estudiante $statusText correctamente');
        setState(() {}); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        openFailureToast(context, 'Error al cambiar estado: $e');
      }
    }
  }

  void _showDeleteConfirmation(UserModel student) {
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
              'Eliminar Estudiante',
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
              '¿Estás seguro de que deseas eliminar a este estudiante?',
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
                    backgroundImage: student.imageUrl != null
                        ? NetworkImage(student.imageUrl!)
                        : null,
                    child: student.imageUrl == null
                        ? Text(
                            student.name[0].toUpperCase(),
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
                          student.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          student.email,
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
                      'Esta acción no se puede deshacer. Se eliminará el estudiante de forma permanente.',
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
              _deleteStudent(student);
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

  Future<void> _deleteStudent(UserModel student) async {
    try {
      // Eliminar el documento del estudiante
      await FirebaseFirestore.instance
          .collection('users')
          .doc(student.id)
          .delete();

      // También eliminar el código QR asociado si existe
      if (student.qrCodeHash != null && student.qrCodeHash!.isNotEmpty) {
        try {
          final qrDocs = await FirebaseFirestore.instance
              .collection('qr_auth')
              .where('email', isEqualTo: student.email)
              .get();

          for (var doc in qrDocs.docs) {
            await doc.reference.delete();
          }
        } catch (e) {
          // Ignorar errores al eliminar QR, el estudiante ya fue eliminado
        }
      }

      if (mounted) {
        openSuccessToast(context, 'Estudiante eliminado correctamente');
        setState(() {}); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        openFailureToast(context, 'Error al eliminar estudiante: $e');
      }
    }
  }
}

class _StudentCard extends StatelessWidget {
  final UserModel student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onShowQR;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _StudentCard({
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onShowQR,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppConfig.themeColor.withOpacity(0.1),
                  backgroundImage: student.imageUrl != null
                      ? NetworkImage(student.imageUrl!)
                      : null,
                  child: student.imageUrl == null
                      ? Text(
                          student.name[0].toUpperCase(),
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
                        student.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.email,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tags
                Row(
                  children: [
                    _buildTag(
                      studentLevels[student.studentLevel] ?? 'Sin nivel',
                      _getLevelColor(student.studentLevel),
                    ),
                    const SizedBox(width: 8),
                    _buildTag(
                      paymentStatuses[student.paymentStatus] ?? 'Pendiente',
                      _getPaymentColor(student.paymentStatus),
                    ),
                    const SizedBox(width: 8),
                    _buildTag(
                      student.disabled == true ? 'Inactivo' : 'Activo',
                      student.disabled == true
                          ? AppConfig.errorColor
                          : AppConfig.successColor,
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // QR button
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  color: student.qrCodeHash != null 
                      ? AppConfig.successColor 
                      : Colors.grey.shade400,
                  tooltip: student.qrCodeHash != null 
                      ? 'Ver QR de acceso' 
                      : 'Sin QR generado',
                  onPressed: student.qrCodeHash != null ? onShowQR : null,
                ),

                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: AppConfig.themeColor,
                  tooltip: 'Editar estudiante',
                  onPressed: onEdit,
                ),

                // Toggle status button
                IconButton(
                  icon: Icon(
                    student.disabled == true
                        ? Icons.toggle_off_outlined
                        : Icons.toggle_on,
                  ),
                  color: student.disabled == true
                      ? Colors.grey.shade400
                      : AppConfig.successColor,
                  tooltip: student.disabled == true
                      ? 'Habilitar estudiante'
                      : 'Deshabilitar estudiante',
                  onPressed: onToggleStatus,
                ),

                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppConfig.errorColor,
                  tooltip: 'Eliminar estudiante',
                  onPressed: onDelete,
                ),

                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getLevelColor(String? level) {
    switch (level) {
      case 'basic':
        return AppConfig.infoColor;
      case 'intermediate':
        return AppConfig.warningColor;
      case 'advanced':
        return AppConfig.successColor;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentColor(String? status) {
    switch (status) {
      case 'paid':
        return AppConfig.successColor;
      case 'pending':
        return AppConfig.warningColor;
      case 'overdue':
        return AppConfig.errorColor;
      case 'free':
        return AppConfig.infoColor;
      default:
        return Colors.grey;
    }
  }
}
