import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/couple/presentation/create_couple_screen.dart';
import '../../features/couple/presentation/join_couple_screen.dart';
import '../../features/journal/presentation/create_entry_screen.dart';
import '../../features/memories/presentation/create_memory_screen.dart';
import '../../features/memories/presentation/memory_detail_screen.dart';
import '../../features/future_letters/presentation/create_future_letter_screen.dart';
import '../../features/future_letters/presentation/letter_detail_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/security/presentation/lock_screen.dart';
import '../../features/security/presentation/security_settings_screen.dart';
import '../../features/security/providers/lock_provider.dart';

class _GoRouterNotifier extends ChangeNotifier {
  AuthState? authState;
  LockState lockState = LockState.unlocked;

  void updateAuth(AuthState state) {
    authState = state;
    notifyListeners();
  }

  void updateLock(LockState state) {
    lockState = state;
    notifyListeners();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _GoRouterNotifier();

  ref.listen(authStateProvider, (_, next) => notifier.updateAuth(next));
  ref.listen(lockStateProvider, (_, next) => notifier.updateLock(next));

  notifier.authState = ref.read(authStateProvider);

  final router = GoRouter(
    refreshListenable: notifier,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = notifier.authState;
      final lockState = notifier.lockState;
      final location = state.matchedLocation;

      if (authState == null || authState.status == AuthStatus.initial) return null;

      final isAuthPage = location == '/login' || location == '/register';
      final isSplash = location == '/splash';

      if (authState.isAuthenticated) {
        if (lockState == LockState.locked) {
          if (location != '/lock') return '/lock';
          return null;
        }

        if (isAuthPage || isSplash || location == '/lock') return '/home';
        return null;
      }

      if (isAuthPage) return null;
      return '/login';
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create-couple',
        builder: (context, state) => const CreateCoupleScreen(),
      ),
      GoRoute(
        path: '/join-couple',
        builder: (context, state) => const JoinCoupleScreen(),
      ),
      GoRoute(
        path: '/journal/create',
        builder: (context, state) => const CreateEntryScreen(),
      ),
      GoRoute(
        path: '/memories/create',
        builder: (context, state) => const CreateMemoryScreen(),
      ),
      GoRoute(
        path: '/memory/:id',
        builder: (context, state) => MemoryDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/future-letters/create',
        builder: (context, state) => const CreateFutureLetterScreen(),
      ),
      GoRoute(
        path: '/future-letter/:id',
        builder: (context, state) => LetterDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });

  return router;
});
