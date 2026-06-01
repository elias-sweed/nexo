import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../couple/providers/couple_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../../memories/providers/memory_provider.dart';
import '../../future_letters/providers/future_letter_provider.dart';
import '../domain/activity_item.dart';
import '../domain/relationship_stats.dart';

final relationshipStatsProvider = Provider<RelationshipStats>((ref) {
  final couple = ref.watch(currentCoupleProvider).value;
  if (couple == null) return RelationshipStats.empty();

  final journalEntries = ref.watch(journalEntriesProvider).value ?? [];
  final memories = ref.watch(memoriesProvider).value ?? [];
  final letters = ref.watch(futureLettersProvider).value ?? [];

  final now = DateTime.now();
  final createdAt = couple.createdAt;
  
  final duration = now.difference(createdAt);
  final daysTogether = duration.inDays;
  final weeksTogether = (daysTogether / 7).floor();
  
  // Approximate months
  final monthsTogether = (now.year - createdAt.year) * 12 + now.month - createdAt.month - (now.day < createdAt.day ? 1 : 0);

  // Next monthly anniversary (same day each month)
  final anniversaryDay = createdAt.day;
  int nextMonth = now.month;
  int nextYear = now.year;

  if (now.day > anniversaryDay) {
    nextMonth++;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }
  }

  final lastDayOfMonth = DateTime(nextYear, nextMonth + 1, 0).day;
  final clampedDay = anniversaryDay > lastDayOfMonth ? lastDayOfMonth : anniversaryDay;
  final nextAnniversary = DateTime(nextYear, nextMonth, clampedDay);
  final today = DateTime(now.year, now.month, now.day);
  final daysUntilAnniversary = nextAnniversary.difference(today).inDays;

  // Activity this week
  final oneWeekAgo = now.subtract(const Duration(days: 7));
  int activityThisWeek = 0;
  activityThisWeek += journalEntries.where((e) => e.createdAt.isAfter(oneWeekAgo)).length;
  activityThisWeek += memories.where((m) => m.createdAt.isAfter(oneWeekAgo)).length;
  activityThisWeek += letters.where((l) => l.createdAt.isAfter(oneWeekAgo)).length;

  return RelationshipStats(
    daysTogether: daysTogether,
    monthsTogether: monthsTogether >= 0 ? monthsTogether : 0,
    weeksTogether: weeksTogether >= 0 ? weeksTogether : 0,
    totalJournalEntries: journalEntries.length,
    totalMemories: memories.length,
    totalLetters: letters.length,
    nextAnniversary: nextAnniversary,
    daysUntilAnniversary: daysUntilAnniversary >= 0 ? daysUntilAnniversary : 0,
    activityThisWeek: activityThisWeek,
  );
});

final recentActivityProvider = Provider<List<ActivityItem>>((ref) {
  final journalEntries = ref.watch(journalEntriesProvider).value ?? [];
  final memories = ref.watch(memoriesProvider).value ?? [];
  final letters = ref.watch(futureLettersProvider).value ?? [];

  final List<ActivityItem> allItems = [];

  for (final entry in journalEntries) {
    allItems.add(ActivityItem(
      id: entry.id,
      title: 'Nueva entrada en diario',
      description: entry.content.length > 50 ? '${entry.content.substring(0, 50)}...' : entry.content,
      date: entry.createdAt,
      type: ActivityType.journal,
    ));
  }

  for (final memory in memories) {
    allItems.add(ActivityItem(
      id: memory.id,
      title: 'Nuevo recuerdo: ${memory.title}',
      description: memory.description ?? '',
      date: memory.createdAt,
      type: ActivityType.memory,
    ));
  }

  for (final letter in letters) {
    allItems.add(ActivityItem(
      id: letter.id,
      title: 'Nueva carta para el futuro',
      description: letter.title,
      date: letter.createdAt,
      type: ActivityType.futureLetter,
    ));
  }

  allItems.sort((a, b) => b.date.compareTo(a.date));
  return allItems.take(10).toList();
});

final featuredMemoryProvider = Provider((ref) {
  final memories = ref.watch(memoriesProvider).value ?? [];
  if (memories.isEmpty) return null;
  // Get the most recent memory as featured
  return memories.first;
});

final partnerNameProvider = FutureProvider<String?>((ref) {
  final couple = ref.watch(currentCoupleProvider).value;
  final currentUserId = ref.watch(authStateProvider.select((s) => s.user?.id));
  if (couple == null || currentUserId == null) return null;

  final partnerId = couple.user1Id == currentUserId ? couple.user2Id : couple.user1Id;
  if (partnerId == null) return null;

  return _resolvePartnerName(partnerId);
});

String _capitalize(String s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';

Future<String?> _resolvePartnerName(String partnerId) async {
  final client = SupabaseService.client;

  try {
    final email = await client.rpc('get_user_email', params: {'p_user_id': partnerId});
    if (email != null && email is String) {
      final name = _capitalize(email.split('@').first);
      await client.from('profiles').update({'display_name': name}).eq('id', partnerId);
      return name;
    }
  } catch (_) {}

  try {
    final profile = await client
        .from('profiles')
        .select('display_name')
        .eq('id', partnerId)
        .maybeSingle();
    final displayName = profile?['display_name'] as String?;
    if (displayName != null && displayName.isNotEmpty) return displayName;
  } catch (_) {}

  return null;
}

final dailyQuoteProvider = Provider<String>((ref) {
  const quotes = [
    "Los mejores recuerdos son los que aún seguimos construyendo.",
    "Cada día juntos es una página más de nuestra historia.",
    "El amor no se mira, se siente, y aún más cuando estás junto a mí.",
    "Eres mi lugar favorito para ir cuando mi mente busca paz.",
    "Contigo, todos los días son una aventura que vale la pena.",
    "La mejor parte de mi día es cuando lo comparto contigo.",
    "Amar no es solamente querer, es sobre todo comprender.",
    "Nuestro vínculo es el hilo invisible que nos mantiene unidos siempre.",
    "Haces que lo ordinario se vuelva extraordinario.",
    "En cada pequeño detalle tuyo encuentro un universo entero."
  ];
  
  final now = DateTime.now();
  // Simple hash to get a consistent quote for the day
  final index = (now.year * 365 + now.month * 31 + now.day) % quotes.length;
  return quotes[index];
});
