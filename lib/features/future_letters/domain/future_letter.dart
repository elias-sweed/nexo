class FutureLetter {
  final String id;
  final String coupleId;
  final String authorId;
  final String title;
  final String? content;
  final DateTime unlockDate;
  final DateTime createdAt;
  final String? authorName;
  final bool isUnlocked;

  const FutureLetter({
    required this.id,
    required this.coupleId,
    required this.authorId,
    required this.title,
    this.content,
    required this.unlockDate,
    required this.createdAt,
    this.authorName,
    required this.isUnlocked,
  });

  FutureLetter copyWith({String? content, bool? isUnlocked}) {
    return FutureLetter(
      id: id,
      coupleId: coupleId,
      authorId: authorId,
      title: title,
      content: content ?? this.content,
      unlockDate: unlockDate,
      createdAt: createdAt,
      authorName: authorName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
