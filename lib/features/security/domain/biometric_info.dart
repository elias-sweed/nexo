import 'package:local_auth/local_auth.dart';

class BiometricInfo {
  final bool isAvailable;
  final List<BiometricType> availableTypes;

  const BiometricInfo({
    required this.isAvailable,
    required this.availableTypes,
  });

  bool get canAuthenticate => isAvailable && availableTypes.isNotEmpty;
}
