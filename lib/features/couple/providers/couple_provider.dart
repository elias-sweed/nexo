import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/couple_repository.dart';
import '../domain/couple.dart';

final coupleRepositoryProvider = Provider<CoupleRepository>((ref) {
  return CoupleRepository();
});

final currentCoupleProvider = FutureProvider<Couple?>((ref) {
  final authUser = ref.watch(authStateProvider.select((s) => s.user));
  if (authUser == null) return null;
  final repository = ref.watch(coupleRepositoryProvider);
  return repository.getCurrentCouple(authUser.id);
});

final pendingCodeProvider = FutureProvider<String?>((ref) {
  final authUser = ref.watch(authStateProvider.select((s) => s.user));
  if (authUser == null) return null;
  final repository = ref.watch(coupleRepositoryProvider);
  return repository.getPendingCode(authUser.id);
});
