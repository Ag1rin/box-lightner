import '../constants/app_constants.dart';
import '../../features/word/data/word_model.dart';

/// Pure implementation of the Leitner spaced-repetition algorithm.
///
/// Rules:
/// - Correct answer  -> move to next box (capped at box 5), schedule the
///   next review using that box's interval.
/// - Incorrect answer -> move back to box 1, schedule for tomorrow.
class LeitnerAlgorithm {
  LeitnerAlgorithm._();

  static Word applyAnswer(Word word, {required bool wasCorrect}) {
    final now = DateTime.now();

    final int newBox = wasCorrect
        ? (word.box < AppConstants.totalBoxes ? word.box + 1 : word.box)
        : 1;

    final int intervalDays = AppConstants.boxIntervalDays[newBox] ?? 1;

    return word.copyWith(
      box: newBox,
      lastReviewed: now,
      nextReview: now.add(Duration(days: intervalDays)),
      reviewCount: word.reviewCount + 1,
      correctCount: wasCorrect ? word.correctCount + 1 : word.correctCount,
      wrongCount: wasCorrect ? word.wrongCount : word.wrongCount + 1,
    );
  }

  /// Words that are due for review today (nextReview <= now), sorted with
  /// the most overdue cards first.
  static List<Word> dueWords(List<Word> allWords) {
    final due = allWords.where((w) => w.isDueToday).toList();
    due.sort((a, b) => a.nextReview.compareTo(b.nextReview));
    return due;
  }

  static Map<int, List<Word>> groupByBox(List<Word> allWords) {
    final Map<int, List<Word>> boxes = {
      for (int i = 1; i <= AppConstants.totalBoxes; i++) i: [],
    };
    for (final w in allWords) {
      boxes.putIfAbsent(w.box, () => []).add(w);
    }
    return boxes;
  }
}
