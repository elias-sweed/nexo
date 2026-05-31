import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../couple/providers/couple_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/journal_repository.dart';
import '../domain/journal_entry.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository();
});

final journalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) async {
  final couple = await ref.watch(currentCoupleProvider.future);
  if (couple == null) return [];
  return ref.read(journalRepositoryProvider).getEntries(couple.id);
});

final journalRealtimeProvider = Provider<RealtimeChannel?>((ref) {
  final couple = ref.watch(currentCoupleProvider).value;
  if (couple == null) return null;

  final channel = ref.read(journalRepositoryProvider).subscribeToEntries(
    couple.id,
    (_) {
      ref.invalidate(journalEntriesProvider);
    },
  );

  ref.onDispose(() => channel.unsubscribe());
  return channel;
});

final journalCreateProvider = FutureProvider.family<JournalEntry, String>(
  (ref, content) async {
    final couple = await ref.watch(currentCoupleProvider.future);
    if (couple == null) throw Exception('No tienes un vínculo activo');

    final user = ref.watch(authStateProvider).user;
    if (user == null) throw Exception('No autenticado');

    return ref.read(journalRepositoryProvider).createEntry(
          coupleId: couple.id,
          authorId: user.id,
          content: content,
        );
  },
);
