enum ActivityType {
  journal,
  memory,
  futureLetter,
}

class ActivityItem {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final ActivityType type;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });
}
