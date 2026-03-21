import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/title_model.dart';

final discoverRepositoryProvider = Provider<DiscoverRepository>(
  (ref) => DiscoverRepository(),
);

class DiscoverFilter {
  final String? type;
  final List<String> genres;
  final String? status;
  final double minRating;

  const DiscoverFilter({
    this.type,
    this.genres = const [],
    this.status,
    this.minRating = 0,
  });

  bool get hasFilters =>
      type != null || genres.isNotEmpty || status != null || minRating > 0;
}

class DiscoverRepository {
  final _db = FirebaseFirestore.instance;

  // Trending titles
  Future<List<TitleModel>> getTrending() async {
    final snap = await _db
        .collection('titles')
        .where('trending', isEqualTo: true)
        .get();
    final results = snap.docs.map(TitleModel.fromFirestore).toList();
    // Sort client-side to avoid composite index requirement
    results.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return results.take(10).toList();
  }

  // New releases
  Future<List<TitleModel>> getNewReleases() async {
    final snap = await _db
        .collection('titles')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
    return snap.docs.map(TitleModel.fromFirestore).toList();
  }

  // Top rated
  Future<List<TitleModel>> getTopRated() async {
    final snap = await _db
        .collection('titles')
        .orderBy('averageRating', descending: true)
        .limit(20)
        .get();
    return snap.docs.map(TitleModel.fromFirestore).toList();
  }

  // Filtered search
  Future<List<TitleModel>> getFiltered(DiscoverFilter filter) async {
    // Fetch all then filter client-side
    final snap = await _db.collection('titles').get();
    var results = snap.docs.map(TitleModel.fromFirestore).toList();

    if (filter.type != null) {
      results = results.where((t) => t.type == filter.type).toList();
    }
    if (filter.genres.isNotEmpty) {
      results = results
          .where((t) => t.genres.any((g) => filter.genres.contains(g)))
          .toList();
    }
    if (filter.status != null) {
      results = results.where((t) => t.status == filter.status).toList();
    }
    if (filter.minRating > 0) {
      results = results
          .where((t) => t.averageRating >= filter.minRating)
          .toList();
    }

    results.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return results;
  }

  // Search by title
  Future<List<TitleModel>> search(String query) async {
    if (query.isEmpty) return [];
    // Fetch all and filter client-side for now
    final snap = await _db.collection('titles').get();
    final lower = query.toLowerCase();
    return snap.docs
        .map(TitleModel.fromFirestore)
        .where(
          (t) =>
              t.title.toLowerCase().contains(lower) ||
              t.author.toLowerCase().contains(lower) ||
              t.genres.any((g) => g.toLowerCase().contains(lower)),
        )
        .toList();
  }
}
