import 'package:hive/hive.dart';

/// A single review event, used to power streaks, heatmaps and charts.
class ReviewHistoryEntry {
  final String id;
  final String wordId;
  final DateTime reviewedAt;
  final bool wasCorrect;
  final int boxBefore;
  final int boxAfter;

  const ReviewHistoryEntry({
    required this.id,
    required this.wordId,
    required this.reviewedAt,
    required this.wasCorrect,
    required this.boxBefore,
    required this.boxAfter,
  });
}

/// TypeId 1 is reserved for [ReviewHistoryEntry].
class ReviewHistoryAdapter extends TypeAdapter<ReviewHistoryEntry> {
  @override
  final int typeId = 1;

  @override
  ReviewHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewHistoryEntry(
      id: fields[0] as String,
      wordId: fields[1] as String,
      reviewedAt: fields[2] as DateTime,
      wasCorrect: fields[3] as bool,
      boxBefore: fields[4] as int,
      boxAfter: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewHistoryEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.wordId)
      ..writeByte(2)
      ..write(obj.reviewedAt)
      ..writeByte(3)
      ..write(obj.wasCorrect)
      ..writeByte(4)
      ..write(obj.boxBefore)
      ..writeByte(5)
      ..write(obj.boxAfter);
  }
}
