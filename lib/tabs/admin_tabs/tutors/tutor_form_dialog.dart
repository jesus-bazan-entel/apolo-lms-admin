import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/models/user_model.dart';
import 'package:lms_admin/utils/toasts.dart';

/// Diálogo para crear o editar un tutor
class TutorFormDialog extends ConsumerStatefulWidget {
  final UserModel? tutor;

  const TutorFormDialog({super.key, this.tutor});

  @override
  ConsumerState<TutorFormDialog> createState() => _TutorFormDialogState();
}

class _TutorFormDialogState extends ConsumerState<TutorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  bool _obscurePassword = true;

  // Permisos del tutor
  bool _canCreateLessons = true;
  bool _canUploadVideos = true;
  bool _canUploadPdfs = true;
  bool _canCreateQuizzes = true;
  bool _canEditCourse = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.tutor != null;

    if (_isEditing) {
      _nameController.text = widget.tutor!.name;
      _emailController.text = widget.tutor!.email;

      // Load permissions
      final permissions = widget.tutor!.tutorPermissions ?? {};
      _canCreateLessons = permissions['create_lessons'] ?? true;
      _canUploadVideos = permissions['upload_videos'] ?? true;
      _canUploadPdfs = permissions['upload_pdfs'] ?? true;
      _canCreateQuizzes = permissions['create_quizzes'] ?? true;
      _canEditCourse = permissions['edit_course'] ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),

                // Form fields
                _buildNameField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                if (!_isEditing) ...[
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                ],
                const SizedBox(height: 24),

                // Permisos section
                _buildPermissionsSection(),
                const SizedBox(height: 24),

                // Buttons
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppConfig.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isEditing ? Icons.edit : Icons.person_add,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            _isEditing ? 'Editar Tutor' : 'Nuevo Tutor',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre completo',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Ingrese el nombre del tutor',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correo electrónico',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          enabled: !_isEditing,
          decoration: InputDecoration(
            hintText: 'tutor@idecap.edu.pe',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: _isEditing ? Colors.grey.shade200 : Colors.grey.shade50,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El correo es requerido';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Ingrese un correo válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Mínimo 6 caracteres',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La contraseña es requerida';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPermissionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 20, color: AppConfig.themeColor),
              const SizedBox(width: 8),
              Text(
                'Permisos del Tutor',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPermissionSwitch(
            'Crear lecciones',
            'Puede crear y editar lecciones en sus cursos',
            _canCreateLessons,
            (v) => setState(() => _canCreateLessons = v),
          ),
          _buildPermissionSwitch(
            'Subir videos',
            'Puede subir videos a las lecciones',
            _canUploadVideos,
            (v) => setState(() => _canUploadVideos = v),
          ),
          _buildPermissionSwitch(
            'Subir PDFs',
            'Puede subir documentos PDF',
            _canUploadPdfs,
            (v) => setState(() => _canUploadPdfs = v),
          ),
          _buildPermissionSwitch(
            'Crear quizzes',
            'Puede crear cuestionarios y exámenes',
            _canCreateQuizzes,
            (v) => setState(() => _canCreateQuizzes = v),
          ),
          _buildPermissionSwitch(
            'Editar información del curso',
            'Puede modificar título, descripción e imagen',
            _canEditCourse,
            (v) => setState(() => _canEditCourse = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConfig.themeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
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
            onPressed: _isLoading ? null : _saveTutor,
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
                : Text(_isEditing ? 'Actualizar' : 'Crear Tutor'),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getPermissions() {
    return {
      'create_lessons': _canCreateLessons,
      'upload_videos': _canUploadVideos,
      'upload_pdfs': _canUploadPdfs,
      'create_quizzes': _canCreateQuizzes,
      'edit_course': _canEditCourse,
    };
  }

  Future<void> _saveTutor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final permissions = _getPermissions();

      if (_isEditing) {
        // Update existing tutor
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.tutor!.id)
            .update({
          'name': name,
          'tutor_permissions': permissions,
          'updated_at': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          openSuccessToast(context, 'Tutor actualizado correctamente');
          Navigator.pop(context, true);
        }
      } else {
        // Check if user already exists
        final existingUsers = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (existingUsers.docs.isNotEmpty) {
          // User exists, add tutor role
          final existingDoc = existingUsers.docs.first;
          final existingData = existingDoc.data();
          final currentRoles = List<String>.from(existingData['role'] ?? []);

          if (currentRoles.contains('tutor')) {
            if (mounted) {
              openFailureToast(context, 'Este usuario ya es un tutor');
            }
            return;
          }

          currentRoles.add('tutor');

          await existingDoc.reference.update({
            'role': currentRoles,
            'tutor_permissions': permissions,
            'assigned_courses': [],
            'updated_at': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            openSuccessToast(context, 'Rol de tutor agregado al usuario existente');
            Navigator.pop(context, true);
          }
        } else {
          // Create new user with tutor role
          final password = _passwordController.text;

          // Create Firebase Auth user
          final userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Create Firestore document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': name,
            'email': email,
            'role': ['tutor'],
            'tutor_permissions': permissions,
            'assigned_courses': [],
            'disabled': false,
            'created_at': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            openSuccessToast(context, 'Tutor creado correctamente');
            Navigator.pop(context, true);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error al crear el tutor';
      if (e.code == 'email-already-in-use') {
        message = 'El correo ya está registrado en Firebase Auth';
      } else if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil';
      } else if (e.code == 'invalid-email') {
        message = 'El correo no es válido';
      }
      if (mounted) {
        openFailureToast(context, message);
      }
    } catch (e) {
      if (mounted) {
        openFailureToast(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
