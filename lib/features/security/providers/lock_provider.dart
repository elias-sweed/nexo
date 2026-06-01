import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'security_provider.dart';

enum LockState { unlocked, locked }

class LockNotifier extends Notifier<LockState> {
  @override
  LockState build() {
    ref.listen(securitySettingsProvider, (prev, next) {
      final wasEnabled = prev?.value?.biometricEnabled ?? false;
      final isEnabled = next.value?.biometricEnabled ?? false;
      if (isEnabled && !wasEnabled) {
        state = LockState.locked;
      }
    });
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
    if (settings?.biometricEnabled == true) {
      state = LockState.locked;
    }
  }
}

final lockStateProvider = NotifierProvider<LockNotifier, LockState>(
  LockNotifier.new,
);
