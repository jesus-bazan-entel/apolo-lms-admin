import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/constants.dart';
import 'package:lms_admin/models/user_model.dart';
import 'package:lms_admin/components/qr_dialog.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/services/qr_generator_service.dart';
import 'package:lms_admin/utils/toasts.dart';

class StudentFormDialog extends ConsumerStatefulWidget {
  final UserModel? student;

  const StudentFormDialog({Key? key, this.student}) : super(key: key);

  @override
  ConsumerState<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends ConsumerState<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isNewStudent = true;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _usernameController;

  // Selecciones
  String? _selectedLevel;
  String? _selectedPaymentStatus;
  String? _selectedCourseId;
  String? _selectedModuleId;
  String? _selectedLessonId;
  bool _isDisabled = false;
  String? _qrCodeHash;

  // Cursos inscritos
  List<String> _enrolledCourses = [];

  // Datos de cursos
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _levels = [];
  List<Map<String, dynamic>> _modules = [];
  List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    _isNewStudent = widget.student == null;

    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();

    _selectedLevel = widget.student?.studentLevel;
    _selectedPaymentStatus = widget.student?.paymentStatus ?? 'pending';
    _isDisabled = widget.student?.disabled ?? false;
    _qrCodeHash = widget.student?.qrCodeHash;

    // Cargar cursos inscritos del estudiante
    if (widget.student?.enrolledCourses != null) {
      _enrolledCourses = widget.student!.enrolledCourses!.cast<String>();
    }

    _loadCourses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('status', isEqualTo: 'live')
        .get();

