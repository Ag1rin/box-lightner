/// Plain-old settings object persisted as primitives in a Hive box
/// (no custom adapter needed since Hive can store Map<String, dynamic>
/// of primitive types directly).
class AppSettings {
  final bool autoPronounce;
  final double speechRate; // 0.1 - 1.0
  final bool hapticsEnabled;
  final int dailyGoal;

  const AppSettings({
    this.autoPronounce = true,
    this.speechRate = 0.45,
    this.hapticsEnabled = true,
    this.dailyGoal = 20,
  });

  AppSettings copyWith({
    bool? autoPronounce,
    double? speechRate,
    bool? hapticsEnabled,
    int? dailyGoal,
  }) {
    return AppSettings(
      autoPronounce: autoPronounce ?? this.autoPronounce,
      speechRate: speechRate ?? this.speechRate,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  Map<String, dynamic> toMap() => {
        'autoPronounce': autoPronounce,
        'speechRate': speechRate,
        'hapticsEnabled': hapticsEnabled,
        'dailyGoal': dailyGoal,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const AppSettings();
    return AppSettings(
      autoPronounce: map['autoPronounce'] as bool? ?? true,
      speechRate: (map['speechRate'] as num?)?.toDouble() ?? 0.45,
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
      dailyGoal: map['dailyGoal'] as int? ?? 20,
    );
  }
}
