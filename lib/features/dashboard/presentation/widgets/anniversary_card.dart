import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/dashboard_providers.dart';

class AnniversaryCard extends ConsumerWidget {
  const AnniversaryCard({super.key});

  String _monthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(relationshipStatsProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()?.gold ?? AppColors.gold;

    if (stats.daysTogether == 0) return const SizedBox.shrink();

    final isToday = stats.daysUntilAnniversary == 0;
    final date = stats.nextAnniversary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isToday ? Icons.celebration : Icons.calendar_today,
              color: isToday ? Colors.white : gold,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? '¡Feliz Mesaniversario!' : 'Próximo Mesaniversario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isToday ? AppColors.primary : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isToday
                      ? 'Celebren este día especial juntos'
                      : '${date.day} de ${_monthName(date.month)} — faltan ${stats.daysUntilAnniversary} días',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
