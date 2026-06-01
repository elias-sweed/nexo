import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/security/providers/lock_provider.dart';
import '../../features/security/providers/security_provider.dart';

class AppLifecycleHandler extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends ConsumerState<AppLifecycleHandler> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialLockState();
    });
  }

  Future<void> _checkInitialLockState() async {
    final authState = ref.read(authStateProvider);
    if (authState.status == AuthStatus.authenticated && ref.read(authStateProvider.notifier).isSessionRestore) {
      _checkColdStartLock();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(lockStateProvider.notifier).onAppResumed();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      ref.read(lockStateProvider.notifier).onAppBackgrounded();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (prev, next) {
      if (prev?.status == AuthStatus.initial && next.status == AuthStatus.authenticated) {
        if (ref.read(authStateProvider.notifier).isSessionRestore) {
          _checkColdStartLock();
        }
      }
    });

    return widget.child;
  }

  Future<void> _checkColdStartLock() async {
    final settings = await ref.read(securitySettingsProvider.future);
    if (settings.biometricEnabled) {
      ref.read(lockStateProvider.notifier).lock();
    }
  }
}
