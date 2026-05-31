class Couple {
  final String id;
  final String inviteCode;
  final String user1Id;
  final String? user2Id;
  final DateTime createdAt;

  const Couple({
    required this.id,
    required this.inviteCode,
    required this.user1Id,
    this.user2Id,
    required this.createdAt,
  });

  bool get isComplete => user2Id != null;
}
