import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/discover/presentation/screens/discover_screen.dart';
import 'features/library/presentation/screens/library_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthNotifier(ref);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = notifier.isLoggedIn;
      final isLoading = notifier.isLoading;
      final loc = state.matchedLocation;

      if (isLoading) return '/splash';
      if (isLoggedIn &&
          (loc == '/login' || loc == '/register' || loc == '/splash')) {
        return '/home';
      }
      if (!isLoggedIn && loc == '/home') return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const MainShell()),
    ],
  );
});

// Bottom nav shell
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [DiscoverScreen(), LibraryScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.surfaceAlt, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.nunito(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_bookmark_outlined),
              activeIcon: Icon(Icons.collections_bookmark),
              label: 'Library',
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, next) async {
      if (!next.isLoading) {
        await Future.delayed(const Duration(milliseconds: 800));
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
