import 'package:flutter/material.dart';

/// Design Tokens para ApoloLMS Admin Panel
///
/// Sistema de tokens de diseño basado en Material Design 3
/// con soporte para accesibilidad y touch targets móviles.
class DesignTokens {
  DesignTokens._();

  // ============================================
  // SPACING SCALE (Base: 4px)
  // ============================================

  /// Extra small spacing: 4px
  static const double spaceXxs = 2;

  /// Extra small spacing: 4px
  static const double spaceXs = 4;

  /// Small spacing: 8px
  static const double spaceSm = 8;

  /// Medium spacing: 12px
  static const double spaceMd = 12;

  /// Large spacing: 16px
  static const double spaceLg = 16;

  /// Extra large spacing: 20px
  static const double spaceXl = 20;

  /// 2x Extra large spacing: 24px
  static const double space2xl = 24;

  /// 3x Extra large spacing: 32px
  static const double space3xl = 32;

  /// 4x Extra large spacing: 48px
  static const double space4xl = 48;

  /// 5x Extra large spacing: 64px
  static const double space5xl = 64;

  // ============================================
  // TOUCH TARGETS (Mobile First)
  // ============================================

  /// Minimum touch target size (Material Design: 48dp)
  static const double minTouchTarget = 48.0;

  /// Icon button minimum size
  static const double iconButtonSize = 48.0;

  /// Small button minimum height
  static const double buttonHeightSm = 36.0;

  /// Medium button minimum height
  static const double buttonHeightMd = 44.0;

  /// Large button minimum height
  static const double buttonHeightLg = 52.0;

  /// Minimum spacing between touch targets
  static const double touchTargetSpacing = 8.0;

  // ============================================
  // BORDER RADIUS
  // ============================================

  /// No border radius
  static const double radiusNone = 0;

  /// Extra small radius: 4px
  static const double radiusXs = 4;

  /// Small radius: 8px
  static const double radiusSm = 8;

  /// Medium radius: 12px
  static const double radiusMd = 12;

  /// Large radius: 16px
  static const double radiusLg = 16;

  /// Extra large radius: 20px
  static const double radiusXl = 20;

  /// 2x Extra large radius: 24px
  static const double radius2xl = 24;

  /// Full/Pill radius
  static const double radiusFull = 9999;

  // ============================================
  // ANIMATION DURATIONS
  // ============================================

  /// Instant: 0ms
  static const Duration animInstant = Duration.zero;

  /// Extra fast: 100ms (micro-interactions)
  static const Duration animExtraFast = Duration(milliseconds: 100);

  /// Fast: 150ms (hover, focus states)
  static const Duration animFast = Duration(milliseconds: 150);

  /// Normal: 250ms (standard transitions)
  static const Duration animNormal = Duration(milliseconds: 250);

  /// Slow: 350ms (page transitions)
  static const Duration animSlow = Duration(milliseconds: 350);

  /// Extra slow: 500ms (complex animations)
  static const Duration animExtraSlow = Duration(milliseconds: 500);

  // ============================================
  // ANIMATION CURVES
  // ============================================

  /// Standard easing for most animations
  static const Curve curveStandard = Curves.easeInOut;

  /// Decelerate for entering elements
  static const Curve curveDecelerate = Curves.easeOut;

  /// Accelerate for exiting elements
  static const Curve curveAccelerate = Curves.easeIn;

  /// Emphasized for attention-grabbing
  static const Curve curveEmphasized = Curves.easeInOutCubic;

  // ============================================
  // OPACITY SCALE
  // ============================================

  /// Fully transparent
  static const double opacityTransparent = 0.0;

  /// Disabled state: 38%
  static const double opacityDisabled = 0.38;

  /// Hover overlay: 8%
  static const double opacityHover = 0.08;

  /// Focus overlay: 12%
  static const double opacityFocus = 0.12;

  /// Pressed overlay: 12%
  static const double opacityPressed = 0.12;

  /// Dragged overlay: 16%
  static const double opacityDragged = 0.16;

  /// Subtle background: 5%
  static const double opacitySubtle = 0.05;

