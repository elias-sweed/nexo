import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../couple/presentation/connected_screen.dart';
import '../../couple/presentation/pending_screen.dart';
import '../../couple/providers/couple_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final coupleAsync = ref.watch(currentCoupleProvider);
    final pendingAsync = ref.watch(pendingCodeProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(user?.displayName ?? 'NEXO'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: gold),
            onPressed: () {
              ref.read(authStateProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: coupleAsync.when(
        data: (couple) {
          if (couple != null) return const ConnectedScreen();
          return pendingAsync.when(
            data: (code) {
              if (code != null) return PendingScreen(inviteCode: code);
              return _NoCoupleView(gold: gold);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
      ),
    );
  }
}

class _NoCoupleView extends StatelessWidget {
  final Color gold;

  const _NoCoupleView({required this.gold});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 72, color: gold),
            const SizedBox(height: 24),
            Text(
              'Conecta con tu\npersona especial',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea un vínculo o únete a uno existente',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/create-couple'),
                child: const Text('Crear vínculo'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/join-couple'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: gold,
                  side: BorderSide(color: gold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Unirme con código'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
