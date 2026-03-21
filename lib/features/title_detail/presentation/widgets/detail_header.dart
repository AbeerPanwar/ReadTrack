import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/badge_chip.dart';
import '../../../discover/domain/title_model.dart';
import '../../../library/domain/reading_entry_model.dart';

class DetailHeader extends StatelessWidget {
  final TitleModel title;
  final ReadingEntryModel? libraryEntry;
  final VoidCallback onAddToLibrary;

  const DetailHeader({
    super.key,
    required this.title,
    required this.onAddToLibrary,
    this.libraryEntry,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Blurred background
            CachedNetworkImage(
              imageUrl: title.coverUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(color: AppColors.surface),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),

            // Cover + Info
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Cover image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: title.coverUrl,
                      width: 110,
                      height: 160,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 110,
                        height: 160,
                        color: AppColors.surface,
                        child: const Icon(Icons.menu_book_rounded,
                            color: AppColors.textSecondary, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BadgeChip(type: title.type),
                        const SizedBox(height: 8),
                        Text(
                          title.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title.author,
                          style: GoogleFonts.nunito(
                              color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          RatingBarIndicator(
                            rating: title.averageRating,
                            itemBuilder: (_, __) => const Icon(
                                Icons.star,
                                color: AppColors.accent),
                            itemCount: 5,
                            itemSize: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${title.averageRating} (${title.totalRatings})',
                            style: GoogleFonts.nunito(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ]),
                        const SizedBox(height: 10),

                        // Mini add to library button
                        GestureDetector(
                          onTap: onAddToLibrary,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: libraryEntry != null
                                  ? AppColors.accent
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: libraryEntry != null
                                    ? AppColors.accent
                                    : Colors.white30,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  libraryEntry != null
                                      ? Icons.check_rounded
                                      : Icons.add_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  libraryEntry != null
                                      ? libraryEntry!.status
                                          .replaceAll('_', ' ')
                                      : 'Add to Library',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}