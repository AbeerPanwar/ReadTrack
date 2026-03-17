import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';

// Providers
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref),
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

class AuthRepository {
  final Ref _ref;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  AuthRepository(this._ref);

  // ── Email/Password Register ──────────────────────────────
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _createUserDocument(
      uid: credential.user!.uid,
      email: email,
      username: username,
    );
    await credential.user!.updateDisplayName(username);
  }

  // ── Email/Password Login ─────────────────────────────────
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // ── Google Sign-In ───────────────────────────────────────
  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    final isNew = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (isNew) {
      await _createUserDocument(
        uid: user.uid,
        email: user.email ?? '',
        username: user.displayName ?? 'Reader',
        avatarUrl: user.photoURL ?? '',
      );
    }
  }

  // ── Sign Out ─────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Password Reset ───────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Create Firestore User Doc ────────────────────────────
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String username,
    String avatarUrl = '',
  }) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final exists = (await userDoc.get()).exists;
    if (!exists) {
      await userDoc.set(
        UserModel(
          uid: uid,
          username: username,
          email: email,
          avatarUrl: avatarUrl,
          joinedAt: DateTime.now(),
        ).toMap(),
      );
    }
  }

  // ── Get Current User Data ────────────────────────────────
  Future<UserModel?> getCurrentUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }
}
