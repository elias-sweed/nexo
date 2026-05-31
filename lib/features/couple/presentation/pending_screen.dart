import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/couple_provider.dart';

class PendingScreen extends ConsumerStatefulWidget {
  final String inviteCode;

  const PendingScreen({super.key, required this.inviteCode});

  @override
  ConsumerState<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends ConsumerState<PendingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.invalidate(currentCoupleProvider);
      ref.invalidate(pendingCodeProvider);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 64, color: gold),
            const SizedBox(height: 24),
            Text(
              'Esperando a tu\npersona especial',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Comparte este código para conectarse',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold),
              ),
              child: Text(
                widget.inviteCode,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: gold,
                      letterSpacing: 4,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: widget.inviteCode),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado')),
                  );
                },
                child: const Text('Copiar código'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'El vínculo se activará automáticamente\ncuando la otra persona ingrese este código',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
