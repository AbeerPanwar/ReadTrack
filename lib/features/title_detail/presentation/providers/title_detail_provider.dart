import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/title_detail_repository.dart';
import '../../domain/review_model.dart';
import '../../../discover/domain/title_model.dart';

final titleProvider = FutureProvider.family<TitleModel, String>((ref, id) {
  return ref.watch(titleDetailRepositoryProvider).getTitle(id);
});

final reviewsProvider = FutureProvider.family<List<ReviewModel>, String>((
  ref,
  id,
) {
  return ref.watch(titleDetailRepositoryProvider).getReviews(id);
});

final similarTitlesProvider =
    FutureProvider.family<List<TitleModel>, Map<String, dynamic>>((ref, args) {
      return ref
          .watch(titleDetailRepositoryProvider)
          .getSimilarTitles(
            args['titleId'] as String,
            List<String>.from(args['genres'] as List),
          );
    });
