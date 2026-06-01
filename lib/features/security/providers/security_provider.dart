import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/biometric_service.dart';
import '../data/security_preferences_repository.dart';
import '../domain/biometric_info.dart';
import '../domain/security_settings.dart';

final securityPreferencesRepositoryProvider = Provider<SecurityPreferencesRepository>((ref) {
  return SecurityPreferencesRepository();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final biometricInfoProvider = FutureProvider<BiometricInfo>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.checkAvailability();
});

class SecuritySettingsNotifier extends AsyncNotifier<SecuritySettings> {
  @override
  Future<SecuritySettings> build() async {
    final repository = ref.watch(securityPreferencesRepositoryProvider);
    return await repository.loadSettings();
  }

  Future<void> toggleBiometric(bool enabled) async {
    final repository = ref.read(securityPreferencesRepositoryProvider);
    await repository.setBiometricEnabled(enabled);
    state = AsyncData(state.value!.copyWith(biometricEnabled: enabled));
  }
}

final securitySettingsProvider = AsyncNotifierProvider<SecuritySettingsNotifier, SecuritySettings>(
  SecuritySettingsNotifier.new,
);
