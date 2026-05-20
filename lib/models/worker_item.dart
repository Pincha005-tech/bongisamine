enum WorkerStatus { active, inactive, onLeave }

enum WorkerNameSort { ascending, descending }

class WorkerItem {
  const WorkerItem({
    required this.id,
    required this.name,
    required this.status,
    required this.department,
    required this.lastScan,
  });

  final String id;
  final String name;
  final WorkerStatus status;
  final String department;
  final String lastScan;
}
