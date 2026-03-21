import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/badge_chip.dart';
import '../../domain/title_model.dart';

class TitleCard extends StatelessWidget {
  final TitleModel title;
  final VoidCallback? onTap;

  const TitleCard({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: title.coverUrl,
                width: 140,
                height: 190,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.surface,
                  highlightColor: AppColors.surfaceAlt,
                  child: Container(
                    width: 140,
                    height: 190,
                    color: AppColors.surface,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 140,
                  height: 190,
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.textSecondary,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            BadgeChip(type: title.type),
            const SizedBox(height: 4),
            Text(
              title.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                RatingBarIndicator(
                  rating: title.averageRating,
                  itemBuilder: (_, __) =>
                      const Icon(Icons.star, color: AppColors.accent),
                  itemCount: 5,
                  itemSize: 11,
                ),
                const SizedBox(width: 4),
                Text(
                  title.averageRating.toStringAsFixed(1),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
