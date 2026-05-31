import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexo/core/services/supabase_service.dart';
import '../domain/couple.dart';

class CoupleRepository {
  SupabaseClient get _client => SupabaseService.client;

  Future<Couple?> getCurrentCouple(String userId) async {
    final data = await _client
        .from('couples')
        .select()
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .maybeSingle();

    if (data == null) return null;

    return _mapToCouple(data);
  }

  Future<String> createCouple(String userId) async {
    final existing = await getCurrentCouple(userId);
    if (existing != null) {
      throw Exception('Ya tienes un vínculo activo');
    }

    final code = _generateCode();

    await _client.from('invitations').insert({
      'invite_code': code,
      'created_by': userId,
    });

    return code;
  }

  Future<Couple> joinCouple(String code, String userId) async {
    final invitation = await _client
        .from('invitations')
        .select()
        .eq('invite_code', code)
        .maybeSingle();

    if (invitation == null) {
      throw Exception('Código inválido');
    }

    if (invitation['used'] == true) {
      throw Exception('Este código ya fue utilizado');
    }

    if (invitation['created_by'] == userId) {
      throw Exception('No puedes unirte a tu propio vínculo');
    }

    final existing = await getCurrentCouple(userId);
    if (existing != null) {
      throw Exception('Ya tienes un vínculo activo');
    }

    final data = await _client.from('couples').insert({
      'invite_code': code,
      'user1_id': invitation['created_by'],
      'user2_id': userId,
    }).select().single();

    await _client
        .from('invitations')
        .update({'used': true})
        .eq('id', invitation['id']);

    return _mapToCouple(data);
  }

  Future<String?> getPendingCode(String userId) async {
    final data = await _client
        .from('invitations')
        .select('invite_code')
        .eq('created_by', userId)
        .eq('used', false)
        .maybeSingle();

    return data?['invite_code'] as String?;
  }

  String _generateCode() {
    final random = Random();
    final number = random.nextInt(9000) + 1000;
    return 'NEXO-$number';
  }

  Couple _mapToCouple(Map<String, dynamic> data) {
    return Couple(
      id: data['id'] as String,
      inviteCode: data['invite_code'] as String,
      user1Id: data['user1_id'] as String,
      user2Id: data['user2_id'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}
