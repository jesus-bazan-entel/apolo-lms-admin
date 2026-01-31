import 'package:flutter/material.dart';

/// Configuración global de la aplicación ApoloLMS Admin
///
/// Paleta de colores optimizada para aplicaciones educativas
/// basada en las recomendaciones de UI/UX Pro Max skill.
class AppConfig {
  AppConfig._();

  // ============================================
  // APP INFO
  // ============================================

  /// Nombre de la aplicación
  static const String appName = 'IDECAP Idiomas';

  // ============================================
  // PRIMARY COLORS (Educational App Palette)
  // Basado en: Educational App #4F46E5, #818CF8, #F97316
  // ============================================

  /// Color primario principal - Indigo
  static const Color primaryColor = Color(0xFF4F46E5);

  /// Alias para compatibilidad
  static const Color themeColor = primaryColor;
  static const Color primaryIndigo = primaryColor;

  /// Color primario claro
  static const Color primaryLight = Color(0xFF818CF8);

  /// Color primario oscuro
  static const Color primaryDark = Color(0xFF3730A3);

  /// Color de acento - Purple
  static const Color accentColor = Color(0xFF8B5CF6);
  static const Color primaryPurple = accentColor;

  /// Color secundario - Cyan (acciones secundarias)
  static const Color secondaryColor = Color(0xFF06B6D4);

  // ============================================
  // SEMANTIC COLORS (Estados)
  // ============================================

  /// Color de éxito - Emerald
  static const Color successColor = Color(0xFF10B981);

  /// Color de advertencia - Amber
  static const Color warningColor = Color(0xFFF59E0B);

  /// Color de error - Red
  static const Color errorColor = Color(0xFFEF4444);

  /// Color informativo - Blue
  static const Color infoColor = Color(0xFF3B82F6);

  // ============================================
  // SURFACE COLORS (Light Mode)
  // ============================================

  /// Fondo del scaffold
  static const Color scaffoldBgColor = Color(0xFFF1F5F9);
  @Deprecated('Use scaffoldBgColor instead')
  static const Color scffoldBgColor = scaffoldBgColor; // Typo compatibility

  /// Color de tarjetas
  static const Color cardColor = Color(0xFFFFFFFF);

  /// Color de superficies
  static const Color surfaceColor = Color(0xFFF8FAFC);

  /// Color de la barra de título
  static const Color titleBarColor = Color(0xFFF8FAFC);

  // ============================================
  // NEUTRAL COLORS (Grises para reemplazar hardcoded)
  // ============================================

  /// Gris muy claro - Bordes y divisores
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // ============================================
  // DARK MODE SURFACE COLORS
  // ============================================

  /// Fondo oscuro principal
  static const Color darkBackground = Color(0xFF0F0F23);

  /// Superficie oscura
  static const Color darkSurface = Color(0xFF1E1E2E);

  /// Superficie oscura elevada
  static const Color darkSurfaceElevated = Color(0xFF2A2A3C);

  /// Borde oscuro
  static const Color darkBorder = Color(0xFF3D3D5C);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Texto primario (light mode)
  static const Color textPrimary = Color(0xFF1E293B);

  /// Texto secundario (light mode)
  static const Color textSecondary = Color(0xFF64748B);

  /// Texto terciario/disabled (light mode)
  static const Color textTertiary = Color(0xFF94A3B8);

  /// Texto primario (dark mode)
  static const Color textPrimaryDark = Color(0xFFF1F5F9);

  /// Texto secundario (dark mode)
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ============================================
  // GRADIENTS
  // ============================================

  /// Gradiente primario
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente oscuro (side menu)
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de acento
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de éxito
  static const LinearGradient successGradient = LinearGradient(
    colors: [successColor, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // LEGACY COMPATIBILITY (Deprecated)
  // ============================================

  @Deprecated('Use primaryColor instead')
  static const Color primaryGreen = primaryColor;

  @Deprecated('Use warningColor instead')
  static const Color primaryYellow = warningColor;

  @Deprecated('Use infoColor instead')
  static const Color primaryBlue = infoColor;

  // ============================================
  // EXTERNAL SERVICES
  // ============================================

  /// Gemini AI API Key (fallback - preferir Firebase Config)
  static const String geminiApiKey = 'AIzaSyBnLGYrGJjqp3Q5LKSfQr9fLxBbQKzrNUE';
}
