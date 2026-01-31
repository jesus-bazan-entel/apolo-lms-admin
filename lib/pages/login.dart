import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/strings.dart';
import 'package:lms_admin/models/app_settings_model.dart';
import 'package:lms_admin/pages/verify.dart';
import 'package:lms_admin/providers/auth_state_provider.dart';
import 'package:lms_admin/providers/user_data_provider.dart';
import 'package:lms_admin/utils/reponsive.dart';
import 'package:lms_admin/pages/home.dart';
import 'package:lms_admin/services/auth_service.dart';
import 'package:lms_admin/utils/next_screen.dart';
import 'package:lms_admin/utils/toasts.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../tabs/admin_tabs/app_settings/app_setting_providers.dart';

class Login extends ConsumerStatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  var emailCtlr = TextEditingController();
  var passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController _btnCtlr = RoundedLoadingButtonController();
  bool _obsecureText = true;
  IconData _lockIcon = CupertinoIcons.eye_fill;

  _onChangeVisiblity() {
    if (_obsecureText == true) {
      setState(() {
        _obsecureText = false;
        _lockIcon = CupertinoIcons.eye;
      });
    } else {
      setState(() {
        _obsecureText = true;
        _lockIcon = CupertinoIcons.eye_fill;
      });
    }
  }

  void _handleLogin() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _btnCtlr.start();
      UserCredential? userCredential = await AuthService().loginWithEmailPassword(emailCtlr.text, passwordCtrl.text);
      if (userCredential?.user != null) {
        debugPrint('Login Success');
        _checkVerification(userCredential!);
      } else {
        _btnCtlr.reset();
        if (!mounted) return;
        openFailureToast(context, 'Correo/Contraseña inválida');
      }
    }
  }

  _checkVerification(UserCredential userCredential) async {
    final UserRoles role = await AuthService().checkUserRole(userCredential.user!.uid);
    if (role == UserRoles.admin || role == UserRoles.author) {
      ref.read(userRoleProvider.notifier).update((state) => role);

      // ADMIN skips license verification
      if (role == UserRoles.admin) {
        await ref.read(userDataProvider.notifier).getData();
        if (!mounted) return;
        NextScreen.replaceAnimation(context, const Home());
      } else {
        // AUTHOR needs license verification
        final settings = await ref.read(appSettingsProvider.future);
        final LicenseType license = settings?.license ?? LicenseType.none;
        final bool isVerified = license != LicenseType.none;

        if (isVerified) {
          await ref.read(userDataProvider.notifier).getData();
          if (!mounted) return;
          NextScreen.replaceAnimation(context, const Home());
        } else {
          if (!mounted) return;
          NextScreen.replaceAnimation(context, const VerifyInfo());
        }
      }
    } else {
      await AuthService().adminLogout().then((value) => openFailureToast(context, AppStrings.accessDenied));
    }
  }

  _handleDemoAdminLogin() async {
    ref.read(userRoleProvider.notifier).update((state) => UserRoles.guest);
    await AuthService().loginAnnonumously().then((value) => NextScreen.replaceAnimation(context, const Home()));
  }

  _handleGoogleSignIn() async {
    _btnCtlr.start();
    try {
      final userCredential = await AuthService().signInWithGoogle();
      if (userCredential?.user != null) {
        debugPrint('Google Sign In Success');
        _checkVerification(userCredential!);
      } else {
        _btnCtlr.reset();
        if (!mounted) return;
        openFailureToast(context, 'Inicio de sesión con Google cancelado');
      }
    } catch (e) {
      _btnCtlr.reset();
      if (!mounted) return;
      openFailureToast(context, 'Error al iniciar sesión con Google: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF009C3B), // Verde de Brasil
              const Color(0xFF002776), // Azul de Brasil
            ],
          ),
        ),
        child: Row(
          children: [
            // Panel izquierdo - Branding
            Visibility(
              visible: Responsive.isDesktop(context) || Responsive.isDesktopLarge(context),
              child: Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo/Icono
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IDECAP',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  'IDIOMAS',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFFDF00), // Amarillo de Brasil
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Título principal
                      Text(
                        'Aprende Portugués',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'de forma efectiva',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Descripción
                      Text(
                        'Plataforma de enseñanza de idiomas con metodología brasileña. Clases interactivas, contenido cultural y práctica real.',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Características
                      _buildFeatureItem(Icons.school, 'Metodología comprobada'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(Icons.people, 'Profesores nativos'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(Icons.emoji_events, 'Certificación oficial'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(Icons.flag, 'Cultura brasileña'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(Icons.auto_awesome, 'Potenciado por IA'),
                      
                      const SizedBox(height: 30),
                      
                      // Bandera de Brasil estilizada
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 34,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: const Color(0xFF009C3B),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform.rotate(
                                  angle: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFDF00),
                                      shape: BoxShape.rectangle,
                                    ),
                                    transform: Matrix4.rotationZ(0.785398), // 45 grados
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF002776),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Português do Brasil',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Panel derecho - Formulario
            Flexible(
              flex: 1,
              child: Form(
                key: formKey,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      bottomLeft: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getHorizontalPadding(),
                      vertical: 30.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo para móvil
                        if (!Responsive.isDesktop(context) && !Responsive.isDesktopLarge(context)) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF009C3B),
                                  const Color(0xFF002776),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.language, color: Colors.white, size: 30),
                                const SizedBox(width: 10),
                                Text(
                                  'IDECAP IDIOMAS',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                        
                        Text(
                          'Bienvenido',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF002776),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Panel de Administración',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 50),
                        
                        // Campo Email
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Correo Electrónico',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: emailCtlr,
                                style: GoogleFonts.poppins(),
                                validator: (value) {
                                  if (value!.isEmpty) return AppStrings.emailRequired;
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade500),
                                  suffixIcon: IconButton(
                                    onPressed: () => emailCtlr.clear(),
                                    icon: Icon(Icons.clear, color: Colors.grey.shade400),
                                  ),
                                  hintText: 'ejemplo@correo.com',
                                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            Text(
                              'Contraseña',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: TextFormField(
                                controller: passwordCtrl,
                                obscureText: _obsecureText,
                                style: GoogleFonts.poppins(),
                                validator: (value) {
                                  if (value!.isEmpty) return AppStrings.passwordRequired;
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: _onChangeVisiblity,
                                        icon: Icon(_lockIcon, color: Colors.grey.shade500),
                                      ),
                                      IconButton(
                                        onPressed: () => passwordCtrl.clear(),
                                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                                      ),
                                    ],
                                  ),
                                  hintText: '••••••••',
                                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // Botón de login
                            RoundedLoadingButton(
                              onPressed: _handleLogin,
                              controller: _btnCtlr,
                              color: const Color(0xFF009C3B),
                              width: MediaQuery.of(context).size.width,
                              borderRadius: 12,
                              height: 55,
                              animateOnTap: false,
                              elevation: 0,
                              child: Text(
                                'Iniciar Sesión',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Separador
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'o continúa con',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Botón de Google Sign In
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: OutlinedButton.icon(
                                onPressed: _handleGoogleSignIn,
                                icon: Image.network(
                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.g_mobiledata,
                                    size: 28,
                                    color: Color(0xFF4285F4),
                                  ),
                                ),
                                label: Text(
                                  'Continuar con Google',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade700,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFFDF00), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _getHorizontalPadding() {
    if (Responsive.isDesktopLarge(context)) {
      return 120;
    } else if (Responsive.isDesktop(context)) {
      return 80;
    } else if (Responsive.isTablet(context)) {
      return 100;
    } else {
      return 30;
    }
  }
}
