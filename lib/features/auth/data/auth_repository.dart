import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexo/core/services/supabase_service.dart';
import '../domain/auth_user.dart';

class AuthRepository {
  SupabaseClient get _client => SupabaseService.client;

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': name},
    );

    final user = response.user;
    if (user == null) {
      throw Exception('No se pudo crear el usuario');
    }

    await _client.from('profiles').insert({
      'id': user.id,
      'display_name': name,
    });

    final profile = await _client
        .from('profiles')
        .select('display_name, avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    return AppUser(
      id: user.id,
      email: user.email ?? email,
      displayName: profile?['display_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
    );
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Credenciales inválidas');
    }

    var profile = await _client
        .from('profiles')
        .select('display_name, avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      final name = user.userMetadata?['display_name'] as String? ?? user.email?.split('@').first ?? 'NEXO';
      await _client.from('profiles').insert({
        'id': user.id,
        'display_name': name,
      });
      profile = <String, dynamic>{'display_name': name, 'avatar_url': null};
    }

    return AppUser(
      id: user.id,
      email: user.email ?? email,
      displayName: profile['display_name'] as String?,
      avatarUrl: profile['avatar_url'] as String?,
    );
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final response = await _client.auth.getUser();
      final user = response.user;
      if (user == null) return null;

      var profile = await _client
          .from('profiles')
          .select('display_name, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        final name = user.userMetadata?['display_name'] as String? ?? user.email?.split('@').first ?? 'NEXO';
        await _client.from('profiles').insert({
          'id': user.id,
          'display_name': name,
        });
        profile = <String, dynamic>{'display_name': name, 'avatar_url': null};
      }

      return AppUser(
        id: user.id,
        email: user.email ?? '',
        displayName: profile['display_name'] as String?,
        avatarUrl: profile['avatar_url'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
