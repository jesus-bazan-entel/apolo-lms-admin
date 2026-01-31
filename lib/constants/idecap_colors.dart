import 'package:flutter/material.dart';

/// Colores institucionales de IDECAP
/// Instituto de Desarrollo y Capacitación - Idioma Portugués
class IdecapColors {
  IdecapColors._();

  // ============ COLORES PRIMARIOS (Verde-Amarillo del logo) ============

  /// Verde brillante IDECAP - Color principal del gradiente
  static const Color primary = Color(0xFF00C853);

  /// Verde más brillante (parte superior del gradiente)
  static const Color primaryBright = Color(0xFF00E676);

  /// Verde oscuro
  static const Color primaryDark = Color(0xFF009624);

  /// Variantes del verde primario
  static const Color primaryLight = Color(0xFF69F0AE);

  // ============ COLORES SECUNDARIOS (Amarillo) ============

  /// Amarillo IDECAP - Color secundario del gradiente
  static const Color secondary = Color(0xFFFFEB3B);

  /// Amarillo brillante
  static const Color secondaryBright = Color(0xFFFFFF00);

  /// Amarillo oscuro
  static const Color secondaryDark = Color(0xFFFBC02D);

  // ============ COLORES DE ACENTO (Azul del logo) ============

  /// Azul IDECAP - Color del logo/icono
  static const Color accent = Color(0xFF1565C0);

  /// Variantes del azul
  static const Color accentLight = Color(0xFF5E92F3);
  static const Color accentDark = Color(0xFF003C8F);

  // ============ AZUL OSCURO (Footer/Sección inferior) ============

  /// Azul oscuro navy - Para secciones inferiores
  static const Color navy = Color(0xFF0D47A1);

  /// Navy más oscuro
  static const Color navyDark = Color(0xFF002171);

  /// Navy claro
  static const Color navyLight = Color(0xFF5472D3);

  // ============ GRADIENTES ============

  /// Gradiente principal IDECAP (Verde brillante a Amarillo) - Vertical
  static const LinearGradient splashGradient = LinearGradient(
    colors: [primaryBright, primary, secondaryBright, secondary],
    stops: [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Gradiente para pantalla de bienvenida (más suave)
  static const LinearGradient welcomeGradient = LinearGradient(
    colors: [primaryBright, primaryLight, secondary],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
