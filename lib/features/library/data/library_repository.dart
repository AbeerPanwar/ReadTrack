import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/reading_entry_model.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(),
);

class LibraryRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _library =>
      _db.collection('users').doc(_uid).collection('library');

  // Stream all entries for a given status
  Stream<List<ReadingEntryModel>> watchByStatus(String status) {
    return _library
        .where('status', isEqualTo: status)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReadingEntryModel.fromFirestore).toList());
  }

  // Add or update a library entry
  Future<void> upsertEntry(ReadingEntryModel entry) async {
    await _library.doc(entry.titleId).set(entry.toMap());
  }

  // Update progress only
  Future<void> updateProgress(String titleId, int chapter) async {
    await _library.doc(titleId).update({
      'currentChapter': chapter,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Update status
  Future<void> updateStatus(String titleId, String status) async {
    final update = {
      'status': status,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    };
    if (status == 'completed') {
      update['completedAt'] = Timestamp.fromDate(DateTime.now());
    }
    await _library.doc(titleId).update(update);
  }

  // Check if title is in library
  Future<ReadingEntryModel?> getEntry(String titleId) async {
    final doc = await _library.doc(titleId).get();
    return doc.exists ? ReadingEntryModel.fromFirestore(doc) : null;
  }

  // Remove from library
  Future<void> removeEntry(String titleId) async {
    await _library.doc(titleId).delete();
  }

  // Get all entries for stats
  Future<List<ReadingEntryModel>> getAllEntries() async {
    final snap = await _library.get();
    return snap.docs.map(ReadingEntryModel.fromFirestore).toList();
  }
}
