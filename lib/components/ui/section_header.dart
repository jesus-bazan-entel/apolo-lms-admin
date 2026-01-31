import 'package:flutter/material.dart';
import 'package:lms_admin/configs/design_tokens.dart';

/// Encabezado de sección profesional con acciones opcionales
///
/// Usado para separar secciones en formularios y listas
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.actions,
    this.padding,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: DesignTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: DesignTokens.iconMd,
                  color: theme.colorScheme.primary,
                ),
                DesignTokens.hSpaceSm,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      DesignTokens.vSpaceXs,
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (actions != null && actions!.isNotEmpty) ...[
                DesignTokens.hSpaceMd,
                ...actions!,
              ],
            ],
          ),
          if (showDivider) ...[
            DesignTokens.vSpaceMd,
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

/// Grupo de campos de formulario con título
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.icon,
    this.isCollapsible = false,
    this.initiallyExpanded = true,
    this.padding,
  });

  final String title;
  final List<Widget> children;
  final String? subtitle;
  final IconData? icon;
  final bool isCollapsible;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isCollapsible) {
      return _CollapsibleSection(
        title: title,
        subtitle: subtitle,
        icon: icon,
        initiallyExpanded: initiallyExpanded,
        children: children,
      );
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: DesignTokens.borderRadiusMd,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceSm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: DesignTokens.borderRadiusSm,
                  ),
                  child: Icon(
                    icon,
                    size: DesignTokens.iconSm,
                    color: theme.colorScheme.primary,
                  ),
                ),
                DesignTokens.hSpaceMd,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      DesignTokens.vSpaceXs,
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          DesignTokens.vSpaceLg,
          ...children,
        ],
      ),
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  const _CollapsibleSection({
    required this.title,
    required this.children,
    this.subtitle,
    this.icon,
    this.initiallyExpanded = true,
  });

  final String title;
  final List<Widget> children;
  final String? subtitle;
  final IconData? icon;
  final bool initiallyExpanded;

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: DesignTokens.animNormal,
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: DesignTokens.curveStandard),
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: DesignTokens.borderRadiusMd,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: _isExpanded
                  ? const BorderRadius.vertical(
                      top: Radius.circular(DesignTokens.radiusMd),
                    )
                  : DesignTokens.borderRadiusMd,
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceLg),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.spaceSm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: DesignTokens.borderRadiusSm,
                        ),
                        child: Icon(
                          widget.icon,
                          size: DesignTokens.iconSm,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      DesignTokens.hSpaceMd,
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            DesignTokens.vSpaceXs,
                            Text(
                              widget.subtitle!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    RotationTransition(
                      turns: _iconTurns,
                      child: Icon(
                        Icons.expand_more,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          AnimatedCrossFade(
            duration: DesignTokens.animNormal,
            crossFadeState:
                _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceLg,
                0,
                DesignTokens.spaceLg,
                DesignTokens.spaceLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  DesignTokens.vSpaceMd,
                  ...widget.children,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de acciones para la parte superior de páginas
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.breadcrumbs,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final List<BreadcrumbItem>? breadcrumbs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          if (breadcrumbs != null && breadcrumbs!.isNotEmpty) ...[
            _Breadcrumbs(items: breadcrumbs!),
            DesignTokens.vSpaceMd,
          ],

          // Title row
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                DesignTokens.hSpaceMd,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      DesignTokens.vSpaceXs,
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                DesignTokens.hSpaceLg,
                Wrap(
                  spacing: DesignTokens.spaceSm,
                  children: actions!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class BreadcrumbItem {
  const BreadcrumbItem({
    required this.label,
    this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
}

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({required this.items});

  final List<BreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceSm),
              child: Icon(
                Icons.chevron_right,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          _BreadcrumbChip(
            item: items[i],
            isLast: i == items.length - 1,
          ),
        ],
      ],
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  const _BreadcrumbChip({
    required this.item,
    required this.isLast,
  });

  final BreadcrumbItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: isLast ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color,
      fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
    );

    if (item.onTap == null || isLast) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: 14, color: textStyle?.color),
            const SizedBox(width: 4),
          ],
          Text(item.label, style: textStyle),
        ],
      );
    }

    return InkWell(
      onTap: item.onTap,
      borderRadius: DesignTokens.borderRadiusSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceXs,
          vertical: DesignTokens.spaceXxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 14, color: textStyle?.color),
              const SizedBox(width: 4),
            ],
            Text(item.label, style: textStyle),
          ],
        ),
      ),
    );
  }
}
