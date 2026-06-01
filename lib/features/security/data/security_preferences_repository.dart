import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/security_settings.dart';

class SecurityPreferencesRepository {
  final FlutterSecureStorage _storage;
  
  static const _keyBiometricEnabled = 'nexo_biometric_enabled';

  SecurityPreferencesRepository({FlutterSecureStorage? storage}) 
      : _storage = storage ?? const FlutterSecureStorage();

  Future<SecuritySettings> loadSettings() async {
    final biometricStr = await _storage.read(key: _keyBiometricEnabled);
    final biometricEnabled = biometricStr == 'true';
    
    return SecuritySettings(
      biometricEnabled: biometricEnabled,
    );
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _keyBiometricEnabled, 
      value: enabled.toString(),
    );
  }
}
