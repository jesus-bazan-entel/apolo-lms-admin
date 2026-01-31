import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para el modo del tema (light/dark/system)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Notifier para manejar cambios de tema
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  /// Cambiar al modo claro
  void setLightMode() {
    state = ThemeMode.light;
  }

  /// Cambiar al modo oscuro
  void setDarkMode() {
    state = ThemeMode.dark;
  }

  /// Usar preferencia del sistema
  void setSystemMode() {
    state = ThemeMode.system;
  }

  /// Alternar entre light y dark
  void toggleTheme() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }

  /// Establecer modo específico
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

/// Provider que indica si el tema actual es oscuro
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});
