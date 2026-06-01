import 'package:local_auth/local_auth.dart';
import '../domain/biometric_info.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  Future<BiometricInfo> checkAvailability() async {
    try {
      final isAvailable = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      final availableTypes = await _auth.getAvailableBiometrics();
      
      return BiometricInfo(
        isAvailable: isAvailable,
        availableTypes: availableTypes,
      );
    } on PlatformException catch (_) {
      return const BiometricInfo(isAvailable: false, availableTypes: []);
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Desbloquea NEXO para acceder a tus recuerdos',
        biometricOnly: true,
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Error en autenticación biométrica: ${e.message}');
      }
      return false;
    }
  }
}
