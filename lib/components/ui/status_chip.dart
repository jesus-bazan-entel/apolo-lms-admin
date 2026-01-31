import 'package:flutter/material.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/design_tokens.dart';

/// Chip de estado para indicar estados de contenido
///
/// Incluye variantes predefinidas para estados comunes de LMS
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.status,
    this.icon,
    this.size = StatusChipSize.medium,
    this.showIcon = true,
  });

  final String label;
  final StatusType status;
  final IconData? icon;
  final StatusChipSize size;
  final bool showIcon;

  /// Factory para estado de borrador
  factory StatusChip.draft({String? label}) {
    return StatusChip(
      label: label ?? 'Borrador',
      status: StatusType.draft,
      icon: Icons.edit_outlined,
    );
  }

  /// Factory para estado pendiente
  factory StatusChip.pending({String? label}) {
    return StatusChip(
      label: label ?? 'Pendiente',
      status: StatusType.pending,
      icon: Icons.schedule_outlined,
    );
  }

  /// Factory para estado activo/publicado
  factory StatusChip.active({String? label}) {
    return StatusChip(
      label: label ?? 'Activo',
      status: StatusType.active,
      icon: Icons.check_circle_outlined,
    );
  }

  /// Factory para estado archivado
  factory StatusChip.archived({String? label}) {
    return StatusChip(
      label: label ?? 'Archivado',
      status: StatusType.archived,
      icon: Icons.archive_outlined,
    );
  }

  /// Factory para estado de error
  factory StatusChip.error({String? label}) {
    return StatusChip(
      label: label ?? 'Error',
      status: StatusType.error,
      icon: Icons.error_outline,
    );
  }

  /// Factory para estado gratuito
  factory StatusChip.free({String? label}) {
    return StatusChip(
      label: label ?? 'Gratis',
      status: StatusType.info,
      icon: Icons.card_giftcard_outlined,
    );
  }

  /// Factory para estado premium
  factory StatusChip.premium({String? label}) {
    return StatusChip(
      label: label ?? 'Premium',
      status: StatusType.premium,
      icon: Icons.workspace_premium_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(status);
    final effectiveIcon = icon ?? _getDefaultIcon(status);

    final padding = size == StatusChipSize.small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    final fontSize = size == StatusChipSize.small ? 11.0 : 13.0;
    final iconSize = size == StatusChipSize.small ? 14.0 : 16.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: DesignTokens.borderRadiusFull,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && effectiveIcon != null) ...[
            Icon(
              effectiveIcon,
              size: iconSize,
              color: colors.foreground,
            ),
            SizedBox(width: size == StatusChipSize.small ? 4 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: colors.foreground,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusColors _getStatusColors(StatusType status) {
    switch (status) {
      case StatusType.draft:
        return _StatusColors(
          background: AppConfig.neutral100,
          foreground: AppConfig.neutral600,
          border: AppConfig.neutral300,
        );
      case StatusType.pending:
        return _StatusColors(
          background: AppConfig.warningColor.withOpacity(0.1),
          foreground: AppConfig.warningColor,
          border: AppConfig.warningColor.withOpacity(0.3),
        );
      case StatusType.active:
        return _StatusColors(
          background: AppConfig.successColor.withOpacity(0.1),
          foreground: AppConfig.successColor,
          border: AppConfig.successColor.withOpacity(0.3),
        );
      case StatusType.archived:
        return _StatusColors(
          background: AppConfig.neutral200,
          foreground: AppConfig.neutral500,
          border: AppConfig.neutral300,
        );
      case StatusType.error:
        return _StatusColors(
          background: AppConfig.errorColor.withOpacity(0.1),
          foreground: AppConfig.errorColor,
          border: AppConfig.errorColor.withOpacity(0.3),
        );
      case StatusType.info:
        return _StatusColors(
          background: AppConfig.infoColor.withOpacity(0.1),
          foreground: AppConfig.infoColor,
          border: AppConfig.infoColor.withOpacity(0.3),
        );
      case StatusType.premium:
        return _StatusColors(
          background: AppConfig.accentColor.withOpacity(0.1),
          foreground: AppConfig.accentColor,
          border: AppConfig.accentColor.withOpacity(0.3),
        );
    }
  }

  IconData? _getDefaultIcon(StatusType status) {
    switch (status) {
      case StatusType.draft:
        return Icons.edit_outlined;
      case StatusType.pending:
        return Icons.schedule_outlined;
      case StatusType.active:
        return Icons.check_circle_outlined;
      case StatusType.archived:
        return Icons.archive_outlined;
      case StatusType.error:
        return Icons.error_outline;
      case StatusType.info:
        return Icons.info_outline;
      case StatusType.premium:
        return Icons.workspace_premium_outlined;
    }
  }
}

enum StatusType {
  draft,
  pending,
  active,
  archived,
  error,
  info,
  premium,
}

enum StatusChipSize { small, medium }

class _StatusColors {
  const _StatusColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

/// Chip de tipo de contenido (video, artículo, quiz)
class ContentTypeChip extends StatelessWidget {
  const ContentTypeChip({
    super.key,
    required this.type,
    this.size = StatusChipSize.medium,
  });

  final ContentType type;
  final StatusChipSize size;

  @override
  Widget build(BuildContext context) {
    final config = _getTypeConfig(type);

    final padding = size == StatusChipSize.small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    final fontSize = size == StatusChipSize.small ? 11.0 : 13.0;
    final iconSize = size == StatusChipSize.small ? 14.0 : 16.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: DesignTokens.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: iconSize,
            color: config.color,
          ),
          SizedBox(width: size == StatusChipSize.small ? 4 : 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _TypeConfig _getTypeConfig(ContentType type) {
    switch (type) {
      case ContentType.video:
        return _TypeConfig(
          label: 'Video',
          icon: Icons.play_circle_outline,
          color: AppConfig.errorColor,
        );
      case ContentType.article:
        return _TypeConfig(
          label: 'Artículo',
          icon: Icons.article_outlined,
          color: AppConfig.infoColor,
        );
      case ContentType.quiz:
        return _TypeConfig(
          label: 'Quiz',
          icon: Icons.quiz_outlined,
          color: AppConfig.accentColor,
        );
      case ContentType.audio:
        return _TypeConfig(
          label: 'Audio',
          icon: Icons.headphones_outlined,
          color: AppConfig.successColor,
        );
      case ContentType.document:
        return _TypeConfig(
          label: 'Documento',
          icon: Icons.description_outlined,
          color: AppConfig.warningColor,
        );
    }
  }
}

enum ContentType {
  video,
  article,
  quiz,
  audio,
  document,
}

class _TypeConfig {
  const _TypeConfig({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Chip de dificultad para cursos
class DifficultyChip extends StatelessWidget {
  const DifficultyChip({
    super.key,
    required this.level,
    this.size = StatusChipSize.medium,
  });

  final DifficultyLevel level;
  final StatusChipSize size;

  @override
  Widget build(BuildContext context) {
    final config = _getLevelConfig(level);

    final padding = size == StatusChipSize.small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    final fontSize = size == StatusChipSize.small ? 11.0 : 13.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: config.gradient,
        borderRadius: DesignTokens.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                Icons.star,
                size: size == StatusChipSize.small ? 10 : 12,
                color: index < config.stars
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          SizedBox(width: size == StatusChipSize.small ? 4 : 6),
          Text(
            config.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _LevelConfig _getLevelConfig(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return _LevelConfig(
          label: 'Principiante',
          stars: 1,
          gradient: LinearGradient(
            colors: [AppConfig.successColor, AppConfig.successColor.withGreen(200)],
          ),
        );
      case DifficultyLevel.intermediate:
        return _LevelConfig(
          label: 'Intermedio',
          stars: 2,
          gradient: LinearGradient(
            colors: [AppConfig.warningColor, AppConfig.warningColor.withRed(230)],
          ),
        );
      case DifficultyLevel.advanced:
        return _LevelConfig(
          label: 'Avanzado',
          stars: 3,
          gradient: LinearGradient(
            colors: [AppConfig.errorColor, AppConfig.errorColor.withRed(200)],
          ),
        );
    }
  }
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

class _LevelConfig {
  const _LevelConfig({
    required this.label,
    required this.stars,
    required this.gradient,
  });

  final String label;
  final int stars;
  final Gradient gradient;
}

/// Chip de progreso para estudiantes
class ProgressChip extends StatelessWidget {
  const ProgressChip({
    super.key,
    required this.progress,
    this.showLabel = true,
    this.size = StatusChipSize.medium,
  });

  /// Progreso de 0.0 a 1.0
  final double progress;
  final bool showLabel;
  final StatusChipSize size;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    final color = _getProgressColor(progress);

    final height = size == StatusChipSize.small ? 6.0 : 8.0;
    final width = size == StatusChipSize.small ? 60.0 : 80.0;
    final fontSize = size == StatusChipSize.small ? 11.0 : 13.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: DesignTokens.borderRadiusFull,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: DesignTokens.borderRadiusFull,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          DesignTokens.hSpaceSm,
          Text(
            '$percent%',
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppConfig.successColor;
    if (progress >= 0.7) return AppConfig.infoColor;
    if (progress >= 0.3) return AppConfig.warningColor;
    return AppConfig.neutral400;
  }
}
