import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_colors.dart';
import 'package:nexo/core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../couple/providers/couple_provider.dart';
import '../providers/journal_provider.dart';

class CreateEntryScreen extends ConsumerStatefulWidget {
  const CreateEntryScreen({super.key});

  @override
  ConsumerState<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends ConsumerState<CreateEntryScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final repo = ref.read(journalRepositoryProvider);
      final coupleAsync = await ref.read(currentCoupleProvider.future);
      if (coupleAsync == null) throw Exception('No tienes un vínculo activo');
      final authState = ref.read(authStateProvider);
      if (authState.user == null) throw Exception('No autenticado');

      await repo.createEntry(
        coupleId: coupleAsync.id,
        authorId: authState.user!.id,
        content: content,
      );

      ref.invalidate(journalEntriesProvider);

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppThemeExtension>()!.gold;
    final canSave = _controller.text.trim().isNotEmpty && !_saving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nueva entrada'),
        actions: [
          TextButton(
            onPressed: canSave ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Guardar', style: TextStyle(color: gold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Escribe algo...',
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }
}
