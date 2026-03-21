import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:read_track/features/discover/presentation/screens/discover_screen.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0F0F14),
    body: const Center(
      child: Text(
        '🎉 Phase 1 Complete!',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
  );
}

// Key fix: use a notifier so GoRouter re-evaluates on auth change
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthNotifier(ref);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier, // ← re-runs redirect on auth change
    redirect: (context, state) {
      final isLoggedIn = notifier.isLoggedIn;
      final isLoading = notifier.isLoading;
      final loc = state.matchedLocation;

      if (isLoading) return '/splash';

      if (isLoggedIn &&
          (loc == '/login' || loc == '/register' || loc == '/splash')) {
        return '/home';
      }
      if (!isLoggedIn && loc == '/home') {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const DiscoverScreen()),
    ],
  );
});

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, next) async {
      if (!next.isLoading) {
        // Wait 800ms before redirecting away from splash
        await Future.delayed(const Duration(milliseconds: 1500));
      }
      _isLoading = next.isLoading;
      _isLoggedIn = next.valueOrNull != null;
      notifyListeners();
    });
  }

  bool _isLoading = true;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
}
