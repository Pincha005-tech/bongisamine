class DashboardStats {
  const DashboardStats({
    required this.workers,
    required this.minerals,
    required this.qrcodes,
    required this.alerts,
    required this.criticalAlerts,
    required this.attendances,
    required this.lotMovements,
    required this.blocks,
  });

  final int workers;
  final int minerals;
  final int qrcodes;
  final int alerts;
  final int criticalAlerts;
  final int attendances;
  final int lotMovements;
  final int blocks;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      workers: json['workers'] as int? ?? 0,
      minerals: json['minerals'] as int? ?? 0,
      qrcodes: json['qrcodes'] as int? ?? 0,
      alerts: json['alerts'] as int? ?? 0,
      criticalAlerts: json['critical_alerts'] as int? ?? 0,
      attendances: json['attendances'] as int? ?? 0,
      lotMovements: json['lot_movements'] as int? ?? 0,
      blocks: json['blocks'] as int? ?? 0,
    );
  }
}
