import 'package:flutter/material.dart';

/// Statuts lots — `mine_back` traceability_service ALLOWED_TRANSITIONS.
class MineralLotStatus {
  static const extracted = 'EXTRACTED';
  static const stored = 'STORED';
  static const inTransport = 'IN_TRANSPORT';
  static const depotReceived = 'DEPOT_RECEIVED';
  static const exportReady = 'EXPORT_READY';
  static const exported = 'EXPORTED';
  static const blocked = 'BLOCKED';
}

/// Aligné sur `LotMovementResponse` (schemas/lot_movement.py).
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

/// Aligné sur réponses QR (`QRResponse` / verify).
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

/// Aligné sur `Alert` backend.
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

/// KPI accueil — dérivés de dashboard + file IN_TRANSPORT.
class ReceptionHomeStats {
  const ReceptionHomeStats({
    required this.lotsInTransport,
    required this.receptionsToday,
    required this.criticalAlerts,
    required this.invalidQrToday,
  });

  final int lotsInTransport;
  final int receptionsToday;
  final int criticalAlerts;
  final int invalidQrToday;
}

/// Résultat mock `POST /traceability/reception/scan`.
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

/// Résultat mock `POST /security/face-qr-fraud-check`.
class ReceptionFraudCheckResult {
  const ReceptionFraudCheckResult({
    required this.success,
    required this.message,
    this.step,
    this.fraudDetected = false,
  });

  final bool success;
  final String message;
  final String? step;
  final bool fraudDetected;
}

class ReceptionMockData {
  ReceptionMockData._();

  static const transitionReception = 'IN_TRANSPORT → DEPOT_RECEIVED';
  static const targetStatus = MineralLotStatus.depotReceived;
  static const defaultAction = 'RECEPTION_DEPOT';

  static const homeStats = ReceptionHomeStats(
    lotsInTransport: 7,
    receptionsToday: 12,
    criticalAlerts: 2,
    invalidQrToday: 1,
  );

  static final List<ReceptionQrLot> qrLots = [
    const ReceptionQrLot(
      id: 101,
      batchCode: 'DRC-MINE-8-A3D91C',
      currentStatus: MineralLotStatus.inTransport,
      mineralId: 8,
      qrDataPreview: 'eyJsb3QiOiI4In0…',
      valid: true,
    ),
    const ReceptionQrLot(
      id: 102,
      batchCode: 'DRC-MINE-5-CC812A',
      currentStatus: MineralLotStatus.inTransport,
      mineralId: 5,
      qrDataPreview: 'eyJsb3QiOiI1In0…',
      valid: true,
    ),
    const ReceptionQrLot(
      id: 103,
      batchCode: 'DRC-MINE-2-B91E04',
      currentStatus: MineralLotStatus.stored,
      mineralId: 2,
      qrDataPreview: 'eyJsb3QiOiIyIn0…',
      valid: true,
    ),
    const ReceptionQrLot(
      id: 104,
      batchCode: 'DRC-MINE-1-FF0099',
      currentStatus: MineralLotStatus.blocked,
      mineralId: 1,
      qrDataPreview: 'eyJsb3QiOiIxIn0…',
      valid: false,
    ),
  ];

  static List<ReceptionLotMovement> historyForBatch(String batchCode) {
    switch (batchCode) {
      case 'DRC-MINE-8-A3D91C':
        return const [
          ReceptionLotMovement(
            id: 1,
            qrId: 101,
            mineralId: 8,
            workerId: 12,
            previousStatus: MineralLotStatus.extracted,
            newStatus: MineralLotStatus.stored,
            locationName: 'Fosse Nord — Zone A',
            action: 'STOCKAGE_EXTRACTION',
            createdAtLabel: '16/05/2026 09:12',
          ),
          ReceptionLotMovement(
            id: 2,
            qrId: 101,
            mineralId: 8,
            workerId: 12,
            previousStatus: MineralLotStatus.stored,
            newStatus: MineralLotStatus.inTransport,
            locationName: 'Chargement camion',
            action: 'CHARGEMENT_TRANSPORT',
            createdAtLabel: '16/05/2026 10:05',
          ),
          ReceptionLotMovement(
            id: 3,
            qrId: 101,
            mineralId: 8,
            workerId: 7,
            previousStatus: MineralLotStatus.inTransport,
            newStatus: MineralLotStatus.depotReceived,
            locationName: 'Dépôt réception Likasi',
            action: defaultAction,
            createdAtLabel: '16/05/2026 11:20',
          ),
        ];
      default:
        return const [
          ReceptionLotMovement(
            id: 10,
            qrId: 102,
            mineralId: 5,
            workerId: 3,
            previousStatus: MineralLotStatus.inTransport,
            newStatus: MineralLotStatus.depotReceived,
            locationName: 'Dépôt central',
            action: defaultAction,
            createdAtLabel: '15/05/2026 17:45',
          ),
        ];
    }
  }

