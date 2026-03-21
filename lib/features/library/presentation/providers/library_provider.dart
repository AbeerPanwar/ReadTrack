import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/library_repository.dart';
import '../../domain/reading_entry_model.dart';

final libraryByStatusProvider =
    StreamProvider.family<List<ReadingEntryModel>, String>((ref, status) {
      return ref.watch(libraryRepositoryProvider).watchByStatus(status);
    });

final libraryStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final entries = await ref.watch(libraryRepositoryProvider).getAllEntries();

  final completed = entries.where((e) => e.status == 'completed').length;
  final reading = entries.where((e) => e.status == 'reading').length;
  final onHold = entries.where((e) => e.status == 'on_hold').length;
  final dropped = entries.where((e) => e.status == 'dropped').length;
  final planToRead = entries.where((e) => e.status == 'plan_to_read').length;

  // Favorite genre from completed
  final genreCount = <String, int>{};
  for (final e in entries) {
    // We don't store genres in entry, so skip for now
  }

  final totalChapters = entries.fold<int>(
    0,
    (sum, e) => sum + e.currentChapter,
  );

  return {
    'total': entries.length,
    'completed': completed,
    'reading': reading,
    'onHold': onHold,
    'dropped': dropped,
    'planToRead': planToRead,
    'totalChapters': totalChapters,
  };
});
