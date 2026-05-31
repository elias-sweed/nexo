import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_colors.dart';
import 'package:nexo/core/theme/app_theme.dart';
import '../providers/journal_provider.dart';
import 'journal_card.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(journalRealtimeProvider);

    final entriesAsync = ref.watch(journalEntriesProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return _EmptyState(gold: gold);
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 88),
            itemCount: entries.length,
            itemBuilder: (_, i) => JournalCard(entry: entries[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            'Error al cargar el diario',
            style: TextStyle(color: gold),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/journal/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Nueva entrada'),
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
            Icon(Icons.book_outlined, size: 72, color: gold),
            const SizedBox(height: 24),
            Text(
              'Aún no han escrito su\nprimera historia juntos.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: gold,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/journal/create'),
              icon: const Icon(Icons.edit),
              label: const Text('Crear primera entrada'),
            ),
          ],
        ),
      ),
    );
  }
}
