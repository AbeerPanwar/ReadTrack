import 'package:cloud_firestore/cloud_firestore.dart';

class TitleModel {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String type; // novel | manga | manhwa | webtoon
  final List<String> genres;
  final String synopsis;
  final String status; // ongoing | completed | hiatus
  final int totalChapters;
  final int releaseYear;
  final double averageRating;
  final int totalRatings;
  final bool trending;
  final DateTime createdAt;

  const TitleModel({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.type,
    required this.genres,
    required this.synopsis,
    required this.status,
    required this.totalChapters,
    required this.releaseYear,
    required this.averageRating,
    required this.totalRatings,
    required this.trending,
    required this.createdAt,
  });

  factory TitleModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TitleModel(
      id: doc.id,
      title: d['title'] ?? '',
      author: d['author'] ?? '',
      coverUrl: d['coverUrl'] ?? '',
      type: d['type'] ?? 'manga',
      genres: List<String>.from(d['genres'] ?? []),
      synopsis: d['synopsis'] ?? '',
      status: d['status'] ?? 'ongoing',
      totalChapters: d['totalChapters'] ?? 0,
      releaseYear: d['releaseYear'] ?? 2020,
      averageRating: (d['averageRating'] ?? 0.0).toDouble(),
      totalRatings: d['totalRatings'] ?? 0,
      trending: d['trending'] ?? false,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'author': author,
    'coverUrl': coverUrl,
    'type': type,
    'genres': genres,
    'synopsis': synopsis,
    'status': status,
    'totalChapters': totalChapters,
    'releaseYear': releaseYear,
    'averageRating': averageRating,
    'totalRatings': totalRatings,
    'trending': trending,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
