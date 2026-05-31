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
import '../../features/auth/providers/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (authState.status == AuthStatus.initial) return null;

      final isAuthPage = location == '/login' || location == '/register';
      final isSplash = location == '/splash';

      if (authState.isAuthenticated) {
        if (isAuthPage || isSplash) return '/home';
        return null;
      }

      if (isAuthPage) return null;
      return '/login';
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create-couple',
        builder: (_, __) => const CreateCoupleScreen(),
      ),
      GoRoute(
        path: '/join-couple',
        builder: (_, __) => const JoinCoupleScreen(),
      ),
      GoRoute(
        path: '/journal/create',
        builder: (_, __) => const CreateEntryScreen(),
      ),
      GoRoute(
        path: '/memories/create',
        builder: (_, __) => const CreateMemoryScreen(),
      ),
      GoRoute(
        path: '/memory/:id',
        builder: (_, state) => MemoryDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
