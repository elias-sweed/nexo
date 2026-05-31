import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_colors.dart';
import 'package:nexo/core/theme/app_theme.dart';
import '../providers/memory_provider.dart';
import 'memory_card.dart';

class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: memoriesAsync.when(
        data: (memories) {
          if (memories.isEmpty) {
            return _EmptyState(gold: gold);
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: memories.length,
            itemBuilder: (_, i) => MemoryCard(
              memory: memories[i],
              onTap: () => context.push('/memory/${memories[i].id}'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            'Error al cargar recuerdos',
            style: TextStyle(color: gold),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/memories/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Crear recuerdo'),
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
            Icon(Icons.photo_library_outlined, size: 72, color: gold),
            const SizedBox(height: 24),
            Text(
              'Aquí comenzarán a guardar\nsu historia.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: gold,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/memories/create'),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Crear primer recuerdo'),
            ),
          ],
        ),
      ),
    );
  }
}
