import 'package:flutter/material.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/design_tokens.dart';

/// Vista de estado vacío profesional
///
/// Usado cuando no hay datos para mostrar en listas, tablas, etc.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.iconWidget,
    this.action,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.compact = false,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final Widget? iconWidget;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool compact;

  /// Factory para lista de cursos vacía
  factory EmptyStateView.courses({VoidCallback? onCreate}) {
    return EmptyStateView(
      title: 'No hay cursos',
      message: 'Crea tu primer curso para comenzar a enseñar',
      icon: Icons.school_outlined,
      actionLabel: 'Crear curso',
      onAction: onCreate,
    );
  }

  /// Factory para lista de estudiantes vacía
  factory EmptyStateView.students({VoidCallback? onAdd}) {
    return EmptyStateView(
      title: 'No hay estudiantes',
      message: 'Agrega estudiantes para gestionar sus inscripciones',
      icon: Icons.people_outlined,
      actionLabel: 'Agregar estudiante',
      onAction: onAdd,
    );
  }

  /// Factory para lista de lecciones vacía
  factory EmptyStateView.lessons({VoidCallback? onCreate}) {
    return EmptyStateView(
      title: 'No hay lecciones',
      message: 'Agrega lecciones a este módulo',
      icon: Icons.play_lesson_outlined,
      actionLabel: 'Crear lección',
      onAction: onCreate,
    );
  }

  /// Factory para búsqueda sin resultados
  factory EmptyStateView.noResults({String? query, VoidCallback? onClear}) {
    return EmptyStateView(
      title: 'Sin resultados',
      message: query != null
          ? 'No se encontraron resultados para "$query"'
          : 'No se encontraron resultados',
      icon: Icons.search_off_outlined,
      actionLabel: 'Limpiar búsqueda',
      onAction: onClear,
    );
  }

  /// Factory para error de carga
  factory EmptyStateView.error({String? message, VoidCallback? onRetry}) {
    return EmptyStateView(
      title: 'Error al cargar',
      message: message ?? 'Ocurrió un error al cargar los datos',
      icon: Icons.error_outline,
      actionLabel: 'Reintentar',
      onAction: onRetry,
    );
  }

  /// Factory para sin conexión
  factory EmptyStateView.offline({VoidCallback? onRetry}) {
    return EmptyStateView(
      title: 'Sin conexión',
      message: 'Verifica tu conexión a internet e intenta de nuevo',
      icon: Icons.wifi_off_outlined,
      actionLabel: 'Reintentar',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (compact) {
      return _buildCompact(context, theme, isDark);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space3xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            _buildIcon(context, theme, isDark),

            DesignTokens.vSpace2xl,

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Message
            if (message != null) ...[
              DesignTokens.vSpaceSm,
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Actions
            if (action != null || actionLabel != null) ...[
              DesignTokens.vSpace2xl,
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            decoration: BoxDecoration(
              color: (isDark ? AppConfig.neutral700 : AppConfig.neutral100),
              borderRadius: DesignTokens.borderRadiusMd,
            ),
            child: Icon(
              icon ?? Icons.inbox_outlined,
              size: DesignTokens.iconLg,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          DesignTokens.hSpaceLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message != null) ...[
                  DesignTokens.vSpaceXs,
                  Text(
                    message!,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, ThemeData theme, bool isDark) {
    if (iconWidget != null) return iconWidget!;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space2xl),
      decoration: BoxDecoration(
        color: (isDark ? AppConfig.neutral800 : AppConfig.neutral100),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? Icons.inbox_outlined,
        size: DesignTokens.icon2xl,
        color: theme.textTheme.bodySmall?.color,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (action != null) return action!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (actionLabel != null && onAction != null)
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add, size: DesignTokens.iconSm),
            label: Text(actionLabel!),
          ),
        if (secondaryActionLabel != null && onSecondaryAction != null) ...[
          DesignTokens.vSpaceSm,
          TextButton(
            onPressed: onSecondaryAction,
            child: Text(secondaryActionLabel!),
          ),
        ],
      ],
    );
  }
}

/// Vista de carga con esqueleto
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final double? borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? AppConfig.neutral800 : AppConfig.neutral200;
    final highlightColor = isDark ? AppConfig.neutral700 : AppConfig.neutral100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? DesignTokens.radiusXs,
            ),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tarjeta esqueleto para listas
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.hasImage = true,
    this.lines = 3,
  });

  final bool hasImage;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: DesignTokens.borderRadiusMd,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[
            const SkeletonLoader(
              height: 120,
              borderRadius: DesignTokens.radiusSm,
            ),
            DesignTokens.vSpaceLg,
          ],
          for (var i = 0; i < lines; i++) ...[
            SkeletonLoader(
              width: i == 0 ? double.infinity : (i == lines - 1 ? 100 : 200),
              height: i == 0 ? 20 : 14,
            ),
            if (i < lines - 1) DesignTokens.vSpaceSm,
          ],
        ],
      ),
    );
  }
}

/// Lista de tarjetas esqueleto
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 3,
    this.hasImage = true,
  });

  final int itemCount;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => DesignTokens.vSpaceMd,
      itemBuilder: (_, __) => SkeletonCard(hasImage: hasImage),
    );
  }
}
