class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.action,
    this.mineralId,
    this.workerId,
    this.qrId,
    this.latitude,
    this.longitude,
    this.status,
    this.createdAt,
  });

  final int id;
  final int? mineralId;
  final int? workerId;
  final int? qrId;
  final String action;
  final double? latitude;
  final double? longitude;
  final String? status;
  final DateTime? createdAt;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      mineralId: json['mineral_id'] as int?,
      workerId: json['worker_id'] as int?,
      qrId: json['qr_id'] as int?,
      action: json['action'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
