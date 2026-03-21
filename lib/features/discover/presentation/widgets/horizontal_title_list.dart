import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/title_model.dart';
import 'title_card.dart';

class HorizontalTitleList extends StatelessWidget {
  final AsyncValue<List<TitleModel>> titlesAsync;
  final Function(TitleModel)? onTap;

  const HorizontalTitleList({super.key, required this.titlesAsync, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: titlesAsync.when(
        loading: () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 5,
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: AppColors.surfaceAlt,
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error loading titles',
            style: TextStyle(color: AppColors.error),
          ),
        ),
        data: (titles) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: titles.length,
          itemBuilder: (_, i) => TitleCard(
            title: titles[i],
            onTap: onTap != null ? () => onTap!(titles[i]) : null,
          ),
        ),
      ),
    );
  }
}
