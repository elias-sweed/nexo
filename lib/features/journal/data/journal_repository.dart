import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexo/core/services/supabase_service.dart';
import '../domain/journal_entry.dart';

class JournalRepository {
  SupabaseClient get _client => SupabaseService.client;

  Future<List<JournalEntry>> getEntries(String coupleId) async {
    final data = await _client
        .from('journal_entries')
        .select('*, profiles!author_id(display_name)')
        .eq('couple_id', coupleId)
        .order('created_at', ascending: false);
    return data.map((e) => _mapToEntry(e)).toList();
  }

  Future<JournalEntry> createEntry({
    required String coupleId,
    required String authorId,
    required String content,
  }) async {
    final data = await _client.from('journal_entries').insert({
      'couple_id': coupleId,
      'author_id': authorId,
      'content': content,
    }).select('*, profiles!author_id(display_name)').single();
    return _mapToEntry(data);
  }

  RealtimeChannel subscribeToEntries(
    String coupleId,
    void Function(Map<String, dynamic> newRecord) onInsert,
  ) {
    final channel = _client.channel('journal-entries-$coupleId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'journal_entries',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'couple_id',
        value: coupleId,
      ),
      callback: (payload) {
        onInsert(payload.newRecord);
      },
    ).subscribe();
    return channel;
  }

  JournalEntry _mapToEntry(Map<String, dynamic> data) {
    final profile = data['profiles'] as Map<String, dynamic>?;
    return JournalEntry(
      id: data['id'] as String,
      coupleId: data['couple_id'] as String,
      authorId: data['author_id'] as String,
      authorName: profile?['display_name'] as String?,
      content: data['content'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}
