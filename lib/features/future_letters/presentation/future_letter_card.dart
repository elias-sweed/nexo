import 'package:flutter/material.dart';
import 'package:nexo/core/theme/app_colors.dart';
import 'package:nexo/core/theme/app_theme.dart';
import '../domain/future_letter.dart';

class FutureLetterCard extends StatelessWidget {
  final FutureLetter letter;
  final VoidCallback onTap;

  const FutureLetterCard({super.key, required this.letter, required this.onTap});

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: letter.isUnlocked
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: letter.isUnlocked
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                letter.isUnlocked ? Icons.mail : Icons.lock_outline,
                color: letter.isUnlocked ? AppColors.primary : gold,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      letter.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      letter.isUnlocked
                          ? 'Disponible'
                          : 'Se abre el ${_formatDate(letter.unlockDate)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: letter.isUnlocked ? AppColors.primary : gold,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: letter.isUnlocked ? AppColors.primary : gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
