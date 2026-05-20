import '../coree/traceability/lot_status.dart';

export '../coree/traceability/lot_status.dart' show LotStatus;

class ExtractionWorkflow {
  ExtractionWorkflow._();

  static const transitionLabel = 'EXTRACTED → STORED';
  static const targetStatus = LotStatus.stored;
  static const defaultAction = 'STOCKAGE_EXTRACTION';
  static const scanSourceStatus = LotStatus.extracted;
}

class ExtractionMineral {
  const ExtractionMineral({
    required this.id,
    required this.type,
    required this.weight,
    required this.status,
    this.latitude,
    this.longitude,
    this.hasQr = false,
    this.batchCode,
    this.qrId,
  });

  final int id;
  final String type;
  final double weight;
  final String status;
  final double? latitude;
  final double? longitude;
  final bool hasQr;
  final String? batchCode;
  final int? qrId;
}

class ExtractionQrLot {
  const ExtractionQrLot({
    required this.id,
    required this.batchCode,
    required this.currentStatus,
    required this.mineralId,
    required this.valid,
    this.originSite,
  });

  final int id;
  final String batchCode;
  final String currentStatus;
  final int mineralId;
  final bool valid;
  final String? originSite;
}

class ExtractionLotMovement {
  const ExtractionLotMovement({
    required this.id,
    required this.qrId,
    required this.mineralId,
    required this.workerId,
    required this.previousStatus,
    required this.newStatus,
    required this.locationName,
    required this.action,
    required this.createdAtLabel,
  });

  final int id;
  final int qrId;
  final int? mineralId;
  final int? workerId;
  final String previousStatus;
  final String newStatus;
  final String? locationName;
  final String action;
  final String createdAtLabel;
}

class ExtractionAlert {
  const ExtractionAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.time,
  });

  final int id;
  final String type;
  final String message;
  final String severity;
  final String time;
}

class ExtractionScanResult {
  const ExtractionScanResult.success(this.movement)
      : success = true,
        errorCode = null,
        errorMessage = null;

  const ExtractionScanResult.failure({
    required this.errorCode,
    required this.errorMessage,
  })  : success = false,
        movement = null;

  final bool success;
  final ExtractionLotMovement? movement;
  final String? errorCode;
  final String? errorMessage;
}

class ExtractionQrGenerateResult {
  const ExtractionQrGenerateResult({
    required this.success,
    required this.message,
    this.qr,
  });

  final bool success;
  final String message;
  final ExtractionQrLot? qr;
}
