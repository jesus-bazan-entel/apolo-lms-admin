import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/design_tokens.dart';

/// Muestra un toast para modo testing
void openTestingToast(context) {
  return openFailureToast(context, 'La modificación está deshabilitada en modo testing');
}

/// Muestra un toast informativo con el color primario
void openToast(context, String message) {
  final toast = Container(
    padding: const EdgeInsets.symmetric(
      vertical: DesignTokens.spaceSm,
      horizontal: DesignTokens.spaceLg,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: DesignTokens.borderRadiusSm,
    ),
    child: Text(
      message,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
    ),
  );
  FToast().init(context).showToast(child: toast);
}

/// Muestra un toast de error con icono
void openFailureToast(context, String message) {
  final toast = Container(
    padding: const EdgeInsets.symmetric(
      vertical: DesignTokens.spaceSm,
      horizontal: DesignTokens.spaceLg,
    ),
    decoration: BoxDecoration(
      color: AppConfig.errorColor,
      borderRadius: DesignTokens.borderRadiusSm,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Colors.white,
          size: DesignTokens.iconSm,
        ),
        DesignTokens.hSpaceSm,
        Flexible(
          child: Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ],
    ),
  );
  FToast().init(context).showToast(child: toast);
}

/// Muestra un toast de éxito con icono
void openSuccessToast(context, String message) {
  final toast = Container(
    padding: const EdgeInsets.symmetric(
      vertical: DesignTokens.spaceSm,
      horizontal: DesignTokens.spaceLg,
    ),
    decoration: BoxDecoration(
      color: AppConfig.successColor,
      borderRadius: DesignTokens.borderRadiusSm,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.white,
          size: DesignTokens.iconSm,
        ),
        DesignTokens.hSpaceSm,
        Flexible(
          child: Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ],
    ),
  );
  FToast().init(context).showToast(child: toast);
}

/// Muestra un toast de advertencia con icono
void openWarningToast(context, String message) {
  final toast = Container(
    padding: const EdgeInsets.symmetric(
      vertical: DesignTokens.spaceSm,
      horizontal: DesignTokens.spaceLg,
    ),
    decoration: BoxDecoration(
      color: AppConfig.warningColor,
      borderRadius: DesignTokens.borderRadiusSm,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
          size: DesignTokens.iconSm,
        ),
        DesignTokens.hSpaceSm,
        Flexible(
          child: Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ],
    ),
  );
  FToast().init(context).showToast(child: toast);
}

/// Muestra un toast informativo con icono
void openInfoToast(context, String message) {
  final toast = Container(
    padding: const EdgeInsets.symmetric(
      vertical: DesignTokens.spaceSm,
      horizontal: DesignTokens.spaceLg,
    ),
    decoration: BoxDecoration(
      color: AppConfig.infoColor,
      borderRadius: DesignTokens.borderRadiusSm,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: Colors.white,
          size: DesignTokens.iconSm,
        ),
        DesignTokens.hSpaceSm,
        Flexible(
          child: Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ],
    ),
  );
  FToast().init(context).showToast(child: toast);
}
