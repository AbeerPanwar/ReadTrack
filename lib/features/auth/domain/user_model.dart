import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String avatarUrl;
  final String bio;
  final DateTime joinedAt;
  final List<String> favoriteGenres;
  final Map<String, dynamic>? readingChallenge;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.avatarUrl = '',
    this.bio = '',
    required this.joinedAt,
    this.favoriteGenres = const [],
    this.readingChallenge,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      bio: data['bio'] ?? '',
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? []),
      readingChallenge: data['readingChallenge'],
    );
  }

  Map<String, dynamic> toMap() => {
    'username': username,
    'email': email,
    'avatarUrl': avatarUrl,
    'bio': bio,
    'joinedAt': Timestamp.fromDate(joinedAt),
    'favoriteGenres': favoriteGenres,
    'readingChallenge': readingChallenge,
  };
}
