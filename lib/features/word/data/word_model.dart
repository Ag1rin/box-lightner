import 'package:hive/hive.dart';

/// Core vocabulary word entity persisted in Hive.
///
/// NOTE: This adapter is hand-written (instead of using build_runner +
/// hive_generator) so the project compiles immediately without a
/// code-generation step. If you prefer generated adapters, delete this
/// file's [WordAdapter] and annotate this class with @HiveType/@HiveField,
/// then run `flutter pub run build_runner build`.
class Word {
  final String id;
  final String english;
  final String persian;
  final String example;
  final String category;
  final String difficulty; // Easy | Medium | Hard
  final String notes;

  /// Current Leitner box, 1-5.
  final int box;

  final DateTime createdAt;
  final DateTime? lastReviewed;
  final DateTime nextReview;

  final int reviewCount;
  final int correctCount;
  final int wrongCount;

  final bool isFavorite;

  const Word({
    required this.id,
    required this.english,
    required this.persian,
    this.example = '',
    this.category = 'General',
    this.difficulty = 'Medium',
    this.notes = '',
    this.box = 1,
    required this.createdAt,
    this.lastReviewed,
    required this.nextReview,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.isFavorite = false,
  });

  /// A word is considered "learned" once it has graduated to the last box.
  bool get isLearned => box >= 5;

  /// A word is "unknown" if it has been reviewed at least once and its most
  /// recent trend is still sitting in the earliest boxes.
  bool get isStruggling => reviewCount > 0 && box <= 1 && wrongCount > 0;

  double get accuracy =>
      reviewCount == 0 ? 0 : correctCount / reviewCount.toDouble();

  bool get isDueToday => !nextReview.isAfter(DateTime.now());

  Word copyWith({
    String? id,
    String? english,
    String? persian,
    String? example,
    String? category,
    String? difficulty,
    String? notes,
    int? box,
    DateTime? createdAt,
    DateTime? lastReviewed,
    DateTime? nextReview,
    int? reviewCount,
    int? correctCount,
    int? wrongCount,
    bool? isFavorite,
  }) {
    return Word(
      id: id ?? this.id,
      english: english ?? this.english,
      persian: persian ?? this.persian,
      example: example ?? this.example,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      notes: notes ?? this.notes,
      box: box ?? this.box,
      createdAt: createdAt ?? this.createdAt,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'english': english,
        'persian': persian,
        'example': example,
        'category': category,
        'difficulty': difficulty,
        'notes': notes,
        'box': box,
        'createdAt': createdAt.toIso8601String(),
        'lastReviewed': lastReviewed?.toIso8601String(),
        'nextReview': nextReview.toIso8601String(),
        'reviewCount': reviewCount,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'isFavorite': isFavorite,
      };

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        id: json['id'] as String,
        english: json['english'] as String,
        persian: json['persian'] as String,
        example: json['example'] as String? ?? '',
        category: json['category'] as String? ?? 'General',
        difficulty: json['difficulty'] as String? ?? 'Medium',
        notes: json['notes'] as String? ?? '',
        box: json['box'] as int? ?? 1,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastReviewed: json['lastReviewed'] == null
            ? null
            : DateTime.parse(json['lastReviewed'] as String),
        nextReview: DateTime.parse(json['nextReview'] as String),
        reviewCount: json['reviewCount'] as int? ?? 0,
        correctCount: json['correctCount'] as int? ?? 0,
        wrongCount: json['wrongCount'] as int? ?? 0,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}

/// Hand-written Hive adapter. TypeId 0 is reserved for [Word].
class WordAdapter extends TypeAdapter<Word> {
  @override
  final int typeId = 0;

  @override
  Word read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Word(
      id: fields[0] as String,
      english: fields[1] as String,
      persian: fields[2] as String,
      example: fields[3] as String? ?? '',
      category: fields[4] as String? ?? 'General',
      difficulty: fields[5] as String? ?? 'Medium',
      notes: fields[6] as String? ?? '',
      box: fields[7] as int? ?? 1,
      createdAt: fields[8] as DateTime,
      lastReviewed: fields[9] as DateTime?,
      nextReview: fields[10] as DateTime,
      reviewCount: fields[11] as int? ?? 0,
      correctCount: fields[12] as int? ?? 0,
      wrongCount: fields[13] as int? ?? 0,
      isFavorite: fields[14] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Word obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.english)
      ..writeByte(2)
      ..write(obj.persian)
      ..writeByte(3)
      ..write(obj.example)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.box)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.lastReviewed)
      ..writeByte(10)
      ..write(obj.nextReview)
      ..writeByte(11)
      ..write(obj.reviewCount)
      ..writeByte(12)
      ..write(obj.correctCount)
      ..writeByte(13)
      ..write(obj.wrongCount)
      ..writeByte(14)
      ..write(obj.isFavorite);
  }
}
