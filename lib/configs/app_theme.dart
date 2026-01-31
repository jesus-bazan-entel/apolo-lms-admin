import 'package:flutter/material.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/design_tokens.dart';

/// Tema de la aplicación ApoloLMS Admin
///
/// Incluye soporte para Light Mode y Dark Mode
/// basado en Material Design 3 y los design tokens.
class AppTheme {
  AppTheme._();

  // ============================================
  // COLOR ALIASES (Para compatibilidad)
  // ============================================

  static const Color primaryColor = AppConfig.primaryColor;
  static const Color accentColor = AppConfig.accentColor;
  static const Color backgroundColor = AppConfig.surfaceColor;
  static const Color cardColor = AppConfig.cardColor;
  static const Color textPrimary = AppConfig.textPrimary;
  static const Color textSecondary = AppConfig.textSecondary;
  static const Color dividerColor = AppConfig.neutral200;
  static const Color errorColor = AppConfig.errorColor;
  static const Color successColor = AppConfig.successColor;
  static const Color warningColor = AppConfig.warningColor;
  static const Color infoColor = AppConfig.infoColor;

  // Legacy aliases (deprecated)
  @Deprecated('Use primaryColor instead')
  static const Color primaryGreen = AppConfig.primaryColor;
  @Deprecated('Use warningColor instead')
  static const Color primaryYellow = AppConfig.warningColor;
  @Deprecated('Use infoColor instead')
  static const Color primaryBlue = AppConfig.infoColor;

  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: AppConfig.primaryLight.withOpacity(0.2),
        onPrimaryContainer: AppConfig.primaryDark,
        secondary: accentColor,
        onSecondary: Colors.white,
        secondaryContainer: accentColor.withOpacity(0.2),
        onSecondaryContainer: AppConfig.primaryDark,
        tertiary: AppConfig.secondaryColor,
        onTertiary: Colors.white,
        surface: cardColor,
        onSurface: textPrimary,
        surfaceContainerHighest: AppConfig.neutral100,
        error: errorColor,
        onError: Colors.white,
        outline: AppConfig.neutral300,
        outlineVariant: AppConfig.neutral200,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppConfig.scaffoldBgColor,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: DesignTokens.elevation2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusMd,
        ),
        margin: const EdgeInsets.all(DesignTokens.spaceSm),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: DesignTokens.elevation2,
          minimumSize: const Size(0, DesignTokens.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space2xl,
            vertical: DesignTokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusSm,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          minimumSize: const Size(0, DesignTokens.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space2xl,
            vertical: DesignTokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusSm,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(DesignTokens.minTouchTarget, DesignTokens.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceSm,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(DesignTokens.minTouchTarget, DesignTokens.minTouchTarget),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: DesignTokens.elevation4,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConfig.neutral50,
        border: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: BorderSide(color: AppConfig.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: BorderSide(color: AppConfig.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: AppConfig.neutral400),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: DesignTokens.spaceMd,
        ),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return AppConfig.neutral400;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return AppConfig.neutral400;
        }),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return AppConfig.neutral300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return AppConfig.neutral300;
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: AppConfig.neutral200,
        linearTrackColor: AppConfig.neutral200,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: accentColor.withOpacity(0.1),
        selectedColor: accentColor,
        labelStyle: const TextStyle(color: textPrimary),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusXl,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        elevation: DesignTokens.elevation8,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusLg,
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        elevation: DesignTokens.elevation8,
        type: BottomNavigationBarType.fixed,
      ),

      // Navigation Rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardColor,
        selectedIconTheme: IconThemeData(
          color: primaryColor,
          size: DesignTokens.iconMd,
        ),
        unselectedIconTheme: IconThemeData(
          color: textSecondary,
          size: DesignTokens.iconMd,
        ),
        selectedLabelTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryColor,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(textPrimary, textSecondary),

      // Icon Theme
      iconTheme: IconThemeData(
        color: textSecondary,
        size: DesignTokens.iconMd,
      ),

      // Primary Icon Theme
      primaryIconTheme: IconThemeData(
        color: Colors.white,
        size: DesignTokens.iconMd,
      ),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================

  static ThemeData get darkTheme {
    const darkTextPrimary = AppConfig.textPrimaryDark;
    const darkTextSecondary = AppConfig.textSecondaryDark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppConfig.primaryLight,
        onPrimary: AppConfig.primaryDark,
        primaryContainer: primaryColor.withOpacity(0.3),
        onPrimaryContainer: AppConfig.primaryLight,
        secondary: accentColor,
        onSecondary: Colors.white,
        secondaryContainer: accentColor.withOpacity(0.3),
        onSecondaryContainer: AppConfig.primaryLight,
        tertiary: AppConfig.secondaryColor,
        onTertiary: Colors.white,
        surface: AppConfig.darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: AppConfig.darkSurfaceElevated,
        error: errorColor,
        onError: Colors.white,
        outline: AppConfig.darkBorder,
        outlineVariant: AppConfig.neutral700,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppConfig.darkBackground,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppConfig.darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppConfig.darkSurface,
        elevation: DesignTokens.elevation2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusMd,
        ),
        margin: const EdgeInsets.all(DesignTokens.spaceSm),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryLight,
          foregroundColor: AppConfig.primaryDark,
          elevation: DesignTokens.elevation2,
          minimumSize: const Size(0, DesignTokens.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space2xl,
            vertical: DesignTokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusSm,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConfig.primaryLight,
          side: BorderSide(color: AppConfig.primaryLight, width: 2),
          minimumSize: const Size(0, DesignTokens.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space2xl,
            vertical: DesignTokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusSm,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConfig.primaryLight,
          minimumSize: const Size(DesignTokens.minTouchTarget, DesignTokens.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceSm,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(DesignTokens.minTouchTarget, DesignTokens.minTouchTarget),
          foregroundColor: darkTextPrimary,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppConfig.primaryLight,
        foregroundColor: AppConfig.primaryDark,
        elevation: DesignTokens.elevation4,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConfig.darkSurfaceElevated,
        border: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: BorderSide(color: AppConfig.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: BorderSide(color: AppConfig.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: BorderSide(color: AppConfig.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusSm,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: TextStyle(color: AppConfig.neutral500),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: DesignTokens.spaceMd,
        ),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppConfig.primaryLight;
          }
          return AppConfig.neutral500;
        }),
        checkColor: WidgetStateProperty.all(AppConfig.primaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppConfig.primaryLight;
          }
          return AppConfig.neutral500;
        }),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppConfig.primaryLight;
          }
          return AppConfig.neutral500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppConfig.primaryLight.withOpacity(0.5);
          }
          return AppConfig.neutral700;
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppConfig.primaryLight,
        circularTrackColor: AppConfig.neutral700,
        linearTrackColor: AppConfig.neutral700,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppConfig.darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: accentColor.withOpacity(0.2),
        selectedColor: accentColor,
        labelStyle: const TextStyle(color: darkTextPrimary),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusXl,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppConfig.darkSurface,
        elevation: DesignTokens.elevation8,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusLg,
        ),
        titleTextStyle: const TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: darkTextSecondary,
          fontSize: 16,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppConfig.darkSurface,
        selectedItemColor: AppConfig.primaryLight,
        unselectedItemColor: darkTextSecondary,
        elevation: DesignTokens.elevation8,
        type: BottomNavigationBarType.fixed,
      ),

      // Navigation Rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppConfig.darkSurface,
        selectedIconTheme: IconThemeData(
          color: AppConfig.primaryLight,
          size: DesignTokens.iconMd,
        ),
        unselectedIconTheme: IconThemeData(
          color: darkTextSecondary,
          size: DesignTokens.iconMd,
        ),
        selectedLabelTextStyle: TextStyle(
          color: AppConfig.primaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: darkTextSecondary,
          fontSize: 14,
        ),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: AppConfig.primaryLight,
        unselectedLabelColor: darkTextSecondary,
        indicatorColor: AppConfig.primaryLight,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(darkTextPrimary, darkTextSecondary),

      // Icon Theme
      iconTheme: IconThemeData(
        color: darkTextSecondary,
        size: DesignTokens.iconMd,
      ),

      // Primary Icon Theme
      primaryIconTheme: IconThemeData(
        color: AppConfig.primaryDark,
        size: DesignTokens.iconMd,
      ),
    );
  }

  // ============================================
  // HELPER: Build Text Theme
  // ============================================

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: primary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
    );
  }
  
  // ============================================
  // GRADIENTS
  // ============================================

  /// Gradiente primario (indigo → purple)
  static LinearGradient get primaryGradient => AppConfig.primaryGradient;

  /// Gradiente oscuro (para side menu)
  static LinearGradient get darkGradient => AppConfig.darkGradient;

  /// Gradiente de acento
  static LinearGradient get accentGradient => AppConfig.accentGradient;

  /// Gradiente de éxito
  static LinearGradient get successGradient => AppConfig.successGradient;

  @Deprecated('Use primaryGradient instead')
  static LinearGradient get blueGradient => primaryGradient;

  // ============================================
  // SHADOWS
  // ============================================

  /// Sombra sutil para tarjetas
  static List<BoxShadow> get cardShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(DesignTokens.opacitySubtle),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Sombra elevada para elementos flotantes
  static List<BoxShadow> get elevatedShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(DesignTokens.opacityLight),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Sombra para elementos enfocados
  static List<BoxShadow> get focusShadow {
    return [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Sombra para dark mode
  static List<BoxShadow> get darkCardShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
