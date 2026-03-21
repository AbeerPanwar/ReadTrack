import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/review_model.dart';
import '../../discover/domain/title_model.dart';

final titleDetailRepositoryProvider = Provider<TitleDetailRepository>(
  (ref) => TitleDetailRepository(),
);

class TitleDetailRepository {
  final _db = FirebaseFirestore.instance;

  Future<TitleModel> getTitle(String titleId) async {
    final doc = await _db.collection('titles').doc(titleId).get();
    return TitleModel.fromFirestore(doc);
  }

  Future<List<ReviewModel>> getReviews(String titleId) async {
    final snap = await _db
        .collection('titles')
        .doc(titleId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snap.docs.map(ReviewModel.fromFirestore).toList();
  }

  Future<void> addReview({
    required String titleId,
    required ReviewModel review,
  }) async {
    final ref = _db
        .collection('titles')
        .doc(titleId)
        .collection('reviews')
        .doc();
    await ref.set(review.toMap());

    // Update average rating on the title
    await _recalculateRating(titleId);
  }

  Future<void> _recalculateRating(String titleId) async {
    final snap = await _db
        .collection('titles')
        .doc(titleId)
        .collection('reviews')
        .get();
    if (snap.docs.isEmpty) return;

    final ratings = snap.docs
        .map((d) => (d.data()['rating'] as int).toDouble())
        .toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    await _db.collection('titles').doc(titleId).update({
      'averageRating': double.parse(avg.toStringAsFixed(1)),
      'totalRatings': ratings.length,
    });
  }

  Future<List<TitleModel>> getSimilarTitles(
    String titleId,
    List<String> genres,
  ) async {
    final snap = await _db.collection('titles').get();
    return snap.docs
        .map(TitleModel.fromFirestore)
        .where(
          (t) => t.id != titleId && t.genres.any((g) => genres.contains(g)),
        )
        .take(8)
        .toList();
  }
}
