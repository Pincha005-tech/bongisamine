import 'package:flutter/material.dart';

/// Statuts lots — `mine_back` traceability_service.
class LotStatus {
  static const extracted = 'EXTRACTED';
  static const stored = 'STORED';
  static const inTransport = 'IN_TRANSPORT';
  static const depotReceived = 'DEPOT_RECEIVED';
  static const blocked = 'BLOCKED';
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
    this.source,
  });

  final int id;
  final String type;
  final String message;
  final String severity;
  final String time;
  final String? source;
}

class TransportHomeStats {
  const TransportHomeStats({
    required this.lotsReadyToLoad,
    required this.loadsToday,
    required this.lotsInTransit,
    required this.criticalAlerts,
  });

  final int lotsReadyToLoad;
  final int loadsToday;
  final int lotsInTransit;
  final int criticalAlerts;
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
    required this.success,
    required this.message,
    this.step,
    this.batchCode,
    this.currentStatus,
  });

  final bool success;
  final String message;
  final String? step;
  final String? batchCode;
  final String? currentStatus;
}

class TransportMockData {
  TransportMockData._();

  static const transitionTransport = 'STORED → IN_TRANSPORT';
  static const targetStatus = LotStatus.inTransport;
  static const defaultAction = 'CHARGEMENT_TRANSPORT';

  static const homeStats = TransportHomeStats(
    lotsReadyToLoad: 9,
    loadsToday: 15,
    lotsInTransit: 7,
    criticalAlerts: 1,
  );

  static final List<TransportQrLot> qrLots = [
    const TransportQrLot(
      id: 201,
      batchCode: 'DRC-MINE-2-B91E04',
      currentStatus: LotStatus.stored,
      mineralId: 2,
      valid: true,
    ),
    const TransportQrLot(
      id: 202,
      batchCode: 'DRC-MINE-6-D4F210',
      currentStatus: LotStatus.stored,
      mineralId: 6,
      valid: true,
    ),
    const TransportQrLot(
      id: 203,
      batchCode: 'DRC-MINE-9-11AC02',
      currentStatus: LotStatus.stored,
      mineralId: 9,
      valid: true,
    ),
    const TransportQrLot(
      id: 101,
      batchCode: 'DRC-MINE-8-A3D91C',
      currentStatus: LotStatus.inTransport,
      mineralId: 8,
      valid: true,
    ),
    const TransportQrLot(
      id: 104,
      batchCode: 'DRC-MINE-1-FF0099',
      currentStatus: LotStatus.blocked,
      mineralId: 1,
      valid: false,
    ),
    const TransportQrLot(
      id: 204,
      batchCode: 'DRC-MINE-4-00EX01',
      currentStatus: LotStatus.extracted,
      mineralId: 4,
      valid: true,
    ),
  ];

  static List<TransportLotMovement> historyForBatch(String batchCode) {
    switch (batchCode) {
      case 'DRC-MINE-2-B91E04':
        return const [
          TransportLotMovement(
            id: 1,
            qrId: 201,
            mineralId: 2,
            workerId: 12,
            previousStatus: LotStatus.extracted,
            newStatus: LotStatus.stored,
            locationName: 'Fosse Nord — Zone A',
            action: 'STOCKAGE_EXTRACTION',
            createdAtLabel: '18/05/2026 07:30',
          ),
        ];
      case 'DRC-MINE-8-A3D91C':
        return const [
          TransportLotMovement(
            id: 10,
            qrId: 101,
            mineralId: 8,
            workerId: 12,
            previousStatus: LotStatus.extracted,
            newStatus: LotStatus.stored,
            locationName: 'Fosse Nord — Zone A',
            action: 'STOCKAGE_EXTRACTION',
            createdAtLabel: '16/05/2026 09:12',
          ),
          TransportLotMovement(
            id: 11,
            qrId: 101,
            mineralId: 8,
            workerId: 4,
            previousStatus: LotStatus.stored,
            newStatus: LotStatus.inTransport,
            locationName: 'Quai chargement Kolwezi',
            action: defaultAction,
            createdAtLabel: '16/05/2026 10:05',
          ),
        ];
      default:
        return const [];
    }
  }

