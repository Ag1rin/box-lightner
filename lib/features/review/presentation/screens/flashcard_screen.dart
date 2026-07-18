import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../word/data/word_model.dart';
import '../../../word/presentation/providers/word_providers.dart';
import '../providers/review_providers.dart';
import '../widgets/flip_card.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  String? _lastSpokenWordId;
  double _dragOffsetX = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final due = ref.read(dueWordsProvider);
      ref.read(reviewSessionProvider.notifier).start(due, shuffle: false);
    });
  }

  Future<void> _maybeAutoSpeak(Word? word) async {
    if (word == null) return;
    if (word.id == _lastSpokenWordId) return;
    final settings = ref.read(settingsProvider);
    if (!settings.autoPronounce) return;
    _lastSpokenWordId = word.id;
    await ref.read(ttsServiceProvider).speak(word.english, rate: settings.speechRate);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(reviewSessionProvider);
    final settings = ref.watch(settingsProvider);

    // Auto-pronounce whenever the current word changes.
    final current = session.currentWord;
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoSpeak(current));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: session.isFinished
            ? null
            : Text('Card ${session.position} / ${session.total}'),
      ),
      body: SafeArea(
        child: session.isFinished
            ? _SessionCompleteView(session: session)
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: session.total == 0
                            ? 0
                            : session.position / session.total,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceHigh,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.accent),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() => _dragOffsetX += details.delta.dx);
                        },
                        onHorizontalDragEnd: (details) {
                          final threshold = MediaQuery.of(context).size.width * 0.25;
                          if (_dragOffsetX.abs() > threshold) {
                            final wasCorrect = _dragOffsetX > 0;
                            _answer(wasCorrect);
                          }
                          setState(() => _dragOffsetX = 0);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          transform: Matrix4.translationValues(_dragOffsetX, 0, 0)
                            ..rotateZ(_dragOffsetX / 800),
                          transformAlignment: Alignment.center,
                          child: FlipCard(
                            isFlipped: session.isFlipped,
                            onTap: () =>
                                ref.read(reviewSessionProvider.notifier).flip(),
                            front: _CardFace(
                              child: _FrontContent(
                                word: current!,
                                onReplay: () => ref.read(ttsServiceProvider).speak(
                                      current.english,
                                      rate: settings.speechRate,
                                    ),
                              ),
                            ),
                            back: _CardFace(
                              child: _BackContent(word: current),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (session.isFlipped)
                      Row(
                        children: [
                          Expanded(
                            child: _AnswerButton(
                              label: "I Didn't Know",
                              icon: Icons.close_rounded,
                              color: AppColors.danger,
                              onTap: () => _answer(false),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _AnswerButton(
                              label: 'I Knew It',
                              icon: Icons.check_rounded,
                              color: AppColors.success,
                              onTap: () => _answer(true),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Tap the card to reveal the meaning',
                        style: const TextStyle(color: AppColors.textTertiary),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  void _answer(bool wasCorrect) {
    HapticFeedback.mediumImpact();
    _lastSpokenWordId = null;
    ref.read(reviewSessionProvider.notifier).answer(wasCorrect);
  }
}

class _CardFace extends StatelessWidget {
  final Widget child;
  const _CardFace({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _FrontContent extends StatelessWidget {
  final Word word;
  final VoidCallback onReplay;
  const _FrontContent({required this.word, required this.onReplay});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.boxColors[(word.box - 1).clamp(0, 4)].withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            'Box ${word.box}',
            style: TextStyle(
              color: AppColors.boxColors[(word.box - 1).clamp(0, 4)],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          word.english,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        IconButton.filledTonal(
          onPressed: onReplay,
          icon: const Icon(Icons.volume_up_rounded),
        ),
      ],
    );
  }
}

class _BackContent extends StatelessWidget {
  final Word word;
  const _BackContent({required this.word});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            word.persian,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
          if (word.example.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '"${word.example}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              Chip(label: Text(word.category)),
              Chip(label: Text(word.difficulty)),
            ],
          ),
          if (word.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              word.notes,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionCompleteView extends StatelessWidget {
  final ReviewSessionState session;
  const _SessionCompleteView({required this.session});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_rounded, size: 56, color: AppColors.accent),
            const SizedBox(height: AppSpacing.lg),
            Text(
              session.total == 0 ? 'Nothing to review' : 'Session complete!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (session.total > 0)
              Text(
                '${session.correctThisSession} correct · ${session.wrongThisSession} to review again',
                style: const TextStyle(color: AppColors.textSecondary),
              )
            else
              const Text(
                "You're all caught up. Come back later or add new words.",
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
