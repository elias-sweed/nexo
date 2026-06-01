import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexo/core/services/supabase_service.dart';
import '../domain/future_letter.dart';

class FutureLetterRepository {
  SupabaseClient get _client => SupabaseService.client;

  Future<List<FutureLetter>> getLetters(String coupleId) async {
    final data = await _client
        .from('future_letters')
        .select('*, profiles!author_id(display_name)')
        .eq('couple_id', coupleId)
        .order('created_at', ascending: false);

    return data.map((e) {
      final letter = _mapToLetter(e);
      if (!_isUnlocked(letter.unlockDate)) {
        return letter.copyWith(content: null, isUnlocked: false);
      }
      return letter.copyWith(isUnlocked: true);
    }).toList();
  }

  Future<FutureLetter> createLetter({
    required String coupleId,
    required String authorId,
    required String title,
    required String content,
    required DateTime unlockDate,
  }) async {
    final data = await _client.from('future_letters').insert({
      'couple_id': coupleId,
      'author_id': authorId,
      'title': title,
      'content': content,
      'unlock_date': unlockDate.toIso8601String().split('T').first,
    }).select('*, profiles!author_id(display_name)').single();

    return _mapToLetter(data).copyWith(isUnlocked: true);
  }

  bool _isUnlocked(DateTime unlockDate) {
    final now = DateTime.now();
    final unlock = DateTime(unlockDate.year, unlockDate.month, unlockDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return !today.isBefore(unlock);
  }

  FutureLetter _mapToLetter(Map<String, dynamic> data) {
    final profile = data['profiles'] as Map<String, dynamic>?;
    final unlockDate = DateTime.parse(data['unlock_date'] as String);
    return FutureLetter(
      id: data['id'] as String,
      coupleId: data['couple_id'] as String,
      authorId: data['author_id'] as String,
      title: data['title'] as String,
      content: data['content'] as String?,
      unlockDate: unlockDate,
      createdAt: DateTime.parse(data['created_at'] as String),
      authorName: profile?['display_name'] as String?,
      isUnlocked: _isUnlocked(unlockDate),
    );
  }
}
