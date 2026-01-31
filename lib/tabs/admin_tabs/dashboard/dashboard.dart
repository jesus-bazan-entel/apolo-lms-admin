import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/design_tokens.dart';
import 'package:lms_admin/tabs/admin_tabs/dashboard/user_bar_chart.dart';
import 'package:lms_admin/mixins/course_mixin.dart';
import 'package:lms_admin/utils/reponsive.dart';
import 'package:lms_admin/components/ui/section_header.dart';
import 'dashboard_reviews.dart';
import 'dashboard_tile.dart';
import 'dashboard_providers.dart';
import 'dashboard_top_courses.dart';
import 'dashboard_users.dart';

/// Dashboard principal del sistema LMS
///
/// Muestra estadísticas clave, gráficos de usuarios,
/// cursos populares y reseñas recientes.
class Dashboard extends ConsumerWidget with CourseMixin {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space2xl),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header (datos se actualizan automáticamente en tiempo real)
          const PageHeader(
            title: 'Dashboard',
            subtitle: 'Resumen general del sistema',
          ),

          DesignTokens.vSpaceLg,

          // Stats Grid
          _buildStatsGrid(context, ref, theme),

          DesignTokens.vSpace2xl,

          // Charts and Data Sections
          _buildDataSections(context),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WidgetRef ref, ThemeData theme) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: DesignTokens.spaceLg,
        mainAxisSpacing: DesignTokens.spaceLg,
        crossAxisCount: Responsive.getCrossAxisCount(context),
        childAspectRatio: 2.5,
      ),
      children: [
        DashboardTile(
          info: 'Total Estudiantes',
          count: ref.watch(usersCountProvider).value ?? 0,
          icon: LineIcons.userGraduate,
          gradient: AppConfig.primaryGradient,
          trend: TrendDirection.up,
          trendValue: '+12%',
        ),
        DashboardTile(
          info: 'Estudiantes Activos',
          count: ref.watch(activeStudentsCountProvider).value ?? 0,
          icon: LineIcons.userCheck,
          bgColor: AppConfig.successColor,
          trend: TrendDirection.up,
          trendValue: '+8%',
        ),
        DashboardTile(
          info: 'Total Reseñas',
          count: ref.watch(reviewsCountProvider).value ?? 0,
          icon: LineIcons.starAlt,
          bgColor: AppConfig.primaryPurple,
          trend: TrendDirection.up,
          trendValue: '+15%',
        ),
        DashboardTile(
          info: 'Total Cursos',
          count: ref.watch(coursesCountProvider).value ?? 0,
          icon: LineIcons.book,
          gradient: AppConfig.accentGradient,
          trend: TrendDirection.up,
          trendValue: '+5%',
        ),
      ],
    );
  }

  Widget _buildDataSections(BuildContext context) {
    if (Responsive.isDesktopLarge(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: Column(
              children: [
                const UserBarChart(),
                DesignTokens.vSpaceLg,
                const DashboardReviews(),
              ],
            ),
          ),
          DesignTokens.hSpaceLg,
          Flexible(
            flex: 1,
            child: Column(
              children: [
                const DashboardUsers(),
                DesignTokens.vSpaceLg,
                const DashboardTopCourses(),
              ],
            ),
          ),
        ],
      );
    } else if (Responsive.isDesktop(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: Column(
              children: [
                const UserBarChart(),
                DesignTokens.vSpaceLg,
                const DashboardReviews(),
              ],
            ),
          ),
          DesignTokens.hSpaceLg,
          Flexible(
            flex: 1,
            child: Column(
              children: [
                const DashboardUsers(),
                DesignTokens.vSpaceLg,
                const DashboardTopCourses(),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const UserBarChart(),
          DesignTokens.vSpaceLg,
          const DashboardReviews(),
          DesignTokens.vSpaceLg,
          const DashboardUsers(),
          DesignTokens.vSpaceLg,
          const DashboardTopCourses(),
        ],
      );
    }
  }
}
