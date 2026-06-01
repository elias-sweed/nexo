import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'security_provider.dart';

enum LockState { unlocked, locked }

class LockNotifier extends Notifier<LockState> {
  @override
  LockState build() {
    return LockState.unlocked;
  }

  void lock() {
    state = LockState.locked;
  }

  void unlock() {
    state = LockState.unlocked;
  }

  void onAppResumed() {
    final settings = ref.read(securitySettingsProvider).value;
    if (settings != null && settings.biometricEnabled) {
      lock();
    }
  }
}

final lockStateProvider = NotifierProvider<LockNotifier, LockState>(
  LockNotifier.new,
);
