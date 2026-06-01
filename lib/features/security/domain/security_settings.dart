class SecuritySettings {
  final bool biometricEnabled;

  const SecuritySettings({
    this.biometricEnabled = false,
  });

  SecuritySettings copyWith({
    bool? biometricEnabled,
  }) {
    return SecuritySettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
