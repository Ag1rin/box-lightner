import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../add_word/presentation/screens/add_word_screen.dart';
import '../../../word/presentation/providers/word_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(filteredWordsProvider);
    final filter = ref.watch(wordFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search English, Persian, or category',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (v) {
                  ref.read(wordFilterProvider.notifier).state =
                      filter.copyWith(query: v);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChip(
                      label: const Text('Favorites'),
                      selected: filter.favoritesOnly,
                      onSelected: (v) {
                        ref.read(wordFilterProvider.notifier).state =
                            filter.copyWith(favoritesOnly: v);
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: words.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'No words found',
                      message: 'Try a different search term or add a new word.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      itemCount: words.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final word = words[index];
                        return Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddWordScreen(word: word),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          word.english,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          word.persian,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors
                                          .boxColors[(word.box - 1).clamp(0, 4)]
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: Text(
                                      'Box ${word.box}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.boxColors[
                                            (word.box - 1).clamp(0, 4)],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      word.isFavorite
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: word.isFavorite
                                          ? AppColors.warning
                                          : AppColors.textTertiary,
                                    ),
                                    onPressed: () => ref
                                        .read(wordListProvider.notifier)
                                        .toggleFavorite(word.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
