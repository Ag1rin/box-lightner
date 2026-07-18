import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import 'review_history_model.dart';
import 'word_model.dart';

/// Repository abstraction over the Hive-backed word store.
/// Keeps Hive specifics out of the presentation layer (Clean Architecture).
class WordRepository {
  final Box<Word> _wordsBox;
  final Box<ReviewHistoryEntry> _historyBox;
  final _uuid = const Uuid();

  WordRepository(this._wordsBox, this._historyBox);

  List<Word> getAll() => _wordsBox.values.toList();

  Word? getById(String id) => _wordsBox.get(id);

  Future<Word> addWord({
    required String english,
    required String persian,
    String example = '',
    String category = 'General',
    String difficulty = 'Medium',
    String notes = '',
  }) async {
    final now = DateTime.now();
    final word = Word(
      id: _uuid.v4(),
      english: english.trim(),
      persian: persian.trim(),
      example: example.trim(),
      category: category,
      difficulty: difficulty,
      notes: notes.trim(),
      box: 1,
      createdAt: now,
      nextReview: now,
    );
    await _wordsBox.put(word.id, word);
    return word;
  }

  Future<void> updateWord(Word word) async {
    await _wordsBox.put(word.id, word);
  }

  Future<void> deleteWord(String id) async {
    await _wordsBox.delete(id);
  }

  Future<void> toggleFavorite(String id) async {
    final w = _wordsBox.get(id);
    if (w != null) {
      await _wordsBox.put(id, w.copyWith(isFavorite: !w.isFavorite));
    }
  }

  Future<void> recordReview(Word before, Word after, bool wasCorrect) async {
    await _wordsBox.put(after.id, after);
    final entry = ReviewHistoryEntry(
      id: _uuid.v4(),
      wordId: after.id,
      reviewedAt: DateTime.now(),
      wasCorrect: wasCorrect,
      boxBefore: before.box,
      boxAfter: after.box,
    );
    await _historyBox.put(entry.id, entry);
  }

  List<ReviewHistoryEntry> getHistory() => _historyBox.values.toList();

  Future<void> resetProgress() async {
    final now = DateTime.now();
    for (final w in _wordsBox.values.toList()) {
      await _wordsBox.put(
        w.id,
        w.copyWith(
          box: 1,
          nextReview: now,
          reviewCount: 0,
          correctCount: 0,
          wrongCount: 0,
          lastReviewed: null,
        ),
      );
    }
    await _historyBox.clear();
  }

  /// Exports all words as a pretty-printed JSON string.
  String exportAsJson() {
    final list = _wordsBox.values.map((w) => w.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  /// Imports words from a JSON string (array of word objects). Existing
  /// words with the same id are overwritten; new ids are preserved.
  Future<int> importFromJson(String jsonStr) async {
    final decoded = jsonDecode(jsonStr) as List<dynamic>;
    int count = 0;
    for (final item in decoded) {
      final json = Map<String, dynamic>.from(item as Map);
      // Assign a fresh id if missing to avoid collisions across devices.
      json['id'] ??= _uuid.v4();
      final word = Word.fromJson(json);
      await _wordsBox.put(word.id, word);
      count++;
    }
    return count;
  }

  /// Simple CSV export: english,persian,example,category,difficulty,notes
  String exportAsCsv() {
    final buffer = StringBuffer();
    buffer.writeln('english,persian,example,category,difficulty,notes');
    for (final w in _wordsBox.values) {
      buffer.writeln([
        w.english,
        w.persian,
        w.example,
        w.category,
        w.difficulty,
        w.notes,
      ].map(_csvEscape).join(','));
    }
    return buffer.toString();
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<int> importFromCsv(String csvStr) async {
    final lines = csvStr.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return 0;
    int count = 0;
    // Skip header row.
    for (final line in lines.skip(1)) {
      final parts = line.split(',');
      if (parts.length < 2) continue;
      await addWord(
        english: parts[0],
        persian: parts[1],
        example: parts.length > 2 ? parts[2] : '',
        category: parts.length > 3 && parts[3].isNotEmpty
            ? parts[3]
            : AppConstants.defaultCategories.first,
        difficulty: parts.length > 4 && parts[4].isNotEmpty ? parts[4] : 'Medium',
        notes: parts.length > 5 ? parts[5] : '',
      );
      count++;
    }
    return count;
  }
}
