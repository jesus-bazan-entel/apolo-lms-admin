import 'package:flutter/material.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/design_tokens.dart';
import 'package:lms_admin/utils/reponsive.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

/// Botones personalizados con touch targets accesibles (min 48px)
///
/// Todos los botones cumplen con las guías de accesibilidad:
/// - iOS: 44pt mínimo
/// - Android: 48dp mínimo
class CustomButtons {
  CustomButtons._();

  /// Botón outlined con icono y texto
  ///
  /// Touch target mínimo: 48px
  static OutlinedButton customOutlineButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    Color bgColor = Colors.transparent,
    Color? foregroundColor,
  }) {
    final color = foregroundColor ?? Theme.of(context).colorScheme.primary;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: DesignTokens.spaceMd,
        ),
        minimumSize: const Size(0, DesignTokens.minTouchTarget),
        backgroundColor: bgColor,
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusFull,
        ),
      ),
      icon: Icon(icon, size: DesignTokens.iconSm),
      label: Visibility(
        visible: !Responsive.isMobile(context),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
        ),
      ),
      onPressed: onPressed,
    );
  }

  /// Botón de envío con indicador de carga
  ///
  /// Touch target mínimo: 48px
  static RoundedLoadingButton submitButton(
    BuildContext context, {
    required RoundedLoadingButtonController buttonController,
    required String text,
    required VoidCallback onPressed,
    double? borderRadius,
    double? width,
    double? height,
    double? elevation,
    Color? bgColor,
  }) {
    return RoundedLoadingButton(
      onPressed: onPressed,
      animateOnTap: false,
      color: bgColor ?? Theme.of(context).colorScheme.primary,
      width: width ?? MediaQuery.of(context).size.width,
      elevation: elevation ?? 0,
      height: height ?? DesignTokens.minTouchTarget,
      borderRadius: borderRadius ?? DesignTokens.radiusSm,
      controller: buttonController,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  /// Botón normal con fondo de color
  ///
  /// Touch target mínimo: 48px
  static TextButton normalButton(
    BuildContext context, {
    required String text,
    VoidCallback? onPressed,
    Color? bgColor,
    double? radius,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: bgColor ?? Theme.of(context).colorScheme.primary,
        minimumSize: const Size(0, DesignTokens.minTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceXl,
          vertical: DesignTokens.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? DesignTokens.radiusFull),
        ),
      ),
      onPressed: onPressed ?? () => Navigator.pop(context),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  /// Botón circular con icono
  ///
  /// Touch target: 48px (radius 24)
  static Widget circleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    Color? bgColor,
    double? radius,
    String? tooltip,
    Color? iconColor,
  }) {
    final effectiveRadius = radius ?? 24.0; // 48px touch target
    final effectiveIconSize = effectiveRadius * 0.8; // Icon proportional to button

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: bgColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: effectiveRadius * 2,
            height: effectiveRadius * 2,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
              size: effectiveIconSize,
            ),
          ),
        ),
      ),
    );
  }

  /// Botón de icono con tamaño mínimo accesible
  ///
  /// Touch target mínimo: 48px
  static IconButton accessibleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? color,
    double? iconSize,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
      color: color,
      iconSize: iconSize ?? DesignTokens.iconMd,
      constraints: const BoxConstraints(
        minWidth: DesignTokens.minTouchTarget,
        minHeight: DesignTokens.minTouchTarget,
      ),
    );
  }

  /// Botón primario con gradiente
  static Widget gradientButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
    Gradient? gradient,
    double? width,
    double? height,
    double? borderRadius,
  }) {
    return Container(
      width: width,
      height: height ?? DesignTokens.minTouchTarget,
      decoration: BoxDecoration(
        gradient: gradient ?? AppConfig.primaryGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? DesignTokens.radiusSm),
        boxShadow: [
          BoxShadow(
            color: AppConfig.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius ?? DesignTokens.radiusSm),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
