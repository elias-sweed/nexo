class Memory {
  final String id;
  final String coupleId;
  final String createdBy;
  final String title;
  final String? description;
  final String coverImageUrl;
  final DateTime memoryDate;
  final DateTime createdAt;
  final String? creatorName;

  const Memory({
    required this.id,
    required this.coupleId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.coverImageUrl,
    required this.memoryDate,
    required this.createdAt,
    this.creatorName,
  });
}
