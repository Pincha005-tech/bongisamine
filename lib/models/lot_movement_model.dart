class LotMovementModel {
  const LotMovementModel({
    required this.id,
    required this.qrId,
    required this.newStatus,
    required this.action,
    this.mineralId,
    this.workerId,
    this.previousStatus,
    this.locationName,
    this.latitude,
    this.longitude,
    this.comment,
    this.createdAt,
  });

  final int id;
  final int qrId;
  final int? mineralId;
  final int? workerId;
  final String? previousStatus;
  final String newStatus;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String action;
  final String? comment;
  final DateTime? createdAt;

  factory LotMovementModel.fromJson(Map<String, dynamic> json) {
    return LotMovementModel(
      id: json['id'] as int,
      qrId: json['qr_id'] as int,
      mineralId: json['mineral_id'] as int?,
      workerId: json['worker_id'] as int?,
      previousStatus: json['previous_status'] as String?,
      newStatus: json['new_status'] as String? ?? '',
      locationName: json['location_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      action: json['action'] as String? ?? '',
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
