import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/design_tokens.dart';
import 'package:lms_admin/models/chart_model.dart';
import 'package:lms_admin/services/firebase_service.dart';

final userStatsProvider = FutureProvider<List<ChartModel>>((ref) async {
  final int days = ref.read(usersStateDaysCount);
  final List<ChartModel> stats = await FirebaseService().getUserStats(days);
  return stats;
});

final usersStateDaysCount = StateProvider<int>((ref) => 7);

/// Gráfico de barras para estadísticas de usuarios
///
/// Muestra el registro de nuevos estudiantes por día
/// con soporte para diferentes períodos de tiempo.
class UserBarChart extends ConsumerWidget {
  const UserBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersStateRef = ref.watch(userStatsProvider);
    final selectedDays = ref.watch(usersStateDaysCount);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space2xl),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : AppConfig.cardColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: isDark ? AppConfig.darkBorder : AppConfig.neutral200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, ref, selectedDays, theme, isDark),
          DesignTokens.vSpace2xl,

          // Chart
          SizedBox(
            height: 280,
            child: usersStateRef.when(
              loading: () => _buildLoadingState(theme, isDark),
              error: (e, x) => _buildEmptyState(theme, isDark),
              skipError: true,
              data: (usersStat) {
                if (usersStat.isEmpty) {
                  return _buildEmptyState(theme, isDark);
                }
                return _buildChart(context, ref, usersStat, theme, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, int selectedDays,
      ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              decoration: BoxDecoration(
                gradient: AppConfig.primaryGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: const Icon(
                LineIcons.userPlus,
                color: Colors.white,
                size: DesignTokens.iconMd,
              ),
            ),
            DesignTokens.hSpaceMd,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registro de Estudiantes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DesignTokens.vSpaceXs,
                Text(
                  'Nuevos registros por día',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppConfig.neutral400 : AppConfig.neutral500,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Period selector
        Container(
          padding: const EdgeInsets.all(DesignTokens.spaceXs),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.neutral800 : AppConfig.neutral100,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Row(
            children: [
              _buildPeriodButton(context, ref, '7 días', 7, selectedDays == 7, isDark),
              _buildPeriodButton(context, ref, '30 días', 30, selectedDays == 30, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    int days,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(usersStateDaysCount.notifier).update((state) => days);
        ref.invalidate(userStatsProvider);
      },
      child: AnimatedContainer(
        duration: DesignTokens.animFast,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: DesignTokens.spaceSm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppConfig.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppConfig.themeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppConfig.neutral400 : AppConfig.neutral600),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
            strokeWidth: 3,
          ),
          DesignTokens.vSpaceMd,
          Text(
            'Cargando datos...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppConfig.neutral400 : AppConfig.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.space2xl),
            decoration: BoxDecoration(
              color: isDark ? AppConfig.neutral800 : AppConfig.neutral100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: isDark ? AppConfig.neutral500 : AppConfig.neutral400,
            ),
          ),
          DesignTokens.vSpaceLg,
          Text(
            'Sin datos disponibles',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppConfig.neutral300 : AppConfig.neutral600,
            ),
          ),
          DesignTokens.vSpaceXs,
          Text(
            'No hay registros en este período',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppConfig.neutral500 : AppConfig.neutral400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, WidgetRef ref,
      List<ChartModel> usersStat, ThemeData theme, bool isDark) {
    final double maxYvalue = _calculateMaxYValue(usersStat);

    return BarChart(
      BarChartData(
        maxY: maxYvalue,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: _getTouchData(context, usersStat),
        ),
        barGroups: _generateBarGroups(context, usersStat, maxYvalue, isDark),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxYvalue / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? AppConfig.neutral700 : AppConfig.neutral200,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: maxYvalue / 5,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: isDark ? AppConfig.neutral400 : AppConfig.neutral500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => _bottomTitles(value, ref, isDark),
            ),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _bottomTitles(double value, WidgetRef ref, bool isDark) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    String title = '';
    if (ref.watch(usersStateDaysCount) == 7) {
      title = DateFormat('EEE', 'es').format(date);
    } else {
      title = DateFormat('d').format(date);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppConfig.neutral400 : AppConfig.neutral500,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  BarTouchTooltipData _getTouchData(
      BuildContext context, List<ChartModel> usersStat) {
    return BarTouchTooltipData(
      tooltipPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceMd,
      ),
      getTooltipColor: (group) => AppConfig.themeColor,
      getTooltipItem: (groupData, groupIndex, rod, rodIndex) {
        final ChartModel model = usersStat[groupIndex];
        final String formattedDate =
            DateFormat('dd MMM yyyy', 'es').format(model.timestamp);

        return BarTooltipItem(
          '${rod.toY.toInt()} ',
          const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          children: [
            TextSpan(
              text: 'estudiantes',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const TextSpan(text: '\n'),
            TextSpan(
              text: formattedDate,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        );
      },
    );
  }

  List<BarChartGroupData> _generateBarGroups(
      BuildContext context, List<ChartModel> userStats, double maxY, bool isDark) {
    Map<DateTime, dynamic> groupedData = {};
    for (var registration in userStats) {
      DateTime day = DateTime(registration.timestamp.year,
          registration.timestamp.month, registration.timestamp.day);

      if (groupedData.containsKey(day)) {
        groupedData[day] = groupedData[day]! + registration.count;
      } else {
        groupedData[day] = registration.count;
      }
    }

    List<DateTime> sortedDays = groupedData.keys.toList()..sort();

    List<BarChartGroupData> barGroups = [];
    for (DateTime day in sortedDays) {
      int registrationsCount = groupedData[day] ?? 0;

      BarChartRodData rodData = BarChartRodData(
        toY: registrationsCount.toDouble(),
        width: 20,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
        gradient: LinearGradient(
          colors: [
            AppConfig.themeColor,
            AppConfig.primaryPurple,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: maxY,
          color: isDark ? AppConfig.neutral800 : AppConfig.neutral100,
        ),
      );

      BarChartGroupData groupData = BarChartGroupData(
        x: day.millisecondsSinceEpoch,
        barRods: [rodData],
      );

      barGroups.add(groupData);
    }

    return barGroups;
  }

  double _calculateMaxYValue(List<ChartModel> usersStat) {
    double maxYValue = 0;
    for (ChartModel model in usersStat) {
      if (model.count > maxYValue) {
        maxYValue = model.count.toDouble();
      }
    }
    maxYValue = maxYValue < 5 ? 10 : maxYValue + 5;
    return maxYValue;
  }
}
