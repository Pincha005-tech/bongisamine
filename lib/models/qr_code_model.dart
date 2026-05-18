class QrCodeModel {
  const QrCodeModel({
    required this.id,
    required this.data,
    required this.signature,
    this.mineralId,
    this.workerId,
    this.batchCode,
    this.originSite,
    this.currentStatus,
    this.qrPath,
    this.createdAt,
  });

  final int id;
  final String data;
  final String signature;
  final int? mineralId;
  final int? workerId;
  final String? batchCode;
  final String? originSite;
  final String? currentStatus;
  final String? qrPath;
  final DateTime? createdAt;

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      id: json['id'] as int,
      data: json['data'] as String? ?? '',
      signature: json['signature'] as String? ?? '',
      mineralId: json['mineral_id'] as int?,
      workerId: json['worker_id'] as int?,
      batchCode: json['batch_code'] as String?,
      originSite: json['origin_site'] as String?,
      currentStatus: json['current_status'] as String?,
      qrPath: json['qr_path'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
