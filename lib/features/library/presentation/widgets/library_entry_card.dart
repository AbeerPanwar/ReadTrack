import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/badge_chip.dart';
import '../../data/library_repository.dart';
import '../../domain/reading_entry_model.dart';

class LibraryEntryCard extends ConsumerWidget {
  final ReadingEntryModel entry;
  const LibraryEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = entry.totalChapters > 0
        ? entry.currentChapter / entry.totalChapters
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: entry.coverUrl,
              width: 70,
              height: 100,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 70,
                height: 100,
                color: AppColors.surfaceAlt,
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BadgeChip(type: entry.type),
                const SizedBox(height: 6),
                Text(
                  entry.titleName,
                  style: GoogleFonts.nunito(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Progress
                if (entry.status != 'plan_to_read') ...[
                  Text(
                    'Ch. ${entry.currentChapter} / ${entry.totalChapters}',
                    style: GoogleFonts.nunito(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.surfaceAlt,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.accent,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // Rating
                if (entry.personalRating > 0) ...[
                  RatingBarIndicator(
                    rating: entry.personalRating.toDouble(),
                    itemBuilder: (_, __) =>
                        const Icon(Icons.star, color: AppColors.accent),
                    itemCount: 5,
                    itemSize: 14,
                  ),
                  const SizedBox(height: 4),
                ],

                Text(
                  'Updated ${timeago.format(entry.lastUpdated)}',
                  style: GoogleFonts.nunito(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Quick chapter update
          if (entry.status == 'reading')
            Column(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.accent,
                  ),
                  onPressed: () async {
                    await ref
                        .read(libraryRepositoryProvider)
                        .updateProgress(
                          entry.titleId,
                          entry.currentChapter + 1,
                        );
                  },
                ),
                Text(
                  '+1 Ch',
                  style: GoogleFonts.nunito(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
