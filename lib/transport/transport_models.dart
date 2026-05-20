import '../coree/traceability/lot_status.dart';

export '../coree/traceability/lot_status.dart' show LotStatus;

class TransportWorkflow {
  TransportWorkflow._();

  static const transitionLabel = 'STORED → IN_TRANSPORT';
  static const targetStatus = LotStatus.inTransport;
  static const defaultAction = 'CHARGEMENT_TRANSPORT';
  static const scanSourceStatus = LotStatus.stored;
}

class TransportLotMovement {
  const TransportLotMovement({
    required this.id,
    required this.qrId,
    required this.mineralId,
    required this.workerId,
    required this.previousStatus,
    required this.newStatus,
    required this.locationName,
    required this.action,
    required this.createdAtLabel,
    this.comment,
  });

  final int id;
  final int qrId;
  final int? mineralId;
  final int? workerId;
  final String previousStatus;
  final String newStatus;
  final String? locationName;
  final String action;
  final String? comment;
  final String createdAtLabel;
}

class TransportQrLot {
  const TransportQrLot({
    required this.id,
    required this.batchCode,
    required this.currentStatus,
    required this.mineralId,
    required this.valid,
  });

  final int id;
  final String batchCode;
  final String currentStatus;
  final int mineralId;
  final bool valid;
}

class TransportAlert {
  const TransportAlert({
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

class TransportScanResult {
  const TransportScanResult.success(this.movement)
      : success = true,
        errorCode = null,
        errorMessage = null;

  const TransportScanResult.failure({
    required this.errorCode,
    required this.errorMessage,
  })  : success = false,
        movement = null;

  final bool success;
  final TransportLotMovement? movement;
  final String? errorCode;
  final String? errorMessage;
}

class TransportSecureReadResult {
  const TransportSecureReadResult({
    required this.valid,
    required this.message,
    this.batchCode,
    this.currentStatus,
    this.step,
  });

  final bool valid;
  final String message;
  final String? batchCode;
  final String? currentStatus;
  final String? step;
}
