import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkSession();
    return const AuthState();
  }

  Future<void> _checkSession() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(error: null);
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signIn(
        email: email,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(error: _formatError(e));
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      state = state.copyWith(error: null);
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(error: _formatError(e));
    }
  }

  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _formatError(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (msg.contains('Email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión';
    }
    if (msg.contains('User already registered')) {
      return 'El correo ya está registrado';
    }
    if (msg.contains('Password should be')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return msg;
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
