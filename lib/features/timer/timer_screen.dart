import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../settings/presentation/providers/settings_providers.dart';

/// Lets the user turn on a daily local-notification reminder and pick
/// the time it fires at.
class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.surface,
            dialBackgroundColor: AppColors.surfaceElevated,
            hourMinuteColor: AppColors.surfaceElevated,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;

    await notifier.setReminder(enabled: true, time: picked);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Daily reminder set for ${picked.format(context)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final time = TimeOfDay(
      hour: settings.reminderHour,
      minute: settings.reminderMinute,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder Timer')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer_rounded,
                      color: AppColors.accent,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GestureDetector(
                    onTap: () => _pickTime(context, ref),
                    child: Text(
                      time.format(context),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    settings.reminderEnabled
                        ? 'You\'ll get a notification every day at this time.'
                        : 'Reminder is currently off.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: SwitchListTile(
                title: const Text('Daily reminder'),
                subtitle: const Text(
                  'Notify me to review my words every day',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                value: settings.reminderEnabled,
                onChanged: (value) => notifier.setReminder(enabled: value),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => _pickTime(context, ref),
              icon: const Icon(Icons.access_time_rounded),
              label: const Text('Change time'),
            ),
          ],
        ),
      ),
    );
  }
}
