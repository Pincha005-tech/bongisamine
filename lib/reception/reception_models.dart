import '../coree/traceability/lot_status.dart';

export '../coree/traceability/lot_status.dart' show LotStatus;

/// Alias historique — mêmes codes que [LotStatus].
typedef MineralLotStatus = LotStatus;

class ReceptionWorkflow {
  ReceptionWorkflow._();

  static const transitionLabel = 'IN_TRANSPORT → DEPOT_RECEIVED';
  static const targetStatus = LotStatus.depotReceived;
  static const defaultAction = 'RECEPTION_DEPOT';
  static const scanSourceStatus = LotStatus.inTransport;
}

class ReceptionLotMovement {
  const ReceptionLotMovement({
    required this.id,
    required this.qrId,
    required this.mineralId,
    required this.workerId,
    required this.previousStatus,
    required this.newStatus,
    required this.locationName,
    required this.action,
    required this.createdAtLabel,
    this.latitude,
    this.longitude,
    this.comment,
  });

  final int id;
  final int qrId;
  final int? mineralId;
  final int? workerId;
  final String previousStatus;
  final String newStatus;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String action;
  final String? comment;
  final String createdAtLabel;
}

class ReceptionQrLot {
  const ReceptionQrLot({
    required this.id,
    required this.batchCode,
    required this.currentStatus,
    required this.mineralId,
    required this.qrDataPreview,
    required this.valid,
  });

  final int id;
  final String batchCode;
  final String currentStatus;
  final int mineralId;
  final String qrDataPreview;
  final bool valid;
}

class ReceptionAlert {
  const ReceptionAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.time,
    this.source,
  });

  final int id;
  final String type;
  final String message;
  final String severity;
  final String time;
  final String? source;
}

class ReceptionScanResult {
  const ReceptionScanResult.success(this.movement)
      : success = true,
        errorCode = null,
        errorMessage = null;

  const ReceptionScanResult.failure({
    required this.errorCode,
    required this.errorMessage,
  })  : success = false,
        movement = null;

  final bool success;
  final ReceptionLotMovement? movement;
  final String? errorCode;
  final String? errorMessage;
}

class ReceptionFraudCheckResult {
  const ReceptionFraudCheckResult({
    required this.passed,
    required this.message,
    this.riskLevel,
  });

  final bool passed;
  final String message;
  final String? riskLevel;
}
