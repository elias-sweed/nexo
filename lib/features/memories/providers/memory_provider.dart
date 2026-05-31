import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../couple/providers/couple_provider.dart';
import '../data/memory_repository.dart';
import '../domain/memory.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository();
});

final memoriesProvider = FutureProvider<List<Memory>>((ref) async {
  final couple = await ref.watch(currentCoupleProvider.future);
  if (couple == null) return [];
  return ref.read(memoryRepositoryProvider).getMemories(couple.id);
});

final memoryDetailProvider = FutureProvider.family<Memory, String>(
  (ref, id) async {
    return ref.read(memoryRepositoryProvider).getMemoryById(id);
  },
);
