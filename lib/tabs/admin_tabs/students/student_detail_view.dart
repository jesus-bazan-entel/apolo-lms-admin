import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/constants.dart';
import 'package:lms_admin/models/user_model.dart';
import 'package:lms_admin/components/qr_dialog.dart';
import 'package:lms_admin/utils/toasts.dart';

class StudentDetailView extends ConsumerStatefulWidget {
  final UserModel student;

  const StudentDetailView({Key? key, required this.student}) : super(key: key);

  @override
  ConsumerState<StudentDetailView> createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends ConsumerState<StudentDetailView> {
  String? _selectedLevel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.student.studentLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentInfo(),
                    const SizedBox(height: 24),
                    _buildLevelSection(),
                    const SizedBox(height: 24),
                    _buildProgressSection(),
                    const SizedBox(height: 24),
                    _buildActionsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppConfig.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: widget.student.imageUrl != null
                ? NetworkImage(widget.student.imageUrl!)
                : null,
            child: widget.student.imageUrl == null
                ? Text(
                    widget.student.name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                Text(
                  widget.student.email,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo() {
    return _buildSection(
      title: 'Información General',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildInfoRow('ID', widget.student.id),
          _buildInfoRow('Registrado', _formatDate(widget.student.createdAt)),
          _buildInfoRow(
              'Plataforma', widget.student.platform ?? 'No especificada'),
          _buildInfoRow('Cursos inscritos',
              '${widget.student.enrolledCourses?.length ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildLevelSection() {
    return _buildSection(
      title: 'Nivel del Estudiante',
      icon: Icons.school_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLevel,
                isExpanded: true,
                hint: Text('Seleccionar nivel', style: GoogleFonts.poppins()),
                items: studentLevels.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value, style: GoogleFonts.poppins()),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedLevel = v),
              ),
            ),
          ),
          if (widget.student.studentSection != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Sección actual', widget.student.studentSection!),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final completedLessons = widget.student.completedLessons?.length ?? 0;

    return _buildSection(
      title: 'Progreso del Curso',
      icon: Icons.trending_up_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Lecciones Completadas',
                  completedLessons.toString(),
                  Icons.check_circle_outline,
                  AppConfig.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Cursos Inscritos',
                  '${widget.student.enrolledCourses?.length ?? 0}',
                  Icons.book_outlined,
                  AppConfig.infoColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return _buildSection(
      title: 'Acciones',
      icon: Icons.settings_outlined,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildActionButton(
            'Generar QR',
            Icons.qr_code,
            AppConfig.themeColor,
            _showQrCode,
          ),
          _buildActionButton(
            'Guardar Cambios',
            Icons.save_outlined,
            AppConfig.successColor,
            _saveChanges,
          ),
          _buildActionButton(
            widget.student.isDisbaled == true ? 'Habilitar' : 'Deshabilitar',
            widget.student.isDisbaled == true
                ? Icons.check_circle
                : Icons.block,
            widget.student.isDisbaled == true
                ? AppConfig.successColor
                : AppConfig.errorColor,
            _toggleAccess,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppConfig.themeColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showQrCode() {
    showDialog(
      context: context,
      builder: (context) => QrDialog(user: widget.student),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.student.id)
          .update({
        'student_level': _selectedLevel,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        openSuccessToast(context, 'Cambios guardados exitosamente');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        openFailureToast(context, 'Error al guardar: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAccess() async {
    setState(() => _isLoading = true);

    try {
      final newStatus = !(widget.student.isDisbaled ?? false);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.student.id)
          .update({
        'disabled': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        openSuccessToast(
          context,
          newStatus ? 'Usuario deshabilitado' : 'Usuario habilitado',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        openFailureToast(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
