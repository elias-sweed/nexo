import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../couple/providers/couple_provider.dart';
import '../data/future_letter_repository.dart';
import '../domain/future_letter.dart';

final futureLetterRepositoryProvider = Provider<FutureLetterRepository>((ref) {
  return FutureLetterRepository();
});

final futureLettersProvider = FutureProvider<List<FutureLetter>>((ref) async {
  final couple = await ref.watch(currentCoupleProvider.future);
  if (couple == null) return [];
  return ref.read(futureLetterRepositoryProvider).getLetters(couple.id);
});

final unlockedLettersProvider = Provider<List<FutureLetter>>((ref) {
  final letters = ref.watch(futureLettersProvider).value ?? [];
  return letters.where((l) => l.isUnlocked).toList();
});

final lockedLettersProvider = Provider<List<FutureLetter>>((ref) {
  final letters = ref.watch(futureLettersProvider).value ?? [];
  return letters.where((l) => !l.isUnlocked).toList();
});

class FutureLettersSummary {
  final int locked;
  final int unlocked;
  const FutureLettersSummary({required this.locked, required this.unlocked});
  int get total => locked + unlocked;
  bool get hasReady => unlocked > 0;
}

final futureLettersSummaryProvider = Provider<FutureLettersSummary>((ref) {
  final letters = ref.watch(futureLettersProvider).value ?? [];
  int locked = 0, unlocked = 0;
  for (final l in letters) {
    if (l.isUnlocked) {
      unlocked++;
    } else {
      locked++;
    }
  }
  return FutureLettersSummary(locked: locked, unlocked: unlocked);
});
