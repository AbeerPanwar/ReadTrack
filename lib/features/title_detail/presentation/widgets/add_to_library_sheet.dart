import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../discover/domain/title_model.dart';
import '../../../library/data/library_repository.dart';
import '../../../library/domain/reading_entry_model.dart';

class AddToLibrarySheet extends ConsumerStatefulWidget {
  final TitleModel title;
  final ReadingEntryModel? existingEntry;

  const AddToLibrarySheet({super.key, required this.title, this.existingEntry});

  @override
  ConsumerState<AddToLibrarySheet> createState() => _AddToLibrarySheetState();
}

class _AddToLibrarySheetState extends ConsumerState<AddToLibrarySheet> {
  late String _selectedStatus;
  late int _currentChapter;
  late int _personalRating;
  bool _isLoading = false;

  final _statuses = [
    {'value': 'reading', 'label': 'Reading', 'icon': Icons.menu_book_rounded},
    {
      'value': 'completed',
      'label': 'Completed',
      'icon': Icons.check_circle_rounded,
    },
    {
      'value': 'on_hold',
      'label': 'On Hold',
      'icon': Icons.pause_circle_rounded,
    },
    {'value': 'dropped', 'label': 'Dropped', 'icon': Icons.cancel_rounded},
    {
      'value': 'plan_to_read',
      'label': 'Plan to Read',
      'icon': Icons.bookmark_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.existingEntry?.status ?? 'plan_to_read';
    _currentChapter = widget.existingEntry?.currentChapter ?? 0;
    _personalRating = widget.existingEntry?.personalRating ?? 0;
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;
    final repo = ref.read(libraryRepositoryProvider);

    final entry = ReadingEntryModel(
      titleId: widget.title.id,
      titleName: widget.title.title,
      coverUrl: widget.title.coverUrl,
      type: widget.title.type,
      status: _selectedStatus,
      currentChapter: _currentChapter,
      totalChapters: widget.title.totalChapters,
      personalRating: _personalRating,
      lastUpdated: DateTime.now(),
      startedAt: widget.existingEntry?.startedAt ?? DateTime.now(),
      completedAt: _selectedStatus == 'completed' ? DateTime.now() : null,
    );

    await repo.upsertEntry(entry);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _remove() async {
    await ref.read(libraryRepositoryProvider).removeEntry(widget.title.id);
    if (mounted) Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add to Library',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.title.title,
            style: GoogleFonts.nunito(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Status selector
          Text(
            'Status',
            style: GoogleFonts.nunito(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statuses.map((s) {
              final selected = _selectedStatus == s['value'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedStatus = s['value'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        s['icon'] as IconData,
                        size: 16,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s['label'] as String,
                        style: GoogleFonts.nunito(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Chapter progress
          if (_selectedStatus != 'plan_to_read') ...[
            Text(
              'Current Chapter: $_currentChapter / ${widget.title.totalChapters}',
              style: GoogleFonts.nunito(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _currentChapter > 0
                      ? () => setState(() => _currentChapter--)
                      : null,
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.accent,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _currentChapter.toDouble(),
                    min: 0,
                    max: widget.title.totalChapters.toDouble(),
                    divisions: widget.title.totalChapters > 0
                        ? widget.title.totalChapters
                        : 1,
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.surfaceAlt,
                    onChanged: (v) =>
                        setState(() => _currentChapter = v.toInt()),
                  ),
                ),
                IconButton(
                  onPressed: _currentChapter < widget.title.totalChapters
                      ? () => setState(() => _currentChapter++)
                      : null,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Personal rating
          Text(
            'Your Rating',
            style: GoogleFonts.nunito(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(
                  () => _personalRating = i + 1 == _personalRating ? 0 : i + 1,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    i < _personalRating ? Icons.star : Icons.star_border,
                    color: AppColors.accent,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              if (widget.existingEntry != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _remove,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Remove',
                      style: GoogleFonts.nunito(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (widget.existingEntry != null) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.existingEntry != null
                              ? 'Update'
                              : 'Add to Library',
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
