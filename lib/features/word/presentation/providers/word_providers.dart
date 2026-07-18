import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/review_history_model.dart';
import '../../data/word_model.dart';
import '../../data/word_repository.dart';

/// Exposes the already-open Hive boxes. These are overridden in main()
/// with the real, opened boxes before the app runs.
final wordsBoxProvider = Provider<Box<Word>>((ref) {
  throw UnimplementedError('wordsBoxProvider must be overridden in main()');
});

final historyBoxProvider = Provider<Box<ReviewHistoryEntry>>((ref) {
  throw UnimplementedError('historyBoxProvider must be overridden in main()');
});

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(ref.watch(wordsBoxProvider), ref.watch(historyBoxProvider));
});

/// StateNotifier holding the live list of words, kept in sync with Hive.
class WordListNotifier extends StateNotifier<List<Word>> {
  final WordRepository _repository;

  WordListNotifier(this._repository) : super(_repository.getAll());

  void refresh() => state = _repository.getAll();

  Future<void> addWord({
    required String english,
    required String persian,
    String example = '',
    String category = 'General',
    String difficulty = 'Medium',
    String notes = '',
  }) async {
    await _repository.addWord(
      english: english,
      persian: persian,
      example: example,
      category: category,
      difficulty: difficulty,
      notes: notes,
    );
    refresh();
  }

  Future<void> updateWord(Word word) async {
    await _repository.updateWord(word);
    refresh();
  }

  Future<void> deleteWord(String id) async {
    await _repository.deleteWord(id);
    refresh();
  }

  Future<void> toggleFavorite(String id) async {
    await _repository.toggleFavorite(id);
    refresh();
  }

  Future<void> resetProgress() async {
    await _repository.resetProgress();
    refresh();
  }

  Future<int> importJson(String json) async {
    final n = await _repository.importFromJson(json);
    refresh();
    return n;
  }

  Future<int> importCsv(String csv) async {
    final n = await _repository.importFromCsv(csv);
    refresh();
    return n;
  }
}

final wordListProvider =
    StateNotifierProvider<WordListNotifier, List<Word>>((ref) {
  return WordListNotifier(ref.watch(wordRepositoryProvider));
});

/// Words due for review right now.
final dueWordsProvider = Provider<List<Word>>((ref) {
  final words = ref.watch(wordListProvider);
  final due = words.where((w) => w.isDueToday).toList()
    ..sort((a, b) => a.nextReview.compareTo(b.nextReview));
  return due;
});

/// Search + filter state for the word list / search screen.
class WordFilter {
  final String query;
  final String? category;
  final String? difficulty;
  final bool favoritesOnly;

  const WordFilter({
    this.query = '',
    this.category,
    this.difficulty,
    this.favoritesOnly = false,
  });

  WordFilter copyWith({
    String? query,
    String? category,
    bool clearCategory = false,
    String? difficulty,
    bool clearDifficulty = false,
    bool? favoritesOnly,
  }) {
    return WordFilter(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}

final wordFilterProvider =
    StateProvider<WordFilter>((ref) => const WordFilter());

final filteredWordsProvider = Provider<List<Word>>((ref) {
  final words = ref.watch(wordListProvider);
  final filter = ref.watch(wordFilterProvider);

  return words.where((w) {
    final q = filter.query.trim().toLowerCase();
    final matchesQuery = q.isEmpty ||
        w.english.toLowerCase().contains(q) ||
        w.persian.toLowerCase().contains(q) ||
        w.category.toLowerCase().contains(q);
    final matchesCategory =
        filter.category == null || w.category == filter.category;
    final matchesDifficulty =
        filter.difficulty == null || w.difficulty == filter.difficulty;
    final matchesFavorite = !filter.favoritesOnly || w.isFavorite;
    return matchesQuery && matchesCategory && matchesDifficulty && matchesFavorite;
  }).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

const List<String> categoryOptions = AppConstants.defaultCategories;
