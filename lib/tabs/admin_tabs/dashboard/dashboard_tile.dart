import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/design_tokens.dart';

/// Tarjeta de estadísticas del Dashboard
///
/// Muestra métricas clave con animación de contador,
/// iconos y soporte para gradientes.
class DashboardTile extends StatefulWidget {
  const DashboardTile({
    super.key,
    required this.info,
    required this.count,
    required this.icon,
    this.bgColor,
    this.gradient,
    this.onTap,
    this.trend,
    this.trendValue,
  });

  final String info;
  final int count;
  final IconData icon;
  final Color? bgColor;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final TrendDirection? trend;
  final String? trendValue;

  @override
  State<DashboardTile> createState() => _DashboardTileState();
}

class _DashboardTileState extends State<DashboardTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasGradient = widget.gradient != null;
    final accentColor = widget.bgColor ?? theme.colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DesignTokens.animFast,
          curve: DesignTokens.curveStandard,
          transform: Matrix4.diagonal3Values(
            _isHovered ? 1.02 : 1.0,
            _isHovered ? 1.02 : 1.0,
            1.0,
          ),
          padding: const EdgeInsets.all(DesignTokens.space2xl),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: hasGradient
                ? null
                : (isDark ? AppConfig.darkSurface : AppConfig.cardColor),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: hasGradient
                ? null
                : Border.all(
                    color: isDark ? AppConfig.darkBorder : AppConfig.neutral200,
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: (hasGradient ? accentColor : Colors.black)
                    .withValues(alpha: _isHovered ? 0.15 : 0.08),
                blurRadius: _isHovered ? 24 : 12,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeader(theme, isDark, hasGradient, accentColor),
              DesignTokens.vSpaceSm,
              _buildFooter(theme, isDark, hasGradient),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, bool hasGradient, Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icon container
        Container(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          decoration: BoxDecoration(
            color: hasGradient
                ? Colors.white.withValues(alpha: 0.2)
                : accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Icon(
            widget.icon,
            size: DesignTokens.iconLg,
            color: hasGradient ? Colors.white : accentColor,
          ),
        ),

        // Animated counter
        AnimatedFlipCounter(
          duration: const Duration(milliseconds: 500),
          value: widget.count,
          thousandSeparator: ',',
          textStyle: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: hasGradient
                ? Colors.white
                : (isDark ? AppConfig.neutral100 : AppConfig.neutral800),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme, bool isDark, bool hasGradient) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.info,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: hasGradient
                  ? Colors.white.withValues(alpha: 0.9)
                  : (isDark ? AppConfig.neutral400 : AppConfig.neutral600),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DesignTokens.hSpaceSm,
        _buildTrendIndicator(hasGradient),
      ],
    );
  }

  Widget _buildTrendIndicator(bool hasGradient) {
    final trend = widget.trend ?? TrendDirection.up;
    final iconData = switch (trend) {
      TrendDirection.up => Icons.trending_up_rounded,
      TrendDirection.down => Icons.trending_down_rounded,
      TrendDirection.neutral => Icons.trending_flat_rounded,
    };

    final color = switch (trend) {
      TrendDirection.up => AppConfig.successColor,
      TrendDirection.down => AppConfig.errorColor,
      TrendDirection.neutral => AppConfig.neutral500,
    };

    if (widget.trendValue != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm,
          vertical: DesignTokens.spaceXs,
        ),
        decoration: BoxDecoration(
          color: hasGradient
              ? Colors.white.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: DesignTokens.iconSm,
              color: hasGradient
                  ? Colors.white.withValues(alpha: 0.9)
                  : color,
            ),
            DesignTokens.hSpaceXs,
            Text(
              widget.trendValue!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasGradient
                    ? Colors.white.withValues(alpha: 0.9)
                    : color,
              ),
            ),
          ],
        ),
      );
    }

    return Icon(
      iconData,
      size: DesignTokens.iconSm,
      color: hasGradient
          ? Colors.white.withValues(alpha: 0.7)
          : color,
    );
  }
}

/// Dirección de tendencia para indicadores
enum TrendDirection { up, down, neutral }
