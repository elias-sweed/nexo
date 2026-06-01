import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/core/theme/app_colors.dart';
import 'package:nexo/core/theme/app_theme.dart';
import '../providers/future_letter_provider.dart';

class LetterDetailScreen extends ConsumerWidget {
  final String id;

  const LetterDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lettersAsync = ref.watch(futureLettersProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return lettersAsync.when(
      data: (letters) {
        final letter = letters.where((l) => l.id == id).firstOrNull;
        if (letter == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(),
            body: Center(
              child: Text('Carta no encontrada', style: TextStyle(color: gold)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text(letter.title)),
          body: letter.isUnlocked
              ? _UnlockedView(letter: letter, gold: gold)
              : _LockedView(letter: letter, gold: gold),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: Center(child: Text('Error', style: TextStyle(color: gold))),
      ),
    );
  }
}

class _LockedView extends StatelessWidget {
  final dynamic letter;
  final Color gold;

  const _LockedView({required this.letter, required this.gold});

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${dt.day} de ${months[dt.month]} de ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(Icons.lock, size: 40, color: gold),
            ),
            const SizedBox(height: 32),
            Text(
              letter.title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Se abre el ${_formatDate(letter.unlockDate)}',
                style: TextStyle(color: gold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Todavía no es momento de abrir esta carta.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockedView extends StatelessWidget {
  final dynamic letter;
  final Color gold;

  const _UnlockedView({required this.letter, required this.gold});

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${dt.day} de ${months[dt.month]} de ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.mail, size: 32, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            letter.title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Disponible',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Escrita el ${_formatDate(letter.createdAt)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12),
            ),
          ),
          if (letter.authorName != null) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                'por ${letter.authorName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: gold,
                      fontSize: 12,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 24),
          Text(
            letter.content ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
