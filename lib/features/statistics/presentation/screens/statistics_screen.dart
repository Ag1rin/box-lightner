import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/statistics_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Words',
                    value: '${stats.totalWords}',
                    icon: Icons.menu_book_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    label: 'Success Rate',
                    value: '${(stats.successRate * 100).round()}%',
                    icon: Icons.trending_up_rounded,
                    accentColor: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Current Streak',
                    value: '${stats.streaks.current}d',
                    icon: Icons.local_fire_department_rounded,
                    accentColor: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    label: 'Longest Streak',
                    value: '${stats.streaks.longest}d',
                    icon: Icons.emoji_events_rounded,
                    accentColor: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionTitle(title: 'Cards per Leitner Box'),
            _BoxDistributionChart(boxCounts: stats.boxCounts),
            const SizedBox(height: AppSpacing.xl),
            const SectionTitle(title: 'Last 30 Days'),
            _ActivityBarChart(activity: stats.last30DaysActivity),
            const SizedBox(height: AppSpacing.xl),
            const SectionTitle(title: 'Review Heatmap'),
            _Heatmap(activity: stats.last30DaysActivity),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _BoxDistributionChart extends StatelessWidget {
  final Map<int, int> boxCounts;
  const _BoxDistributionChart({required this.boxCounts});

  @override
  Widget build(BuildContext context) {
    final total = boxCounts.values.fold<int>(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 140,
            width: 140,
            child: total == 0
                ? const Center(
                    child: Text('No data', style: TextStyle(color: AppColors.textTertiary)),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 32,
                      sections: [
                        for (int box = 1; box <= 5; box++)
                          if ((boxCounts[box] ?? 0) > 0)
                            PieChartSectionData(
                              value: (boxCounts[box] ?? 0).toDouble(),
                              color: AppColors.boxColors[box - 1],
                              title: '${boxCounts[box]}',
                              radius: 34,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int box = 1; box <= 5; box++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.boxColors[box - 1],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Box $box', style: const TextStyle(fontSize: 13)),
                        const Spacer(),
                        Text(
                          '${boxCounts[box] ?? 0}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityBarChart extends StatelessWidget {
  final Map<DateTime, int> activity;
  const _ActivityBarChart({required this.activity});

  @override
  Widget build(BuildContext context) {
    final entries = activity.entries.toList();
    final maxY = entries.map((e) => e.value).fold<int>(1, (a, b) => a > b ? a : b);

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, AppSpacing.md, 8, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: BarChart(
        BarChartData(
          maxY: (maxY + 1).toDouble(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            show: false,
          ),
          barTouchData: BarTouchData(enabled: true),
          barGroups: [
            for (int i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value.toDouble(),
                    color: AppColors.accent,
                    width: 5,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  final Map<DateTime, int> activity;
  const _Heatmap({required this.activity});

  @override
  Widget build(BuildContext context) {
    final entries = activity.entries.toList();
    final maxCount = entries.map((e) => e.value).fold<int>(1, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: entries.map((e) {
          final intensity = maxCount == 0 ? 0.0 : e.value / maxCount;
          return Tooltip(
            message: '${e.key.month}/${e.key.day}: ${e.value} reviews',
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: e.value == 0
                    ? AppColors.surfaceHigh
                    : AppColors.accent.withOpacity(0.25 + intensity * 0.75),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
