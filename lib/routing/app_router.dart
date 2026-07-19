import 'package:go_router/go_router.dart';

import '../features/add_word/presentation/screens/add_word_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/review/presentation/screens/flashcard_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/statistics/presentation/screens/statistics_screen.dart';
import '../features/timer/timer_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/review',
      builder: (context, state) => const FlashcardScreen(),
    ),
    GoRoute(
      path: '/add-word',
      builder: (context, state) => const AddWordScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/timer',
      builder: (context, state) => const TimerScreen(),
    ),
  ],
);
