import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../word/presentation/providers/word_providers.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final wordNotifier = ref.read(wordListProvider.notifier);
    final repository = ref.read(wordRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _SectionCard(
              title: 'Pronunciation',
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-play pronunciation'),
                  subtitle:
                      const Text('Speak each word automatically when shown'),
                  value: settings.autoPronounce,
                  onChanged: settingsNotifier.setAutoPronounce,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text('Speech Rate',
                    style: TextStyle(color: AppColors.textSecondary)),
                Slider(
                  value: settings.speechRate,
                  min: 0.2,
                  max: 0.8,
                  divisions: 6,
                  label: settings.speechRate.toStringAsFixed(2),
                  onChanged: settingsNotifier.setSpeechRate,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionCard(
              title: 'Experience',
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Haptic feedback'),
                  value: settings.hapticsEnabled,
                  onChanged: settingsNotifier.setHaptics,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Daily goal'),
                  subtitle: Text('${settings.dailyGoal} cards / day'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: settings.dailyGoal > 5
                            ? () => settingsNotifier
                                .setDailyGoal(settings.dailyGoal - 5)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => settingsNotifier
                            .setDailyGoal(settings.dailyGoal + 5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionCard(
              title: 'Data',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.ios_share_rounded),
                  title: const Text('Export database (JSON)'),
                  onTap: () {
                    final json = repository.exportAsJson();
                    Share.share(json, subject: 'Lightner backup');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.table_chart_outlined),
                  title: const Text('Export database (CSV)'),
                  onTap: () {
                    final csv = repository.exportAsCsv();
                    Share.share(csv, subject: 'Lightner words (CSV)');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.file_upload_outlined),
                  title: const Text('Import words (JSON or CSV)'),
                  onTap: () => _importFile(context, wordNotifier),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restore_page_outlined),
                  title: const Text('Reset progress'),
                  subtitle: const Text('Moves all cards back to Box 1'),
                  onTap: () => _confirmReset(context, wordNotifier),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SectionCard(
              title: 'Privacy',
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    'Lightner runs fully offline. We do not collect, store, '
                    'or share any of your personal data — there is nothing '
                    'to protect because nothing ever leaves your device.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.wifi_off_rounded, color: AppColors.success),
                  title: Text('No internet access required'),
                  subtitle: Text(
                    'The app works completely offline. It never connects '
                    'to any server.',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.storage_rounded, color: AppColors.success),
                  title: Text('Everything stays on your device'),
                  subtitle: Text(
                    'Your words and review history are stored locally in '
                    'this app\'s private storage, not in any cloud.',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.no_accounts_rounded, color: AppColors.success),
                  title: Text('No account, no analytics, no ads'),
                  subtitle: Text(
                    'No sign-up, no tracking, no third-party SDKs collecting '
                    'usage data.',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.perm_device_information_rounded,
                      color: AppColors.success),
                  title: Text('No hidden permissions'),
                  subtitle: Text(
                    'The app does not access your contacts, location, '
                    'camera, microphone, or any other data it doesn\'t need.',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.ios_share_rounded, color: AppColors.success),
                  title: Text('You control your data'),
                  subtitle: Text(
                    'Exporting, importing, or resetting progress above only '
                    'happens when you choose to — nothing is sent anywhere.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SectionCard(
              title: 'About',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('Lightner'),
                  subtitle: Text(
                    'A premium, fully offline Leitner-system flashcard app. '
                    'No account, no internet, no ads — your data never leaves '
                    'this device. Made by Agrin 💙',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFile(
      BuildContext context, WordListNotifier notifier) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv'],
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final content = await File(path).readAsString();
    final isJson = path.toLowerCase().endsWith('.json');

    int count = 0;
    try {
      count = isJson
          ? await notifier.importJson(content)
          : await notifier.importCsv(content);
    } catch (_) {
      // Fall back to trying the other format if extension/content mismatch.
      try {
        count = isJson
            ? await notifier.importCsv(content)
            : await notifier.importJson(content);
      } catch (_) {
        count = 0;
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $count word(s)')),
      );
    }
  }

  void _confirmReset(BuildContext context, WordListNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Reset all progress?'),
        content: const Text(
          'Every word will be moved back to Box 1 and review history will be cleared. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.resetProgress();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