  static final List<ReceptionLotMovement> recentReceptions = [
    historyForBatch('DRC-MINE-8-A3D91C').last,
    const ReceptionLotMovement(
      id: 11,
      qrId: 105,
      mineralId: 3,
      workerId: 5,
      previousStatus: MineralLotStatus.inTransport,
      newStatus: MineralLotStatus.depotReceived,
      locationName: 'Barrière Sud',
      action: defaultAction,
      createdAtLabel: '18/05/2026 08:42',
    ),
  ];

  static final List<ReceptionAlert> alerts = [
    const ReceptionAlert(
      id: 1,
      type: 'FRAUD',
      message: 'Transition suspecte : STORED → DEPOT_RECEIVED (lot DRC-MINE-1)',
      severity: 'critical',
      time: '10:22',
      source: 'qrcode:104',
    ),
    const ReceptionAlert(
      id: 2,
      type: 'SECURITY',
      message: 'QR invalide sur barrière Sud',
      severity: 'high',
      time: '09:58',
      source: 'security:scan',
    ),
    const ReceptionAlert(
      id: 3,
      type: 'FACE',
      message: 'Visage non reconnu — poste réception 2',
      severity: 'medium',
      time: '09:40',
    ),
    const ReceptionAlert(
      id: 4,
      type: 'IOT',
      message: 'Batterie conteneur faible — CNT-DRC-0002',
      severity: 'low',
      time: '08:15',
    ),
  ];

  static ReceptionQrLot? findQrByBatch(String batch) {
    for (final q in qrLots) {
      if (q.batchCode == batch) return q;
    }
    return null;
  }

  static ReceptionScanResult simulateReceptionScan({
    required String batchCode,
    required String locationName,
    bool faceMatched = true,
    bool qrValid = true,
  }) {
    final lot = findQrByBatch(batchCode);
    if (!faceMatched) {
      return const ReceptionScanResult.failure(
        errorCode: 'FACE_NOT_RECOGNIZED',
        errorMessage: 'Visage non reconnu',
      );
    }
    if (lot == null || !qrValid || !lot.valid) {
      return const ReceptionScanResult.failure(
        errorCode: 'QR_INVALID',
        errorMessage: 'QR code invalide ou falsifié',
      );
    }
    if (lot.currentStatus != MineralLotStatus.inTransport) {
      return ReceptionScanResult.failure(
        errorCode: 'INVALID_TRANSITION',
        errorMessage:
            'Superviseur de réception : transition non autorisée '
            '(${lot.currentStatus} → $targetStatus). '
            'Statut attendu pour votre rôle : $targetStatus',
      );
    }
    return ReceptionScanResult.success(
      ReceptionLotMovement(
        id: 99,
        qrId: lot.id,
        mineralId: lot.mineralId,
        workerId: 7,
        previousStatus: MineralLotStatus.inTransport,
        newStatus: targetStatus,
        locationName: locationName,
        action: defaultAction,
        createdAtLabel: '18/05/2026 ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        comment: null,
      ),
    );
  }

  static ReceptionFraudCheckResult simulateFraudCheck({
    required String batchCode,
    bool faceMatched = true,
  }) {
    final lot = findQrByBatch(batchCode);
    if (!faceMatched) {
      return const ReceptionFraudCheckResult(
        success: false,
        step: 'face_recognition',
        message: 'Accès refusé : visage non reconnu',
      );
    }
    if (lot == null || !lot.valid) {
      return const ReceptionFraudCheckResult(
        success: false,
        step: 'qr_verification',
        message: 'QR code invalide ou falsifié',
      );
    }
    if (lot.currentStatus == MineralLotStatus.blocked) {
      return const ReceptionFraudCheckResult(
        success: false,
        step: 'fraud_detection',
        message: 'Opération bloquée : fraude détectée',
        fraudDetected: true,
      );
    }
    return const ReceptionFraudCheckResult(
      success: true,
      message: 'Visage reconnu, QR valide, aucune fraude détectée',
    );
  }
}

Color receptionSeverityColor(String severity) {
  switch (severity) {
    case 'critical':
      return const Color(0xFFDC2626);
    case 'high':
      return const Color(0xFFEA580C);
    case 'medium':
      return const Color(0xFFFBBF24);
    case 'low':
    default:
      return const Color(0xFF94A3B8);
  }
}

String receptionSeverityLabel(String severity) {
  switch (severity) {
    case 'critical':
      return 'Critique';
    case 'high':
      return 'Élevé';
    case 'medium':
      return 'Modéré';
    case 'low':
    default:
      return 'Info';
  }
}

Color receptionStatusColor(String status) {
  switch (status) {
    case MineralLotStatus.inTransport:
      return const Color(0xFFF59E0B);
    case MineralLotStatus.depotReceived:
      return const Color(0xFF22C55E);
    case MineralLotStatus.stored:
      return const Color(0xFF8B5CF6);
    case MineralLotStatus.extracted:
      return const Color(0xFF3B82F6);
    case MineralLotStatus.blocked:
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF6B7280);
  }
}
