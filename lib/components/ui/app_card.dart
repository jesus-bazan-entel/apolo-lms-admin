import 'package:flutter/material.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/design_tokens.dart';

/// Tarjeta profesional reutilizable con múltiples variantes
///
/// Incluye soporte para:
/// - Hover effects
/// - Gradientes
/// - Badges/indicadores
/// - Acciones
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.elevation,
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.badge,
    this.header,
    this.footer,
    this.isSelected = false,
    this.isDisabled = false,
    this.enableHover = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? elevation;
  final double? borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final Widget? badge;
  final Widget? header;
  final Widget? footer;
  final bool isSelected;
  final bool isDisabled;
  final bool enableHover;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveRadius = widget.borderRadius ?? DesignTokens.radiusMd;
    final effectivePadding = widget.padding ?? const EdgeInsets.all(DesignTokens.spaceLg);
    final effectiveElevation = widget.elevation ?? (_isHovered ? DesignTokens.elevation4 : DesignTokens.elevation2);

    final effectiveBgColor = widget.backgroundColor ??
        (isDark ? AppConfig.darkSurface : AppConfig.cardColor);

    final effectiveBorderColor = widget.isSelected
        ? theme.colorScheme.primary
        : widget.borderColor ?? (isDark ? AppConfig.darkBorder : AppConfig.neutral200);

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card principal
          MouseRegion(
            onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
            onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
            cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: AnimatedContainer(
              duration: DesignTokens.animFast,
              curve: DesignTokens.curveStandard,
              decoration: BoxDecoration(
                gradient: widget.gradient,
                color: widget.gradient == null ? effectiveBgColor : null,
                borderRadius: BorderRadius.circular(effectiveRadius),
                border: Border.all(
                  color: effectiveBorderColor,
                  width: widget.isSelected ? 2 : (widget.borderWidth ?? 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.12 : 0.06),
                    blurRadius: effectiveElevation * 2,
                    offset: Offset(0, effectiveElevation),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isDisabled ? null : widget.onTap,
                  onLongPress: widget.isDisabled ? null : widget.onLongPress,
                  borderRadius: BorderRadius.circular(effectiveRadius),
                  child: Opacity(
                    opacity: widget.isDisabled ? DesignTokens.opacityDisabled : 1.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.header != null) widget.header!,
                        Padding(
                          padding: effectivePadding,
                          child: widget.child,
                        ),
                        if (widget.footer != null) widget.footer!,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Badge
          if (widget.badge != null)
            Positioned(
              top: -8,
              right: -8,
              child: widget.badge!,
            ),
        ],
      ),
    );
  }
}

/// Badge para indicadores en tarjetas
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
    this.size = AppBadgeSize.medium,
  });

  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final AppBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveTextColor = textColor ?? Colors.white;

    final fontSize = size == AppBadgeSize.small ? 10.0 : 12.0;
    final padding = size == AppBadgeSize.small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    final iconSize = size == AppBadgeSize.small ? 12.0 : 14.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: effectiveTextColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum AppBadgeSize { small, medium }

/// Tarjeta de estadísticas para dashboard
class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trend,
    this.trendValue,
    this.gradient,
    this.onTap,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final TrendDirection? trend;
  final String? trendValue;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
                    borderRadius: DesignTokens.borderRadiusMd,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.primary,
                    size: DesignTokens.iconLg,
                  ),
                ),
              if (icon != null) DesignTokens.hSpaceLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: gradient != null
                            ? Colors.white.withOpacity(0.8)
                            : theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    DesignTokens.vSpaceXs,
                    Text(
                      value,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: gradient != null ? Colors.white : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (subtitle != null || trend != null) ...[
            DesignTokens.vSpaceMd,
            Row(
              children: [
                if (trend != null) ...[
                  _TrendIndicator(direction: trend!, value: trendValue),
                  if (subtitle != null) DesignTokens.hSpaceSm,
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: gradient != null
                            ? Colors.white.withOpacity(0.7)
                            : theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

enum TrendDirection { up, down, neutral }

class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({
    required this.direction,
    this.value,
  });

  final TrendDirection direction;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final color = direction == TrendDirection.up
        ? AppConfig.successColor
        : direction == TrendDirection.down
            ? AppConfig.errorColor
            : AppConfig.neutral500;

    final icon = direction == TrendDirection.up
        ? Icons.trending_up_rounded
        : direction == TrendDirection.down
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: DesignTokens.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          if (value != null) ...[
            const SizedBox(width: 4),
            Text(
              value!,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta de contenido con imagen
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.placeholder,
    this.badge,
    this.actions,
    this.onTap,
    this.aspectRatio = 16 / 9,
  });

  final String title;
  final String? subtitle;
  final String? imageUrl;
  final Widget? placeholder;
  final Widget? badge;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      badge: badge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen
          AspectRatio(
            aspectRatio: aspectRatio,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(DesignTokens.radiusMd),
              ),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  DesignTokens.vSpaceXs,
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (actions != null && actions!.isNotEmpty) ...[
                  DesignTokens.vSpaceMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!;

    return Container(
      color: AppConfig.neutral100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppConfig.neutral400,
        ),
      ),
    );
  }
}
