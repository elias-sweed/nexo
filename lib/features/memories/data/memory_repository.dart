import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexo/core/services/supabase_service.dart';
import '../domain/memory.dart';

class MemoryRepository {
  SupabaseClient get _client => SupabaseService.client;

  Future<List<Memory>> getMemories(String coupleId) async {
    final data = await _client
        .from('memories')
        .select('*, profiles!created_by(display_name)')
        .eq('couple_id', coupleId)
        .order('memory_date', ascending: false);
    return data.map((e) => _mapToMemory(e)).toList();
  }

  Future<Memory> getMemoryById(String id) async {
    final data = await _client
        .from('memories')
        .select('*, profiles!created_by(display_name)')
        .eq('id', id)
        .single();
    return _mapToMemory(data);
  }

  Future<String> uploadImage(String coupleId, File file) async {
    final ext = file.path.split('.').last;
    final path = '$coupleId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('memories').upload(
          path,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return _client.storage.from('memories').getPublicUrl(path);
  }

  Future<Memory> createMemory({
    required String coupleId,
    required String createdBy,
    required String title,
    String? description,
    required String coverImageUrl,
    required DateTime memoryDate,
  }) async {
    final data = await _client.from('memories').insert({
      'couple_id': coupleId,
      'created_by': createdBy,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'memory_date': memoryDate.toIso8601String().split('T').first,
    }).select('*, profiles!created_by(display_name)').single();
    return _mapToMemory(data);
  }

  Memory _mapToMemory(Map<String, dynamic> data) {
    final profile = data['profiles'] as Map<String, dynamic>?;
    return Memory(
      id: data['id'] as String,
      coupleId: data['couple_id'] as String,
      createdBy: data['created_by'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      coverImageUrl: data['cover_image_url'] as String,
      memoryDate: DateTime.parse(data['memory_date'] as String),
      createdAt: DateTime.parse(data['created_at'] as String),
      creatorName: profile?['display_name'] as String?,
    );
  }
}