  /// Light overlay: 10%
  static const double opacityLight = 0.10;

  /// Medium overlay: 20%
  static const double opacityMedium = 0.20;

  /// Fully opaque
  static const double opacityOpaque = 1.0;

  // ============================================
  // ELEVATION (Shadow Levels)
  // ============================================

  /// No elevation
  static const double elevationNone = 0;

  /// Level 1: Subtle shadow
  static const double elevation1 = 1;

  /// Level 2: Card shadow
  static const double elevation2 = 2;

  /// Level 3: Raised elements
  static const double elevation3 = 3;

  /// Level 4: Floating buttons
  static const double elevation4 = 4;

  /// Level 6: Navigation
  static const double elevation6 = 6;

  /// Level 8: Dialogs
  static const double elevation8 = 8;

  /// Level 12: Modals
  static const double elevation12 = 12;

  /// Level 16: Side sheets
  static const double elevation16 = 16;

  /// Level 24: Full screen dialogs
  static const double elevation24 = 24;

  // ============================================
  // ICON SIZES
  // ============================================

  /// Extra small icon: 16px
  static const double iconXs = 16;

  /// Small icon: 20px
  static const double iconSm = 20;

  /// Medium icon: 24px (default)
  static const double iconMd = 24;

  /// Large icon: 32px
  static const double iconLg = 32;

  /// Extra large icon: 48px
  static const double iconXl = 48;

  /// 2x Extra large icon: 64px
  static const double icon2xl = 64;

  // ============================================
  // LINE HEIGHTS
  // ============================================

  /// Tight line height: 1.25
  static const double lineHeightTight = 1.25;

  /// Normal line height: 1.5
  static const double lineHeightNormal = 1.5;

  /// Relaxed line height: 1.75
  static const double lineHeightRelaxed = 1.75;

  // ============================================
  // CONTENT WIDTHS
  // ============================================

  /// Small content width: 640px
  static const double contentWidthSm = 640;

  /// Medium content width: 768px
  static const double contentWidthMd = 768;

  /// Large content width: 1024px
  static const double contentWidthLg = 1024;

  /// Extra large content width: 1280px
  static const double contentWidthXl = 1280;

  /// 2x Extra large content width: 1536px
  static const double contentWidth2xl = 1536;

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Creates EdgeInsets with consistent spacing
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    return EdgeInsets.only(
      left: left ?? horizontal ?? 0,
      right: right ?? horizontal ?? 0,
      top: top ?? vertical ?? 0,
      bottom: bottom ?? vertical ?? 0,
    );
  }

  /// Creates a SizedBox for vertical spacing
  static SizedBox verticalSpace(double height) => SizedBox(height: height);

  /// Creates a SizedBox for horizontal spacing
  static SizedBox horizontalSpace(double width) => SizedBox(width: width);

  /// Common vertical spacers
  static const SizedBox vSpaceXs = SizedBox(height: spaceXs);
  static const SizedBox vSpaceSm = SizedBox(height: spaceSm);
  static const SizedBox vSpaceMd = SizedBox(height: spaceMd);
  static const SizedBox vSpaceLg = SizedBox(height: spaceLg);
  static const SizedBox vSpaceXl = SizedBox(height: spaceXl);
  static const SizedBox vSpace2xl = SizedBox(height: space2xl);
  static const SizedBox vSpace3xl = SizedBox(height: space3xl);

  /// Common horizontal spacers
  static const SizedBox hSpaceXs = SizedBox(width: spaceXs);
  static const SizedBox hSpaceSm = SizedBox(width: spaceSm);
  static const SizedBox hSpaceMd = SizedBox(width: spaceMd);
  static const SizedBox hSpaceLg = SizedBox(width: spaceLg);
  static const SizedBox hSpaceXl = SizedBox(width: spaceXl);
  static const SizedBox hSpace2xl = SizedBox(width: space2xl);
  static const SizedBox hSpace3xl = SizedBox(width: space3xl);

  /// Creates a BorderRadius with consistent values
  static BorderRadius borderRadius(double radius) => BorderRadius.circular(radius);

  /// Common border radius presets
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);
}
