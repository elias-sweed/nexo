import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_colors.dart';
import 'package:nexo/core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../couple/providers/couple_provider.dart';
import '../providers/future_letter_provider.dart';

class CreateFutureLetterScreen extends ConsumerStatefulWidget {
  const CreateFutureLetterScreen({super.key});

  @override
  ConsumerState<CreateFutureLetterScreen> createState() =>
      _CreateFutureLetterScreenState();
}

class _CreateFutureLetterScreenState
    extends ConsumerState<CreateFutureLetterScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _unlockDate;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final minDate = DateTime.now().add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: _unlockDate ?? minDate,
      firstDate: minDate,
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() => _unlockDate = date);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty || _unlockDate == null) return;
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final repo = ref.read(futureLetterRepositoryProvider);
      final couple = await ref.read(currentCoupleProvider.future);
      if (couple == null) throw Exception('No tienes un vínculo activo');
      final authState = ref.read(authStateProvider);
      if (authState.user == null) throw Exception('No autenticado');

      await repo.createLetter(
        coupleId: couple.id,
        authorId: authState.user!.id,
        title: title,
        content: content,
        unlockDate: _unlockDate!,
      );

      ref.invalidate(futureLettersProvider);

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
    final months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    final canSave = _titleController.text.trim().isNotEmpty &&
        _contentController.text.trim().isNotEmpty &&
        _unlockDate != null &&
        !_saving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nueva carta'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Tu mensaje al futuro',
                alignLabelWithHint: true,
              ),
              style: const TextStyle(color: AppColors.textPrimary, height: 1.5),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de apertura',
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_clock, size: 18, color: gold),
                    const SizedBox(width: 12),
                    Text(
                      _unlockDate != null
                          ? '${_unlockDate!.day} de ${months[_unlockDate!.month]} de ${_unlockDate!.year}'
                          : 'Seleccionar fecha futura',
                      style: TextStyle(
                        color: _unlockDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_unlockDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Esta carta podrá abrirse a partir de esa fecha.',
                style: TextStyle(color: gold, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
