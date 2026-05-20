/// Position d’un traceur GPS renvoyée par le backend (`GET /trackers`).
class GpsTracker {
  const GpsTracker({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
    this.updatedAt,
    this.status = TrackerStatus.active,
    this.batteryPercent,
  });

  final String id;
  final String label;
  final double latitude;
  final double longitude;
  final String? updatedAt;
  final TrackerStatus status;
  final int? batteryPercent;

  factory GpsTracker.fromMap(Map<String, dynamic> map) {
    return GpsTracker(
      id: map['id']?.toString() ?? '',
      label: map['label'] as String? ??
          map['name'] as String? ??
          'Traceur',
      latitude: _toDouble(map['latitude'] ?? map['lat']),
      longitude: _toDouble(map['longitude'] ?? map['lng'] ?? map['lon']),
      updatedAt: map['updated_at'] as String? ?? map['updatedAt'] as String?,
      status: TrackerStatus.fromString(map['status'] as String?),
      batteryPercent: map['battery'] as int? ?? map['battery_percent'] as int?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  bool get hasValidCoordinates =>
      latitude != 0 || longitude != 0;
}

enum TrackerStatus {
  active,
  idle,
  offline;

  static TrackerStatus fromString(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'active':
      case 'moving':
      case 'online':
        return TrackerStatus.active;
      case 'idle':
      case 'parked':
        return TrackerStatus.idle;
      case 'offline':
      case 'inactive':
        return TrackerStatus.offline;
      default:
        return TrackerStatus.active;
    }
  }

  String get label {
    switch (this) {
      case TrackerStatus.active:
        return 'En mouvement';
      case TrackerStatus.idle:
        return 'À l’arrêt';
      case TrackerStatus.offline:
        return 'Hors ligne';
    }
  }
}
