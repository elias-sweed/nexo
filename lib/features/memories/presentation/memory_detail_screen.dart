import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/core/theme/app_colors.dart';
import 'package:nexo/core/theme/app_theme.dart';
import '../providers/memory_provider.dart';

class MemoryDetailScreen extends ConsumerWidget {
  final String id;

  const MemoryDetailScreen({super.key, required this.id});

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${dt.day} de ${months[dt.month]} de ${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoryAsync = ref.watch(memoryDetailProvider(id));
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return memoryAsync.when(
      data: (memory) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    memory.coverImageUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: AppColors.surface);
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.broken_image,
                          color: AppColors.textSecondary, size: 48),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: gold),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(memory.memoryDate),
                            style: TextStyle(color: gold, fontSize: 14),
                          ),
                        ],
                      ),
                      if (memory.creatorName != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: gold),
                            const SizedBox(width: 8),
                            Text(
                              'Creado por ${memory.creatorName}',
                              style: TextStyle(color: gold, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                      if (memory.description != null &&
                          memory.description!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 24),
                        Text(
                          memory.description!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Error al cargar el recuerdo',
              style: TextStyle(color: gold)),
        ),
      ),
    );
  }
}
