import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String username;
  final String avatarUrl;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      username: d['username'] ?? 'Anonymous',
      avatarUrl: d['avatarUrl'] ?? '',
      rating: d['rating'] ?? 0,
      comment: d['comment'] ?? '',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'username': username,
    'avatarUrl': avatarUrl,
    'rating': rating,
    'comment': comment,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