    setState(() {
      _courses = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'] ?? 'Sin nombre',
              })
          .toList();
    });

    // Si el estudiante tiene cursos inscritos, cargar el primero
    if (widget.student?.enrolledCourses?.isNotEmpty == true) {
      _selectedCourseId = widget.student!.enrolledCourses!.first.toString();
      await _loadLevels(_selectedCourseId!);
    }
  }

  Future<void> _loadLevels(String courseId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('levels')
        .orderBy('order')
        .get();

    setState(() {
      _levels = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'] ?? 'Sin nombre',
              })
          .toList();
      _modules = [];
      _lessons = [];
      _selectedModuleId = null;
      _selectedLessonId = null;
    });
  }

  Future<void> _loadModules(String courseId, String levelId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('levels')
        .doc(levelId)
        .collection('modules')
        .orderBy('order')
        .get();

    setState(() {
      _modules = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'] ?? 'Sin nombre',
              })
          .toList();
      _lessons = [];
      _selectedLessonId = null;
    });
  }

  Future<void> _loadLessons(
      String courseId, String levelId, String moduleId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('levels')
        .doc(levelId)
        .collection('modules')
        .doc(moduleId)
        .collection('lessons')
        .orderBy('order')
        .get();

    setState(() {
      _lessons = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'] ?? 'Sin nombre',
              })
          .toList();
    });
  }

  String _generatePassword() {
    // Usar el servicio centralizado para generar claves de acceso
    return QrGeneratorService.generateAccessKey();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonalInfoSection(),
                      const SizedBox(height: 24),
                      _buildPaymentSection(),
                      const SizedBox(height: 24),
                      _buildProgressSection(),
                      const SizedBox(height: 24),
                      _buildQRSection(),
                      const SizedBox(height: 24),
                      _buildActionsSection(),
                    ],
                  ),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isNewStudent ? Icons.person_add : Icons.edit,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isNewStudent ? 'Nuevo Estudiante' : 'Editar Estudiante',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                Text(
                  _isNewStudent
                      ? 'Complete los datos del nuevo estudiante'
                      : 'Modifique los datos del estudiante',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
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

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Información Personal',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Nombre Completo',
            hint: 'Ingrese el nombre del estudiante',
            icon: Icons.person,
            validator: (v) => v?.isEmpty == true ? 'Nombre requerido' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Correo Electrónico',
            hint: 'ejemplo@correo.com',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v?.isEmpty == true) return 'Correo requerido';
              if (!v!.contains('@')) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Nivel del Estudiante',
                  value: _selectedLevel,
                  items: studentLevels,
                  onChanged: (v) => setState(() => _selectedLevel = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSwitchTile(
                  label: 'Estado de la Cuenta',
                  value: !_isDisabled,
                  onChanged: (v) => setState(() => _isDisabled = !v),
                  activeLabel: 'Activo',
                  inactiveLabel: 'Inactivo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _buildSection(
      title: 'Estado de Pagos',
      icon: Icons.payment_outlined,
      child: Column(
        children: [
          _buildDropdown(
            label: 'Estado de Pago',
            value: _selectedPaymentStatus,
            items: paymentStatuses,
            onChanged: (v) => setState(() => _selectedPaymentStatus = v),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getPaymentStatusColor(_selectedPaymentStatus)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _getPaymentStatusColor(_selectedPaymentStatus)
                    .withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getPaymentStatusIcon(_selectedPaymentStatus),
                  color: _getPaymentStatusColor(_selectedPaymentStatus),
                ),
                const SizedBox(width: 12),
                Text(
                  _getPaymentStatusMessage(_selectedPaymentStatus),
                  style: GoogleFonts.poppins(
                    color: _getPaymentStatusColor(_selectedPaymentStatus),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return _buildSection(
      title: 'Matriculación en Cursos',
      icon: Icons.school_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información sobre matriculación
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConfig.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppConfig.infoColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppConfig.infoColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Seleccione los cursos a los que el estudiante tendrá acceso.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppConfig.infoColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lista de cursos disponibles
          Text(
            'Cursos Disponibles (${_enrolledCourses.length} inscritos)',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),

          if (_courses.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Text(
                    'Cargando cursos...',
                    style: GoogleFonts.poppins(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _courses.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  final courseId = course['id'] as String;
                  final courseName = course['name'] as String;
                  final isEnrolled = _enrolledCourses.contains(courseId);

                  return CheckboxListTile(
                    value: isEnrolled,
                    title: Text(
                      courseName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isEnrolled ? FontWeight.w600 : FontWeight.normal,
                        color: isEnrolled ? AppConfig.themeColor : Colors.grey.shade800,
                      ),
                    ),
                    subtitle: isEnrolled
                        ? Text(
                            'Inscrito',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppConfig.successColor,
                            ),
                          )
                        : null,
                    secondary: Icon(
                      isEnrolled ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isEnrolled ? AppConfig.successColor : Colors.grey.shade400,
                    ),
                    activeColor: AppConfig.themeColor,
                    dense: true,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (!_enrolledCourses.contains(courseId)) {
                            _enrolledCourses.add(courseId);
                          }
                        } else {
                          _enrolledCourses.remove(courseId);
                        }
                      });
                    },
                  );
                },
              ),
            ),

          // Botones de acción rápida
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _enrolledCourses = _courses.map((c) => c['id'] as String).toList();
                  });
                },
                icon: const Icon(Icons.select_all, size: 18),
                label: const Text('Seleccionar todos'),
                style: TextButton.styleFrom(
                  foregroundColor: AppConfig.themeColor,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _enrolledCourses.clear();
                  });
                },
                icon: const Icon(Icons.deselect, size: 18),
                label: const Text('Deseleccionar todos'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection() {
    final hasAccessCode = _qrCodeHash != null && _qrCodeHash!.isNotEmpty;

    return _buildSection(
      title: 'Código de Acceso',
      icon: Icons.qr_code,
      child: Column(
        children: [
          _buildTextField(
            controller: _usernameController,
            label: 'Nombre de Usuario (opcional)',
            hint: 'Usuario para inicio de sesión',
            icon: Icons.account_circle,
          ),
          const SizedBox(height: 16),
          if (hasAccessCode) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConfig.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppConfig.successColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppConfig.successColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clave de Acceso Generada',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppConfig.successColor,
                          ),
                        ),
                        SelectableText(
                          'Clave: $_qrCodeHash',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showQRDialog(),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver'),
                  ),
                ],
              ),
            ),
          ] else if (!hasAccessCode) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_2, color: Colors.grey.shade400, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Genere una clave de acceso para el estudiante (se mostrará como QR)',
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  final newPassword = _generatePassword();
                  _qrCodeHash = newPassword;
                  _passwordController.text = newPassword;
                });
                openSuccessToast(context, 'Clave de acceso generada');
              },
              icon: const Icon(Icons.auto_awesome),
              label: Text(hasAccessCode ? 'Regenerar Clave' : 'Generar Clave'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveStudent,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            label: Text(_isNewStudent ? 'Crear Estudiante' : 'Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.themeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConfig.themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppConfig.themeColor),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppConfig.themeColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required Map<String, String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.containsKey(value) ? value : null,
              isExpanded: true,
              hint: Text('Seleccionar...',
                  style: GoogleFonts.poppins(color: Colors.grey.shade400)),
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey.shade800),
              items: items.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required String activeLabel,
    required String inactiveLabel,
  }) {
    return Column(
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value ? activeLabel : inactiveLabel,
                style: GoogleFonts.poppins(
                  color: value ? AppConfig.successColor : AppConfig.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppConfig.successColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPaymentStatusColor(String? status) {
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

  IconData _getPaymentStatusIcon(String? status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'overdue':
        return Icons.warning;
      case 'free':
        return Icons.card_giftcard;
      default:
        return Icons.help;
    }
  }

  String _getPaymentStatusMessage(String? status) {
    switch (status) {
      case 'paid':
        return 'Estudiante al día con sus pagos';
      case 'pending':
        return 'Pago pendiente de verificación';
      case 'overdue':
        return 'Estudiante con pagos vencidos';
      case 'free':
        return 'Estudiante con acceso gratuito';
      default:
        return 'Estado de pago no definido';
    }
  }

  void _showQRDialog() {
    if (_qrCodeHash == null || _qrCodeHash!.isEmpty) {
      openFailureToast(context, 'Primero debe generar una clave de acceso');
      return;
    }

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

              // Student name if available
              if (_nameController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _nameController.text,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),

              // QR Code Image
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                ),
                child: QrImageView(
                  data: _qrCodeHash!,
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
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _qrCodeHash!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copiar clave',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _qrCodeHash!));
                        openSuccessToast(context, 'Clave copiada al portapapeles');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Escanea este código para iniciar sesión',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
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

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final name = _nameController.text.trim();

      final data = {
        'name': name,
        'email': email,
        'student_level': _selectedLevel,
        'payment_status': _selectedPaymentStatus,
        'disabled': _isDisabled,
        'qr_code_hash': _qrCodeHash,
        'updated_at': FieldValue.serverTimestamp(),
        'enrolled_courses': _enrolledCourses, // Lista de cursos inscritos
      };

      if (_isNewStudent) {
        // Verificar si ya existe un usuario con el mismo email
        final existingUsers = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (existingUsers.docs.isNotEmpty) {
          if (mounted) {
            openFailureToast(context, 'Ya existe un estudiante con este correo electrónico');
          }
          return;
        }

        // Crear nuevo estudiante en Firestore
        // Nota: La cuenta de Firebase Auth se crea automáticamente cuando
        // el estudiante escanea el QR por primera vez en la app móvil
        final docId = FirebaseService.getUID('users');

        data['created_at'] = FieldValue.serverTimestamp();
        data['role'] = ['student'];
        // Bandera para indicar que la cuenta de Auth no ha sido creada
        data['auth_pending'] = true;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .set(data);

        // Actualizar contadores de estudiantes en los cursos
        await _updateCourseStudentCounts([], _enrolledCourses);

        // Crear documento en qr_auth para permitir login sin autenticación previa
        if (_qrCodeHash != null && _qrCodeHash!.isNotEmpty) {
          await _createQrAuthDocument(
            qrHash: _qrCodeHash!,
            email: email,
            name: name,
            userId: docId,
            disabled: _isDisabled,
          );
        }

        // Registrar en estadísticas de usuarios
        await _updateUserStats();

        if (mounted) {
          openSuccessToast(context, 'Estudiante creado exitosamente');
          Navigator.pop(context, true);
        }
      } else {
        // Actualizar estudiante existente
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.student!.id)
            .update(data);

        // Actualizar contadores de estudiantes en los cursos
        final previousEnrolled = widget.student?.enrolledCourses?.cast<String>() ?? [];
        await _updateCourseStudentCounts(previousEnrolled, _enrolledCourses);

        // Actualizar documento en qr_auth si hay código QR
        if (_qrCodeHash != null && _qrCodeHash!.isNotEmpty) {
          await _createQrAuthDocument(
            qrHash: _qrCodeHash!,
            email: email,
            name: name,
            userId: widget.student!.id,
            disabled: _isDisabled,
          );

          // Si el código QR cambió, eliminar el documento anterior
          if (widget.student!.qrCodeHash != null &&
              widget.student!.qrCodeHash != _qrCodeHash) {
            await FirebaseFirestore.instance
                .collection('qr_auth')
                .doc(widget.student!.qrCodeHash)
                .delete();
          }
        }

        if (mounted) {
          openSuccessToast(context, 'Estudiante actualizado exitosamente');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        openFailureToast(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Crea o actualiza el documento en la colección qr_auth
  /// Esta colección tiene lectura pública para permitir login con QR sin autenticación previa
  Future<void> _createQrAuthDocument({
    required String qrHash,
    required String email,
    required String name,
    required String userId,
    required bool disabled,
  }) async {
    await FirebaseFirestore.instance.collection('qr_auth').doc(qrHash).set({
      'email': email,
      'name': name,
      'user_id': userId,
      'disabled': disabled,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Actualiza los contadores de estudiantes en los cursos
  /// Incrementa para cursos nuevos y decrementa para cursos removidos
  Future<void> _updateCourseStudentCounts(
    List<String> previousEnrolled,
    List<String> newEnrolled,
  ) async {
    // Cursos que se agregaron (incrementar contador)
    final addedCourses = newEnrolled.where((c) => !previousEnrolled.contains(c)).toList();
    // Cursos que se removieron (decrementar contador)
    final removedCourses = previousEnrolled.where((c) => !newEnrolled.contains(c)).toList();

    // Incrementar contador para cursos nuevos
    for (final courseId in addedCourses) {
      try {
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .update({
          'students': FieldValue.increment(1),
        });
      } catch (e) {
        debugPrint('Error incrementing student count for course $courseId: $e');
      }
    }

    // Decrementar contador para cursos removidos
    for (final courseId in removedCourses) {
      try {
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .update({
          'students': FieldValue.increment(-1),
        });
      } catch (e) {
        debugPrint('Error decrementing student count for course $courseId: $e');
      }
    }
  }

  Future<void> _updateUserStats() async {
    // Obtener la fecha de hoy sin hora
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final docId = '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';

    final docRef = FirebaseFirestore.instance.collection('user_stats').doc(docId);
    final doc = await docRef.get();

    if (doc.exists) {
      // Incrementar el contador existente
      await docRef.update({
        'count': FieldValue.increment(1),
      });
    } else {
      // Crear nuevo registro para hoy
      await docRef.set({
        'timestamp': Timestamp.fromDate(dateOnly),
        'count': 1,
      });
    }
  }
}
