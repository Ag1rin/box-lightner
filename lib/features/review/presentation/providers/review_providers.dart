import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/leitner_algorithm.dart';
import '../../../../core/utils/tts_service.dart';
import '../../../word/data/word_model.dart';
import '../../../word/presentation/providers/word_providers.dart';

final ttsServiceProvider = Provider<TtsService>((ref) => TtsService());

/// Immutable snapshot of an in-progress review session.
class ReviewSessionState {
  final List<Word> queue;
  final int currentIndex;
  final bool isFlipped;
  final int correctThisSession;
  final int wrongThisSession;

  const ReviewSessionState({
    this.queue = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.correctThisSession = 0,
    this.wrongThisSession = 0,
  });

  Word? get currentWord =>
      currentIndex < queue.length ? queue[currentIndex] : null;

  bool get isFinished => queue.isEmpty || currentIndex >= queue.length;

  int get total => queue.length;
  int get position => currentIndex + 1;

  ReviewSessionState copyWith({
    List<Word>? queue,
    int? currentIndex,
    bool? isFlipped,
    int? correctThisSession,
    int? wrongThisSession,
  }) {
    return ReviewSessionState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      correctThisSession: correctThisSession ?? this.correctThisSession,
      wrongThisSession: wrongThisSession ?? this.wrongThisSession,
    );
  }
}

class ReviewSessionNotifier extends StateNotifier<ReviewSessionState> {
  final Ref ref;

  ReviewSessionNotifier(this.ref) : super(const ReviewSessionState());

  void start(List<Word> words, {bool shuffle = false}) {
    final queue = List<Word>.from(words);
    if (shuffle) queue.shuffle();
    state = ReviewSessionState(queue: queue);
  }

  void flip() {
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  Future<void> answer(bool wasCorrect) async {
    final word = state.currentWord;
    if (word == null) return;

    final updated = LeitnerAlgorithm.applyAnswer(word, wasCorrect: wasCorrect);
    final repo = ref.read(wordRepositoryProvider);
    await repo.recordReview(word, updated, wasCorrect);
    ref.read(wordListProvider.notifier).refresh();

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      isFlipped: false,
      correctThisSession:
          wasCorrect ? state.correctThisSession + 1 : state.correctThisSession,
      wrongThisSession:
          wasCorrect ? state.wrongThisSession : state.wrongThisSession + 1,
    );
  }

  void reset() => state = const ReviewSessionState();
}

final reviewSessionProvider =
    StateNotifierProvider<ReviewSessionNotifier, ReviewSessionState>((ref) {
  return ReviewSessionNotifier(ref);
});
