import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/couple_provider.dart';

class CreateCoupleScreen extends ConsumerStatefulWidget {
  const CreateCoupleScreen({super.key});

  @override
  ConsumerState<CreateCoupleScreen> createState() => _CreateCoupleScreenState();
}

class _CreateCoupleScreenState extends ConsumerState<CreateCoupleScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _create() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authUser = ref.read(authStateProvider).user;
      if (authUser == null) return;

      final repo = ref.read(coupleRepositoryProvider);
      final code = await repo.createCouple(authUser.id);

      Clipboard.setData(ClipboardData(text: code));

      ref.invalidate(pendingCodeProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Código $code copiado')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crear vínculo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Comparte este código con\ntu persona especial',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _create,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Generar código'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
