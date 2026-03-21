import 'package:cloud_firestore/cloud_firestore.dart';

class ReadingEntryModel {
  final String titleId;
  final String titleName;
  final String coverUrl;
  final String type;
  final String status;
  final int currentChapter;
  final int totalChapters;
  final int personalRating;
  final DateTime lastUpdated;
  final DateTime startedAt;
  final DateTime? completedAt;

  const ReadingEntryModel({
    required this.titleId,
    required this.titleName,
    required this.coverUrl,
    required this.type,
    required this.status,
    required this.currentChapter,
    required this.totalChapters,
    required this.personalRating,
    required this.lastUpdated,
    required this.startedAt,
    this.completedAt,
  });

  factory ReadingEntryModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReadingEntryModel(
      titleId: doc.id,
      titleName: d['titleName'] ?? '',
      coverUrl: d['coverUrl'] ?? '',
      type: d['type'] ?? 'manga',
      status: d['status'] ?? 'reading',
      currentChapter: d['currentChapter'] ?? 0,
      totalChapters: d['totalChapters'] ?? 0,
      personalRating: d['personalRating'] ?? 0,
      lastUpdated: (d['lastUpdated'] as Timestamp).toDate(),
      startedAt: (d['startedAt'] as Timestamp).toDate(),
      completedAt: d['completedAt'] != null
          ? (d['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'titleName': titleName,
    'coverUrl': coverUrl,
    'type': type,
    'status': status,
    'currentChapter': currentChapter,
    'totalChapters': totalChapters,
    'personalRating': personalRating,
    'lastUpdated': Timestamp.fromDate(lastUpdated),
    'startedAt': Timestamp.fromDate(startedAt),
    'completedAt': completedAt != null
        ? Timestamp.fromDate(completedAt!)
        : null,
  };

  ReadingEntryModel copyWith({
    String? status,
    int? currentChapter,
    int? personalRating,
    DateTime? completedAt,
  }) => ReadingEntryModel(
    titleId: titleId,
    titleName: titleName,
    coverUrl: coverUrl,
    type: type,
    status: status ?? this.status,
    currentChapter: currentChapter ?? this.currentChapter,
    totalChapters: totalChapters,
    personalRating: personalRating ?? this.personalRating,
    lastUpdated: DateTime.now(),
    startedAt: startedAt,
    completedAt: completedAt ?? this.completedAt,
  );
}
