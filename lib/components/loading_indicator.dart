import 'package:flutter/material.dart';
import 'package:lms_admin/configs/design_tokens.dart';

/// Componente de loading unificado para toda la aplicación
///
/// Proporciona indicadores de carga consistentes con el tema.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.strokeWidth,
    this.message,
  });

  /// Tamaño del indicador
  final LoadingSize size;

  /// Color personalizado (null usa el color del tema)
  final Color? color;

  /// Ancho del trazo (null usa valor por defecto según tamaño)
  final double? strokeWidth;

  /// Mensaje opcional debajo del indicador
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final dimensions = size.dimensions;
    final effectiveStrokeWidth = strokeWidth ?? size.strokeWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: dimensions,
          height: dimensions,
          child: CircularProgressIndicator(
            strokeWidth: effectiveStrokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        ),
        if (message != null) ...[
          DesignTokens.vSpaceMd,
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Crea un loading centrado en pantalla completa
  static Widget fullScreen({
    String? message,
    Color? color,
  }) {
    return Center(
      child: LoadingIndicator(
        size: LoadingSize.large,
        message: message,
        color: color,
      ),
    );
  }

  /// Crea un loading para usar dentro de botones
  static Widget button({Color? color}) {
    return LoadingIndicator(
      size: LoadingSize.small,
      color: color ?? Colors.white,
    );
  }

  /// Crea un loading overlay semi-transparente
  static Widget overlay({
    required Widget child,
    required bool isLoading,
    String? message,
    Color? barrierColor,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: barrierColor ?? Colors.black.withOpacity(0.3),
              child: LoadingIndicator.fullScreen(message: message),
            ),
          ),
      ],
    );
  }
}

/// Tamaños predefinidos para el indicador de carga
enum LoadingSize {
  /// Pequeño: 20x20, strokeWidth: 2
  small,

  /// Mediano: 36x36, strokeWidth: 3
  medium,

  /// Grande: 48x48, strokeWidth: 4
  large,
}

extension LoadingSizeExtension on LoadingSize {
  double get dimensions {
    switch (this) {
      case LoadingSize.small:
        return 20;
      case LoadingSize.medium:
        return 36;
      case LoadingSize.large:
        return 48;
    }
  }

  double get strokeWidth {
    switch (this) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
    }
  }
}

/// Estado vacío con opción de retry
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space3xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: DesignTokens.icon2xl,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            DesignTokens.vSpaceLg,
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              DesignTokens.vSpaceXl,
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de error con opción de retry
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Reintentar',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space3xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: DesignTokens.icon2xl,
              color: theme.colorScheme.error,
            ),
            DesignTokens.vSpaceLg,
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              DesignTokens.vSpaceXl,
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget helper para manejar estados de carga/error/vacío
class AsyncStateWidget<T> extends StatelessWidget {
  const AsyncStateWidget({
    super.key,
    required this.isLoading,
    required this.error,
    required this.data,
    required this.builder,
    this.loadingMessage,
    this.emptyMessage,
    this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final T? data;
  final Widget Function(T data) builder;
  final String? loadingMessage;
  final String? emptyMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingIndicator.fullScreen(message: loadingMessage);
    }

    if (error != null) {
      return ErrorState(
        message: error!,
        onRetry: onRetry,
      );
    }

    if (data == null) {
      return EmptyState(
        message: emptyMessage ?? 'No hay datos disponibles',
      );
    }

    return builder(data as T);
  }
}
