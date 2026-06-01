import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/lock_provider.dart';
import '../providers/security_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAuthenticating = false;
  bool _authFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _authenticate();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _authFailed = false;
    });

    ref.read(lockStateProvider.notifier).setAuthenticating(true);

    final biometricService = ref.read(biometricServiceProvider);
    final success = await biometricService.authenticate();

    if (!mounted) return;

    ref.read(lockStateProvider.notifier).setAuthenticating(false);

    setState(() {
      _isAuthenticating = false;
    });

    if (success) {
      ref.read(lockStateProvider.notifier).unlock();
    } else {
      setState(() {
        _authFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppThemeExtension>()?.gold ?? AppColors.gold;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _animation,
                child: Image.asset(
                  'assets/logo.png',
                  width: 150,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.favorite,
                    size: 100,
                    color: gold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'NEXO',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  letterSpacing: 8.0,
                  color: gold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tu espacio privado',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),

              if (_authFailed) ...[
                Text(
                  'No se pudo verificar la identidad',
                  style: TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 16),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : _authenticate,
                    icon: _isAuthenticating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.fingerprint, size: 24),
                    label: Text(_isAuthenticating ? 'Verificando...' : 'Desbloquear'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: gold.withValues(alpha: 0.2),
                      foregroundColor: gold,
                      side: BorderSide(color: gold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
