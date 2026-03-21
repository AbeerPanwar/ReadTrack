import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class StatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Stats',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('${stats['total']}', 'Total'),
              _stat('${stats['completed']}', 'Completed'),
              _stat('${stats['reading']}', 'Reading'),
              _stat('${stats['totalChapters']}', 'Chapters'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.nunito(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
