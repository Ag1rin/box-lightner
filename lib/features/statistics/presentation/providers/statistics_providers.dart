import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../word/data/review_history_model.dart';
import '../../../word/presentation/providers/word_providers.dart';

class Streaks {
  final int current;
  final int longest;
  const Streaks(this.current, this.longest);
}

class DashboardStats {
  final int totalWords;
  final int learnedWords;
  final int strugglingWords;
  final double successRate;
  final Streaks streaks;
  final Map<int, int> boxCounts; // box -> count
  final int todayReviews;
  final Map<DateTime, int> last30DaysActivity; // day -> review count

  const DashboardStats({
    required this.totalWords,
    required this.learnedWords,
    required this.strugglingWords,
    required this.successRate,
    required this.streaks,
    required this.boxCounts,
    required this.todayReviews,
    required this.last30DaysActivity,
  });
}

DateTime _dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final words = ref.watch(wordListProvider);
  final history = ref.watch(wordRepositoryProvider).getHistory();

  final total = words.length;
  final learned = words.where((w) => w.isLearned).length;
  final struggling = words.where((w) => w.isStruggling).length;

  final totalReviews = history.length;
  final totalCorrect = history.where((h) => h.wasCorrect).length;
  final successRate = totalReviews == 0 ? 0.0 : totalCorrect / totalReviews;

  final boxCounts = <int, int>{for (int i = 1; i <= 5; i++) i: 0};
  for (final w in words) {
    boxCounts[w.box] = (boxCounts[w.box] ?? 0) + 1;
  }

  // Build a day -> reviewed set for streaks + heatmap.
  final Map<DateTime, int> activityByDay = {};
  for (final ReviewHistoryEntry h in history) {
    final day = _dayOnly(h.reviewedAt);
    activityByDay[day] = (activityByDay[day] ?? 0) + 1;
  }

  final today = _dayOnly(DateTime.now());
  final todayReviews = activityByDay[today] ?? 0;

  // Current streak: count consecutive days ending today (or yesterday if
  // today has no reviews yet) that have at least one review.
  int current = 0;
  DateTime cursor = activityByDay.containsKey(today)
      ? today
      : today.subtract(const Duration(days: 1));
  while (activityByDay.containsKey(cursor)) {
    current++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  // Longest streak across all recorded history.
  int longest = 0;
  if (activityByDay.isNotEmpty) {
    final days = activityByDay.keys.toList()..sort();
    int run = 1;
    longest = 1;
    for (int i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > longest) longest = run;
    }
  }

  // Last 30 days activity for the heatmap / bar chart.
  final Map<DateTime, int> last30 = {};
  for (int i = 29; i >= 0; i--) {
    final day = today.subtract(Duration(days: i));
    last30[day] = activityByDay[day] ?? 0;
  }

  return DashboardStats(
    totalWords: total,
    learnedWords: learned,
    strugglingWords: struggling,
    successRate: successRate,
    streaks: Streaks(current, longest),
    boxCounts: boxCounts,
    todayReviews: todayReviews,
    last30DaysActivity: last30,
  );
});
