import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_colors.dart';
import 'package:nexo/core/theme/app_theme.dart';
import '../providers/future_letter_provider.dart';
import 'future_letter_card.dart';

class FutureLettersScreen extends ConsumerWidget {
  const FutureLettersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lettersAsync = ref.watch(futureLettersProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: lettersAsync.when(
        data: (letters) {
          if (letters.isEmpty) {
            return _EmptyState(gold: gold);
          }

          final unlocked = letters.where((l) => l.isUnlocked).toList();
          final locked = letters.where((l) => !l.isUnlocked).toList();

          return CustomScrollView(
            slivers: [
              if (unlocked.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Disponibles',
                    count: unlocked.length,
                    color: AppColors.primary,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => FutureLetterCard(
                      letter: unlocked[i],
                      onTap: () => context.push('/future-letter/${unlocked[i].id}'),
                    ),
                    childCount: unlocked.length,
                  ),
                ),
                if (locked.isNotEmpty) const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
              if (locked.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Esperando el futuro',
                    count: locked.length,
                    color: gold,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => FutureLetterCard(
                      letter: locked[i],
                      onTap: () => context.push('/future-letter/${locked[i].id}'),
                    ),
                    childCount: locked.length,
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text('Error al cargar cartas', style: TextStyle(color: gold)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/future-letters/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note),
        label: const Text('Nueva carta'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color gold;

  const _EmptyState({required this.gold});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 72, color: gold),
            const SizedBox(height: 24),
            Text(
              'Aún no han enviado\nmensajes al futuro.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: gold,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/future-letters/create'),
              icon: const Icon(Icons.edit_note),
              label: const Text('Escribir primera carta'),
            ),
          ],
        ),
      ),
    );
  }
}
