import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'features/word/data/review_history_model.dart';
import 'features/word/data/word_model.dart';
import 'features/word/presentation/providers/word_providers.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(WordAdapter());
  Hive.registerAdapter(ReviewHistoryAdapter());

  final wordsBox = await Hive.openBox<Word>(AppConstants.wordsBoxName);
  final historyBox = await Hive.openBox<ReviewHistoryEntry>(
    AppConstants.reviewHistoryBoxName,
  );
  final settingsBox = await Hive.openBox(AppConstants.settingsBoxName);

  runApp(
    ProviderScope(
      overrides: [
        wordsBoxProvider.overrideWithValue(wordsBox),
        historyBoxProvider.overrideWithValue(historyBox),
        settingsBoxProvider.overrideWithValue(settingsBox),
      ],
      child: const LightnerApp(),
    ),
  );
}

class LightnerApp extends StatelessWidget {
  const LightnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