  static final List<TransportLotMovement> recentLoads = [
    TransportLotMovement(
      id: 20,
      qrId: 101,
      mineralId: 8,
      workerId: 4,
      previousStatus: LotStatus.stored,
      newStatus: LotStatus.inTransport,
      locationName: 'Route Kolwezi-Likasi',
      action: defaultAction,
      createdAtLabel: '18/05/2026 09:15',
    ),
    const TransportLotMovement(
      id: 21,
      qrId: 205,
      mineralId: 7,
      workerId: 8,
      previousStatus: LotStatus.stored,
      newStatus: LotStatus.inTransport,
      locationName: 'Parking camions Sud',
      action: defaultAction,
      createdAtLabel: '18/05/2026 08:50',
    ),
  ];

  static final List<TransportAlert> alerts = [
    const TransportAlert(
      id: 1,
      type: 'TRACEABILITY',
      message: 'Tentative chargement sans stockage — lot DRC-MINE-4',
      severity: 'critical',
      time: '09:10',
      source: 'qrcode:204',
    ),
    const TransportAlert(
      id: 2,
      type: 'SECURITY',
      message: 'Visage non reconnu — quai chargement 1',
      severity: 'medium',
      time: '08:55',
    ),
    const TransportAlert(
      id: 3,
      type: 'GPS',
      message: 'Écart de position sur route Kolwezi-Likasi',
      severity: 'low',
      time: '08:20',
    ),
  ];

  static TransportQrLot? findQrByBatch(String batch) {
    for (final q in qrLots) {
      if (q.batchCode == batch) return q;
    }
    return null;
  }

  static TransportScanResult simulateTransportScan({
    required String batchCode,
    required String locationName,
    bool faceMatched = true,
  }) {
    final lot = findQrByBatch(batchCode);
    if (!faceMatched) {
      return const TransportScanResult.failure(
        errorCode: 'FACE_NOT_RECOGNIZED',
        errorMessage: 'Visage non reconnu',
      );
    }
    if (lot == null || !lot.valid) {
      return const TransportScanResult.failure(
        errorCode: 'QR_INVALID',
        errorMessage: 'QR code invalide ou falsifié',
      );
    }
    if (lot.currentStatus != LotStatus.stored) {
      return TransportScanResult.failure(
        errorCode: 'INVALID_TRANSITION',
        errorMessage:
            'Superviseur de transport : transition non autorisée '
            '(${lot.currentStatus} → $targetStatus). '
            'Statut attendu pour votre rôle : $targetStatus',
      );
    }
    return TransportScanResult.success(
      TransportLotMovement(
        id: 99,
        qrId: lot.id,
        mineralId: lot.mineralId,
        workerId: 4,
        previousStatus: LotStatus.stored,
        newStatus: targetStatus,
        locationName: locationName,
        action: defaultAction,
        createdAtLabel: '18/05/2026 ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      ),
    );
  }

  static TransportSecureReadResult simulateSecureRead({
    required String batchCode,
    bool faceMatched = true,
  }) {
    final lot = findQrByBatch(batchCode);
    if (!faceMatched) {
      return const TransportSecureReadResult(
        success: false,
        step: 'face_recognition',
        message: 'Accès refusé : visage non reconnu',
      );
    }
    if (lot == null || !lot.valid) {
      return const TransportSecureReadResult(
        success: false,
        step: 'qr_verification',
        message: 'QR code invalide ou falsifié',
      );
    }
    return TransportSecureReadResult(
      success: true,
      message: 'Accès autorisé : QR code vérifié',
      batchCode: lot.batchCode,
      currentStatus: lot.currentStatus,
    );
  }
}

Color transportSeverityColor(String severity) {
  switch (severity) {
    case 'critical':
      return const Color(0xFFDC2626);
    case 'high':
      return const Color(0xFFEA580C);
    case 'medium':
      return const Color(0xFFFBBF24);
    default:
      return const Color(0xFF94A3B8);
  }
}

String transportSeverityLabel(String severity) {
  switch (severity) {
    case 'critical':
      return 'Critique';
    case 'high':
      return 'Élevé';
    case 'medium':
      return 'Modéré';
    default:
      return 'Info';
  }
}

Color transportStatusColor(String status) {
  switch (status) {
    case LotStatus.inTransport:
      return const Color(0xFFF59E0B);
    case LotStatus.stored:
      return const Color(0xFF8B5CF6);
    case LotStatus.extracted:
      return const Color(0xFF3B82F6);
    case LotStatus.depotReceived:
      return const Color(0xFF22C55E);
    case LotStatus.blocked:
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF6B7280);
  }
}
