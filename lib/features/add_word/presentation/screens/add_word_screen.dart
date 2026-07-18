import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../word/data/word_model.dart';
import '../../../word/presentation/providers/word_providers.dart';

/// Add or edit a single vocabulary word. Pass an existing [word] to edit.
class AddWordScreen extends ConsumerStatefulWidget {
  final Word? word;
  const AddWordScreen({super.key, this.word});

  @override
  ConsumerState<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends ConsumerState<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _englishCtrl;
  late final TextEditingController _persianCtrl;
  late final TextEditingController _exampleCtrl;
  late final TextEditingController _notesCtrl;
  late String _category;
  late String _difficulty;

  bool get _isEditing => widget.word != null;

  @override
  void initState() {
    super.initState();
    final w = widget.word;
    _englishCtrl = TextEditingController(text: w?.english ?? '');
    _persianCtrl = TextEditingController(text: w?.persian ?? '');
    _exampleCtrl = TextEditingController(text: w?.example ?? '');
    _notesCtrl = TextEditingController(text: w?.notes ?? '');
    _category = w?.category ?? AppConstants.defaultCategories.first;
    _difficulty = w?.difficulty ?? 'Medium';
  }

  @override
  void dispose() {
    _englishCtrl.dispose();
    _persianCtrl.dispose();
    _exampleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final notifier = ref.read(wordListProvider.notifier);

    if (_isEditing) {
      await notifier.updateWord(widget.word!.copyWith(
        english: _englishCtrl.text.trim(),
        persian: _persianCtrl.text.trim(),
        example: _exampleCtrl.text.trim(),
        category: _category,
        difficulty: _difficulty,
        notes: _notesCtrl.text.trim(),
      ));
    } else {
      await notifier.addWord(
        english: _englishCtrl.text.trim(),
        persian: _persianCtrl.text.trim(),
        example: _exampleCtrl.text.trim(),
        category: _category,
        difficulty: _difficulty,
        notes: _notesCtrl.text.trim(),
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Word' : 'Add Word'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _FieldLabel('English Word'),
              TextFormField(
                controller: _englishCtrl,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(hintText: 'e.g. Serendipity'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              _FieldLabel('Persian Translation'),
              TextFormField(
                controller: _persianCtrl,
                decoration: const InputDecoration(hintText: 'e.g. تصادف خوشایند'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              _FieldLabel('Example Sentence (optional)'),
              TextFormField(
                controller: _exampleCtrl,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Use it in a sentence'),
              ),
              const SizedBox(height: AppSpacing.md),
              _FieldLabel('Category'),
              _ChipSelector(
                options: AppConstants.defaultCategories,
                selected: _category,
                onSelected: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: AppSpacing.md),
              _FieldLabel('Difficulty'),
              _ChipSelector(
                options: AppConstants.difficultyLevels,
                selected: _difficulty,
                onSelected: (v) => setState(() => _difficulty = v),
              ),
              const SizedBox(height: AppSpacing.md),
              _FieldLabel('Notes (optional)'),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Anything else worth remembering'),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save Changes' : 'Add Word'),
              ),
              if (_isEditing) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(wordListProvider.notifier)
                        .deleteWord(widget.word!.id);
                    if (context.mounted) context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: const Text('Delete Word'),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: AppColors.accentSoft,
          backgroundColor: AppColors.surface,
          side: BorderSide(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }
}
