import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../future_letters/providers/future_letter_provider.dart';

class FutureLettersSummaryWidget extends ConsumerWidget {
  const FutureLettersSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(futureLettersSummaryProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()?.gold ?? AppColors.gold;

    if (summary.total == 0) {
      return _buildEmptyState(context, gold);
    }

    final hasReady = summary.hasReady;

    return GestureDetector(
      onTap: () {
        // We will just open the letters tab/screen in the parent via index, or push
        // Assuming the app has a way to navigate to future letters list
        // GoRouter usually allows pushing directly to the tab or the feature screen
        // For now, we will push to a dummy or assumed route. If there's a BottomNavBar,
        // tapping this might need to change the tab.
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: hasReady 
            ? LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: hasReady ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasReady ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasReady ? AppColors.primary : gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasReady ? Icons.mark_email_unread : Icons.mail_lock,
                color: hasReady ? Colors.white : gold,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasReady 
                      ? '¡${summary.unlocked} carta${summary.unlocked > 1 ? 's' : ''} lista${summary.unlocked > 1 ? 's' : ''} para abrir!' 
                      : '${summary.locked} carta${summary.locked > 1 ? 's' : ''} esperando el futuro',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasReady 
                      ? 'Toca para descubrir el mensaje' 
                      : 'El tiempo revelará el contenido',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color gold) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.mail_outline, color: gold.withValues(alpha: 0.5), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Escribe algo para el futuro y sorpréndanse más adelante.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
