import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:read_track/features/auth/data/auth_repository.dart';

// Auth state for form loading/error handling
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  const AuthState({this.isLoading = false, this.errorMessage});
  AuthState copyWith({bool? isLoading, String? errorMessage}) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState());

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref
          .read(authRepositoryProvider)
          .registerWithEmail(
            email: email,
            password: password,
            username: username,
          );
      state = const AuthState();
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFirebaseError(e.code),
      );
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref
          .read(authRepositoryProvider)
          .signInWithEmail(email: email, password: password);
      state = const AuthState();
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFirebaseError(e.code),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(authRepositoryProvider).signInWithGoogle();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google sign-in failed. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
  }

  String _mapFirebaseError(String code) => switch (code) {
    'email-already-in-use' => 'This email is already registered.',
    'invalid-email' => 'Please enter a valid email.',
    'weak-password' => 'Password must be at least 6 characters.',
    'user-not-found' => 'No account found with this email.',
    'wrong-password' => 'Incorrect password.',
    'too-many-requests' => 'Too many attempts. Try again later.',
    _ => 'Something went wrong. Please try again.',
  };
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
