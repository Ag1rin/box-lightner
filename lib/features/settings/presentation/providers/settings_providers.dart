import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../notification/notification_service.dart';
import '../../data/settings_model.dart';

final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('settingsBoxProvider must be overridden in main()');
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final Box _box;
  static const _key = 'app_settings';

  SettingsNotifier(this._box)
      : super(AppSettings.fromMap(_box.get(_key) as Map?)) {
    // Re-arm the OS-level alarm on every app start so a scheduled
    // reminder survives app restarts / device reboots.
    if (state.reminderEnabled) {
      NotificationService.instance.scheduleDaily(
        time: TimeOfDay(hour: state.reminderHour, minute: state.reminderMinute),
      );
    }
  }

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

  /// Enables/disables the daily reminder and (re)schedules or cancels the
  /// underlying local notification to match.
  Future<void> setReminder({
    required bool enabled,
    TimeOfDay? time,
  }) async {
    final hour = time?.hour ?? state.reminderHour;
    final minute = time?.minute ?? state.reminderMinute;

    state = state.copyWith(
      reminderEnabled: enabled,
      reminderHour: hour,
      reminderMinute: minute,
    );
    await _persist();

    if (enabled) {
      await NotificationService.instance.scheduleDaily(
        time: TimeOfDay(hour: hour, minute: minute),
      );
    } else {
      await NotificationService.instance.cancelDaily();
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsBoxProvider));
});
