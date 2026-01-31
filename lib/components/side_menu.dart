import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/components/idecap_logo.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/constants.dart';
import 'package:lms_admin/configs/design_tokens.dart';
import 'package:lms_admin/pages/home.dart';
import 'package:lms_admin/providers/auth_state_provider.dart';

final menuIndexProvider = StateProvider<int>((ref) => 0);

/// Menú lateral profesional con navegación animada
///
/// Muestra el menú de navegación principal con:
/// - Logo y nombre de la aplicación
/// - Items de menú con animación de selección
/// - Soporte para diferentes roles (admin/autor)
class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.scaffoldKey,
    required this.role,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final UserRoles role;

  @override
  Widget build(BuildContext context) {
    final bool isAuthor = role == UserRoles.author;

    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppConfig.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con Logo
              _buildHeader(context, isAuthor),

              // Divider decorativo
              _buildDivider(),

              DesignTokens.vSpaceLg,

              // Menu Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceMd,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: isAuthor ? menuListAuthor.length : menuList.length,
                  itemBuilder: (BuildContext context, int index) {
                    String title = isAuthor
                        ? menuListAuthor[index]![0]
                        : menuList[index]![0];
                    IconData icon = isAuthor
                        ? menuListAuthor[index]![1]
                        : menuList[index]![1];
                    return _SideMenuItem(
                      title: title,
                      icon: icon,
                      index: index,
                      scaffoldKey: scaffoldKey,
                    );
                  },
                ),
              ),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAuthor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: DesignTokens.space3xl,
        horizontal: DesignTokens.space2xl,
      ),
      child: Row(
        children: [
          // Logo IDECAP
          const IdecapLogoIcon(size: 44),
          DesignTokens.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConfig.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DesignTokens.vSpaceXs,
                Text(
                  isAuthor ? 'Panel de Autor' : 'Panel Admin',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space2xl),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space2xl),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.white.withValues(alpha: 0.4),
            size: DesignTokens.iconSm,
          ),
          DesignTokens.hSpaceSm,
          Text(
            'v1.0.5',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item individual del menú lateral
class _SideMenuItem extends ConsumerStatefulWidget {
  const _SideMenuItem({
    required this.title,
    required this.icon,
    required this.index,
    required this.scaffoldKey,
  });

  final String title;
  final IconData icon;
  final int index;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  ConsumerState<_SideMenuItem> createState() => _SideMenuItemState();
}

class _SideMenuItemState extends ConsumerState<_SideMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final menuIndex = ref.watch(menuIndexProvider);
    final bool selected = menuIndex == widget.index;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: DesignTokens.animFast,
        margin: const EdgeInsets.only(bottom: DesignTokens.spaceXs),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onTap(context, menuIndex),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            child: AnimatedContainer(
              duration: DesignTokens.animFast,
              constraints: const BoxConstraints(
                minHeight: DesignTokens.minTouchTarget,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceLg,
                vertical: DesignTokens.spaceMd,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                gradient: selected ? AppConfig.accentGradient : null,
                color: _isHovered && !selected
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.transparent,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppConfig.accentColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Icon container
                  AnimatedContainer(
                    duration: DesignTokens.animFast,
                    padding: const EdgeInsets.all(DesignTokens.spaceSm),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Icon(
                      widget.icon,
                      size: DesignTokens.iconMd,
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  DesignTokens.hSpaceMd,

                  // Title
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Selection indicator
                  if (selected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int currentIndex) {
    ref.read(menuIndexProvider.notifier).update((state) => widget.index);

    final bool shouldAnimate = _shouldAnimate(widget.index, currentIndex);
    final pageController = ref.read(pageControllerProvider.notifier).state;

    if (shouldAnimate) {
      pageController.animateToPage(
        widget.index,
        duration: DesignTokens.animNormal,
        curve: DesignTokens.curveStandard,
      );
    } else {
      pageController.jumpToPage(widget.index);
    }

    if (widget.scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  bool _shouldAnimate(int targetIndex, int currentIndex) {
    final diff = targetIndex - currentIndex;
    return diff.abs() <= 1;
  }
}
