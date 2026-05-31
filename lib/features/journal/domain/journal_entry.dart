class JournalEntry {
  final String id;
  final String coupleId;
  final String authorId;
  final String? authorName;
  final String content;
  final DateTime createdAt;

  const JournalEntry({
    required this.id,
    required this.coupleId,
    required this.authorId,
    this.authorName,
    required this.content,
    required this.createdAt,
  });
}
