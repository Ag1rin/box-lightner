/// Centralized constants for the Lightner app.
class AppConstants {
  AppConstants._();

  static const String appName = 'Lightner';
  static const String wordsBoxName = 'words_box';
  static const String settingsBoxName = 'settings_box';
  static const String reviewHistoryBoxName = 'review_history_box';

  /// Number of Leitner boxes implemented in this app.
  static const int totalBoxes = 5;

  /// Review interval (in days) for each Leitner box, indexed [box - 1].
  static const Map<int, int> boxIntervalDays = {
    1: 1,
    2: 2,
    3: 4,
    4: 8,
    5: 16,
  };

  static const List<String> defaultCategories = [
    'General',
    'Business',
    'Travel',
    'Academic',
    'Idioms',
    'Technology',
    'Daily Life',
  ];

  static const List<String> difficultyLevels = ['Easy', 'Medium', 'Hard'];
}
