# Lightner

A premium, fully offline Leitner-system flashcard app for learning English
vocabulary, built with Flutter, Riverpod, and Hive.

## Getting started

```bash
flutter pub get
flutter run
```

No further code-generation step is required — the Hive `TypeAdapter`s in
this project are hand-written (see the note below) instead of generated,
so there's nothing to run beyond `pub get`.

On iOS/Android, `flutter_tts` uses the OS's built-in, on-device speech
engine, so pronunciation works fully offline as long as the `en-US` voice
is installed (it is on virtually all devices out of the box).

## Architecture

Clean Architecture, feature-first:

```
lib/
  core/            # theme, constants, shared widgets, Leitner algorithm, TTS
  features/
    word/          # Word model, Hive adapter, repository, providers
    review/        # Flashcard screen, flip animation, review session state
    home/          # Home dashboard
    add_word/      # Add / edit word form
    search/        # Instant search + filters
    statistics/    # Dashboard, charts, streaks, heatmap
    settings/      # Settings, backup/restore, import/export
    splash/        # Animated splash screen
  routing/         # go_router configuration
```

- **State management:** Riverpod (`StateNotifierProvider` for mutable
  collections/sessions, plain `Provider` for derived/computed data such as
  due-today words and dashboard statistics).
- **Persistence:** Hive boxes for words, review history, and settings —
  all fully local, no cloud, no accounts.
- **Leitner logic:** `core/utils/leitner_algorithm.dart` is a small, pure,
  fully unit-testable module implementing the 5-box interval system
  described in the spec (1 / 2 / 4 / 8 / 16 days).

### Why hand-written Hive adapters instead of Freezed + build_runner?

The original spec calls for Freezed and `json_serializable`. Those need a
`build_runner` code-generation pass before the app will compile. To keep
this project buildable the moment you run `flutter pub get` (no generation
step, no risk of stale generated files), the `Word` and
`ReviewHistoryEntry` models are written by hand with manual
`copyWith`/`toJson`/`fromJson` and a manual `TypeAdapter`. If you'd rather
use Freezed, it's a straightforward swap — the public API of `Word` was
kept intentionally simple to make that migration easy later.

## What's implemented

- Full Leitner 5-box algorithm with automatic scheduling.
- Home dashboard: progress ring, due-today count, streak, quick actions.
- Flashcard review: auto-pronunciation on card entry, tap-to-flip 3D
  animation, replay button, swipe left/right (or buttons) to answer,
  haptic feedback.
- Add / edit / delete words, categories, difficulty, notes, favorites.
- Instant search with favorites filter.
- Statistics dashboard: totals, success rate, streaks, per-box pie chart,
  30-day activity bar chart, review heatmap.
- Settings: auto-pronounce toggle, speech rate, daily goal, haptics,
  JSON/CSV export (share sheet), JSON/CSV import (file picker), reset
  progress.
- Pure dark, Apple/Notion/Linear-inspired visual language with a single
  accent color, rounded corners, and 60fps built-in Flutter animations.

## What's intentionally out of scope for this first pass

A few "bonus" items from the spec were left as good follow-ups rather than
built now, to keep the delivered code reviewable and correct:

- Local scheduled review-reminder notifications (would need
  `flutter_local_notifications` + platform permission wiring).
- Achievements/badges system.
- Onboarding flow (the app currently opens straight to an animated splash
  → Home).
- Word tags (separate from category) and review-history detail screen.

All of these slot cleanly into the existing architecture (new
`features/<name>` folder + provider) if you'd like them added.
