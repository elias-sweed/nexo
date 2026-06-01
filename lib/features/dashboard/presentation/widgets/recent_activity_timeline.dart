import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/activity_item.dart';
import '../../providers/dashboard_providers.dart';

class RecentActivityTimeline extends ConsumerWidget {
  const RecentActivityTimeline({super.key});

  IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.journal:
        return Icons.book;
      case ActivityType.memory:
        return Icons.photo_library;
      case ActivityType.futureLetter:
        return Icons.mail;
    }
  }

  Color _getColorForType(ActivityType type, Color gold) {
    switch (type) {
      case ActivityType.journal:
        return gold;
      case ActivityType.memory:
        return Colors.blueAccent;
      case ActivityType.futureLetter:
        return AppColors.primary;
    }
  }

  void _onTap(BuildContext context, ActivityItem item) {
    switch (item.type) {
      case ActivityType.journal:
        // Diario usually goes to a list, we don't have a detail page for journal yet in the router
        context.push('/home'); // Or whatever is appropriate
        break;
      case ActivityType.memory:
        context.push('/memory/${item.id}');
        break;
      case ActivityType.futureLetter:
        context.push('/future-letter/${item.id}');
        break;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    }
    return 'Hace ${difference.inDays} días';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(recentActivityProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()?.gold ?? AppColors.gold;

    if (activities.isEmpty) {
      return _buildEmptyState(context, gold);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Actividad Reciente',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.border,
              height: 1,
              indent: 56,
            ),
            itemBuilder: (context, index) {
              final item = activities[index];
              final iconColor = _getColorForType(item.type, gold);

              return ListTile(
                onTap: () => _onTap(context, item),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(item.type),
                    color: iconColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: gold.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, Color gold) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.timeline, color: gold.withValues(alpha: 0.5), size: 32),
          const SizedBox(height: 12),
          Text(
            'Aún no hay actividad reciente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
