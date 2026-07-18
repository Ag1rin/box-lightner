import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/settings_model.dart';

final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('settingsBoxProvider must be overridden in main()');
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final Box _box;
  static const _key = 'app_settings';

  SettingsNotifier(this._box)
      : super(AppSettings.fromMap(_box.get(_key) as Map?));

  Future<void> _persist() async => _box.put(_key, state.toMap());

  Future<void> setAutoPronounce(bool value) async {
    state = state.copyWith(autoPronounce: value);
    await _persist();
  }

  Future<void> setSpeechRate(double value) async {
    state = state.copyWith(speechRate: value);
    await _persist();
  }

  Future<void> setHaptics(bool value) async {
    state = state.copyWith(hapticsEnabled: value);
    await _persist();
  }

  Future<void> setDailyGoal(int value) async {
    state = state.copyWith(dailyGoal: value);
    await _persist();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsBoxProvider));
});
