import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/security_provider.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securitySettingsAsync = ref.watch(securitySettingsProvider);
    final biometricInfoAsync = ref.watch(biometricInfoProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()?.gold ?? AppColors.gold;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Seguridad Privada'),
      ),
      body: securitySettingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'AUTENTICACIÓN', gold),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: biometricInfoAsync.when(
                  data: (bioInfo) {
                    final canAuthenticate = bioInfo.canAuthenticate;
                    return SwitchListTile(
                      title: const Text('Desbloqueo biométrico'),
                      subtitle: Text(
                        canAuthenticate 
                            ? 'Usa tu huella o rostro para acceder a NEXO'
                            : 'Biometría no disponible en este dispositivo',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                      value: settings.biometricEnabled && canAuthenticate,
                      onChanged: canAuthenticate 
                          ? (value) {
                              ref.read(securitySettingsProvider.notifier).toggleBiometric(value);
                            }
                          : null,
                      activeThumbColor: gold,
                      secondary: Icon(
                        Icons.fingerprint,
                        color: canAuthenticate ? gold : AppColors.textSecondary,
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) => const ListTile(
                    title: Text('Error cargando información biométrica'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'INFORMACIÓN', gold),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  leading: Icon(Icons.security, color: gold),
                  title: const Text('NEXO Security Premium'),
                  subtitle: const Text('Tus recuerdos están protegidos. Las capturas de pantalla seguras y tiempos de bloqueo personalizados llegarán pronto.'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color gold) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: gold,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
