class ActivityLog {
  const ActivityLog({
    required this.name,
    required this.action,
    required this.time,
  });

  final String name;
  final String action;
  final String time;

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      name: map['name'] as String? ?? '',
      action: map['action'] as String? ?? '',
      time: map['time'] as String? ?? '',
    );
  }
}
