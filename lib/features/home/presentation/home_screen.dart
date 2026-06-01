import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_colors.dart';
import 'package:nexo/core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../couple/presentation/connected_screen.dart';
import '../../couple/presentation/pending_screen.dart';
import '../../couple/providers/couple_provider.dart';
import '../../journal/presentation/journal_screen.dart';
import '../../memories/presentation/memories_screen.dart';
import '../../future_letters/presentation/future_letters_screen.dart';
import '../../future_letters/providers/future_letter_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(user?.displayName ?? 'NEXO'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: gold),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Estás seguro de que quieres salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Cancelar', style: TextStyle(color: gold)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ref.read(authStateProvider.notifier).signOut();
                      },
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _VinculoTab(),
          _JournalTab(),
          _MemoriesTab(),
          _FutureLettersTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Vínculo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Diario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library),
            label: 'Recuerdos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Cartas',
          ),
        ],
      ),
    );
  }
}

class _VinculoTab extends ConsumerWidget {
  const _VinculoTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleAsync = ref.watch(currentCoupleProvider);
    final pendingAsync = ref.watch(pendingCodeProvider);
    final summary = ref.watch(futureLettersSummaryProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return coupleAsync.when(
      data: (couple) {
        if (couple != null) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const SizedBox(
                  height: 300,
                  child: ConnectedScreen(),
                ),
                if (summary.total > 0) ...[
                  const SizedBox(height: 8),
                  _LettersSummary(summary: summary, gold: gold),
                ],
              ],
            ),
          );
        }
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
    );
  }
}

class _LettersSummary extends ConsumerWidget {
  final FutureLettersSummary summary;
  final Color gold;

  const _LettersSummary({required this.summary, required this.gold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Switch to cartas tab - use the parent state
        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
        homeState?.switchToTab(3);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Icon(Icons.mail_outline, size: 32, color: gold),
                if (summary.hasReady)
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                summary.hasReady
                    ? '${summary.unlocked} carta${summary.unlocked > 1 ? 's' : ''} lista${summary.unlocked > 1 ? 's' : ''} para abrir'
                    : 'Tienen ${summary.locked} carta${summary.locked > 1 ? 's' : ''} esperando el futuro',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: gold,
                      fontSize: 14,
                    ),
              ),
            ),
            Icon(Icons.chevron_right, color: gold),
          ],
        ),
      ),
    );
  }
}

class _JournalTab extends ConsumerWidget {
  const _JournalTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(currentCoupleProvider).value;
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    if (couple == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book_outlined, size: 72, color: gold),
              const SizedBox(height: 24),
              Text(
                'Primero conecta con tu pareja',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ve a la pestaña Vínculo para crear o unirte a un vínculo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return const JournalScreen();
  }
}

class _MemoriesTab extends ConsumerWidget {
  const _MemoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(currentCoupleProvider).value;
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    if (couple == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined, size: 72, color: gold),
              const SizedBox(height: 24),
              Text(
                'Primero conecta con tu pareja',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ve a la pestaña Vínculo para crear o unirte a un vínculo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return const MemoriesScreen();
  }
}

class _FutureLettersTab extends ConsumerWidget {
  const _FutureLettersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(currentCoupleProvider).value;
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    if (couple == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mail_outline, size: 72, color: gold),
              const SizedBox(height: 24),
              Text(
                'Primero conecta con tu pareja',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ve a la pestaña Vínculo para crear o unirte a un vínculo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return const FutureLettersScreen();
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
