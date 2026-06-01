import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/couple_provider.dart';

class ConnectedScreen extends ConsumerStatefulWidget {
  const ConnectedScreen({super.key});

  @override
  ConsumerState<ConnectedScreen> createState() => _ConnectedScreenState();
}

class _ConnectedScreenState extends ConsumerState<ConnectedScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    final ms = d.inMilliseconds.remainder(1000);

    return '${days.toString().padLeft(2, '0')}d ${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s ${ms.toString().padLeft(3, '0')}ms';
  }

  @override
  Widget build(BuildContext context) {
    final coupleAsync = ref.watch(currentCoupleProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return coupleAsync.when(
      data: (couple) {
        if (couple == null) return const SizedBox.shrink();

        final createdAt = couple.createdAt;
        final now = DateTime.now();
        final duration = now.difference(createdAt);
        final dateStr =
            '${createdAt.day}/${createdAt.month}/${createdAt.year}';

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: 72, color: gold),
              const SizedBox(height: 24),
              Text(
                'Tu vínculo está activo ❤️',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Conectados desde hace',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _formatDuration(duration),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: gold,
                      fontSize: 20,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Desde el $dateStr',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: gold,
                    ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Center(
        child: Text('Error al cargar vínculo'),
      ),
    );
  }
}
