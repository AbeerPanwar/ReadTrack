import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class BadgeChip extends StatelessWidget {
  final String type;
  const BadgeChip({super.key, required this.type});

  Color get _color => switch (type.toLowerCase()) {
    'novel' => AppColors.novel,
    'manga' => AppColors.manga,
    'manhwa' => AppColors.manhwa,
    'webtoon' => AppColors.webtoon,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        type.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
