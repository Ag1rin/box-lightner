import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../statistics/presentation/providers/statistics_providers.dart';
import '../../../word/presentation/providers/word_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueWords = ref.watch(dueWordsProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final settings = ref.watch(settingsProvider);

    final goal = settings.dailyGoal;
    final progress = goal == 0 ? 0.0 : (stats.todayReviews / goal).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lightner',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 30,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ProgressRing(
                        progress: progress,
                        size: 108,
                        strokeWidth: 10,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${stats.todayReviews}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '/ $goal',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Progress",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              dueWords.isEmpty
                                  ? 'All caught up. Nice work!'
                                  : '${dueWords.length} cards due today',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department_rounded,
                                    color: AppColors.warning, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '${stats.streaks.current} day streak',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Learned Words',
                        value: '${stats.learnedWords}',
                        icon: Icons.check_circle_outline,
                        accentColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        label: 'Unknown Words',
                        value: '${stats.strugglingWords}',
                        icon: Icons.refresh_rounded,
                        accentColor: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: 'Quick Actions'),
                    const SizedBox(height: AppSpacing.xs),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.5,
                      children: [
                        QuickActionButton(
                          icon: Icons.play_circle_fill_rounded,
                          label: 'Start Review',
                          onTap: dueWords.isEmpty
                              ? () {}
                              : () => context.push('/review'),
                        ),
                        QuickActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Add Word',
                          onTap: () => context.push('/add-word'),
                        ),
                        QuickActionButton(
                          icon: Icons.bar_chart_rounded,
                          label: 'Statistics',
                          onTap: () => context.push('/statistics'),
                        ),
                        QuickActionButton(
                          icon: Icons.search_rounded,
                          label: 'Search',
                          onTap: () => context.push('/search'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-word'),
        icon: const Icon(Icons.add),
        label: const Text('Add Word'),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}
