class RelationshipStats {
  final int daysTogether;
  final int monthsTogether;
  final int weeksTogether;
  final int totalJournalEntries;
  final int totalMemories;
  final int totalLetters;
  final DateTime nextAnniversary;
  final int daysUntilAnniversary;
  final int activityThisWeek;

  const RelationshipStats({
    required this.daysTogether,
    required this.monthsTogether,
    required this.weeksTogether,
    required this.totalJournalEntries,
    required this.totalMemories,
    required this.totalLetters,
    required this.nextAnniversary,
    required this.daysUntilAnniversary,
    required this.activityThisWeek,
  });

  factory RelationshipStats.empty() {
    return RelationshipStats(
      daysTogether: 0,
      monthsTogether: 0,
      weeksTogether: 0,
      totalJournalEntries: 0,
      totalMemories: 0,
      totalLetters: 0,
      nextAnniversary: DateTime.now(),
      daysUntilAnniversary: 0,
      activityThisWeek: 0,
    );
  }
}
