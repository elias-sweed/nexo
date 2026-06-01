import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import 'security_provider.dart';

enum LockState { unlocked, locked }

class LockNotifier extends Notifier<LockState> {
  bool _isAuthenticating = false;

  @override
  LockState build() {
    return LockState.unlocked;
  }

  void setAuthenticating(bool value) {
    if (value) {
      _isAuthenticating = true;
    } else {
      // Small delay before clearing the flag to avoid race conditions 
      // with OS lifecycle events (like 'resumed' firing just after auth completes)
      Future.delayed(const Duration(milliseconds: 1000), () {
        _isAuthenticating = false;
      });
    }
  }

  void lock() {
    state = LockState.locked;
  }

  void unlock() {
    state = LockState.unlocked;
  }

  void onAppResumed() {
    if (_isAuthenticating) return;

    final authState = ref.read(authStateProvider);
    if (authState.status != AuthStatus.authenticated) return;

    final settings = ref.read(securitySettingsProvider).value;
    if (settings != null && settings.biometricEnabled) {
      lock();
    }
  }
  void onAppBackgrounded() {
    if (_isAuthenticating) return;

    final authState = ref.read(authStateProvider);
    if (authState.status != AuthStatus.authenticated) return;

    final settings = ref.read(securitySettingsProvider).value;
    if (settings != null && settings.biometricEnabled) {
      lock();
    }
  }
}

final lockStateProvider = NotifierProvider<LockNotifier, LockState>(
  LockNotifier.new,
);
