import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/core/theme/app_colors.dart';
import 'package:nexo/core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/journal_entry.dart';

class JournalCard extends ConsumerWidget {
  final JournalEntry entry;

  const JournalCard({super.key, required this.entry});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (date == today) return 'Hoy, $time';
    if (date == yesterday) return 'Ayer, $time';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider.select((s) => s.user?.id));
    final isOwn = userId == entry.authorId;
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isOwn ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isOwn ? const Radius.circular(16) : Radius.zero,
                bottomRight: isOwn ? Radius.zero : const Radius.circular(16),
              ),
              border: Border.all(
                color: isOwn ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(entry.createdAt),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isOwn ? AppColors.primary : gold,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isOwn ? 'Tú' : (entry.authorName ?? 'Tu pareja'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: isOwn ? AppColors.primary : gold,
                ),
          ),
        ],
      ),
    );
  }
}
