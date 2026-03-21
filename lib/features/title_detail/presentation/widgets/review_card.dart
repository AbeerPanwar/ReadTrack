import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../domain/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accent.withOpacity(0.2),
                backgroundImage: review.avatarUrl.isNotEmpty
                    ? NetworkImage(review.avatarUrl)
                    : null,
                child: review.avatarUrl.isEmpty
                    ? Text(
                        review.username[0].toUpperCase(),
                        style: GoogleFonts.nunito(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.username,
                      style: GoogleFonts.nunito(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeago.format(review.createdAt),
                      style: GoogleFonts.nunito(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: review.rating.toDouble(),
                itemBuilder: (_, __) =>
                    const Icon(Icons.star, color: AppColors.accent),
                itemCount: 5,
                itemSize: 14,
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: GoogleFonts.nunito(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
