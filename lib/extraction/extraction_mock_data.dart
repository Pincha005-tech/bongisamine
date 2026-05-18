import 'package:flutter/material.dart';

class LotStatus {
  static const extracted = 'EXTRACTED';
  static const stored = 'STORED';
  static const inTransport = 'IN_TRANSPORT';
  static const depotReceived = 'DEPOT_RECEIVED';
  static const blocked = 'BLOCKED';
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
  });

  final int id;
  final String type;
  final double weight;
  final String status;
  final double? latitude;
  final double? longitude;
  final bool hasQr;
  final String? batchCode;
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

class ExtractionHomeStats {
  const ExtractionHomeStats({
    required this.lotsExtracted,
    required this.stockagesToday,
    required this.mineralsWithoutQr,
    required this.criticalAlerts,
  });

  final int lotsExtracted;
  final int stockagesToday;
  final int mineralsWithoutQr;
  final int criticalAlerts;
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

class ExtractionMockData {
  ExtractionMockData._();

  static const transitionExtraction = 'EXTRACTED → STORED';
  static const targetStatus = LotStatus.stored;
  static const defaultAction = 'STOCKAGE_EXTRACTION';

  static const homeStats = ExtractionHomeStats(
    lotsExtracted: 11,
    stockagesToday: 18,
    mineralsWithoutQr: 2,
    criticalAlerts: 1,
  );

  static List<ExtractionMineral> minerals = [
    const ExtractionMineral(
      id: 10,
      type: 'Cobalt',
      weight: 1240.5,
      status: 'extracted',
      latitude: -10.7167,
      longitude: 25.4667,
      hasQr: true,
      batchCode: 'DRC-MINE-10-E8A201',
    ),
    const ExtractionMineral(
      id: 11,
      type: 'Cuivre',
      weight: 890.0,
      status: 'extracted',
      latitude: -10.718,
      longitude: 25.47,
      hasQr: true,
      batchCode: 'DRC-MINE-11-C4B902',
    ),
    const ExtractionMineral(
      id: 12,
      type: 'Cobalt',
      weight: 560.25,
      status: 'extracted',
      hasQr: false,
    ),
    const ExtractionMineral(
      id: 13,
      type: 'Or',
      weight: 42.8,
      status: 'extracted',
      hasQr: false,
    ),
  ];

  static final List<ExtractionQrLot> qrLots = [
    const ExtractionQrLot(
      id: 301,
      batchCode: 'DRC-MINE-10-E8A201',
      currentStatus: LotStatus.extracted,
      mineralId: 10,
      valid: true,
      originSite: 'Fosse Nord — Zone A',
    ),
    const ExtractionQrLot(
      id: 302,
      batchCode: 'DRC-MINE-11-C4B902',
      currentStatus: LotStatus.extracted,
      mineralId: 11,
      valid: true,
      originSite: 'Fosse Nord — Zone B',
    ),
    const ExtractionQrLot(
      id: 204,
      batchCode: 'DRC-MINE-4-00EX01',
      currentStatus: LotStatus.extracted,
      mineralId: 4,
      valid: true,
      originSite: 'Fosse Sud',
    ),
    const ExtractionQrLot(
      id: 201,
      batchCode: 'DRC-MINE-2-B91E04',
      currentStatus: LotStatus.stored,
      mineralId: 2,
      valid: true,
    ),
    const ExtractionQrLot(
      id: 104,
      batchCode: 'DRC-MINE-1-FF0099',
      currentStatus: LotStatus.blocked,
      mineralId: 1,
      valid: false,
    ),
  ];

  static List<ExtractionLotMovement> historyForBatch(String batchCode) {
    switch (batchCode) {
      case 'DRC-MINE-10-E8A201':
        return const [
          ExtractionLotMovement(
            id: 1,
            qrId: 301,
            mineralId: 10,
            workerId: 12,
            previousStatus: LotStatus.extracted,
            newStatus: LotStatus.stored,
            locationName: 'Fosse Nord — Zone A',
            action: defaultAction,
            createdAtLabel: '18/05/2026 07:15',
          ),
        ];
      case 'DRC-MINE-2-B91E04':
        return const [
          ExtractionLotMovement(
            id: 2,
            qrId: 201,
            mineralId: 2,
            workerId: 12,
            previousStatus: LotStatus.extracted,
            newStatus: LotStatus.stored,
            locationName: 'Fosse Nord — Zone A',
            action: defaultAction,
            createdAtLabel: '18/05/2026 07:30',
          ),
        ];
      default:
        return const [];
    }
  }

  static final List<ExtractionLotMovement> recentStockages = [
    historyForBatch('DRC-MINE-2-B91E04').first,
    const ExtractionLotMovement(
      id: 3,
      qrId: 303,
      mineralId: 7,
      workerId: 5,
      previousStatus: LotStatus.extracted,
      newStatus: LotStatus.stored,
      locationName: 'Zone tampon extraction',
      action: defaultAction,
      createdAtLabel: '18/05/2026 08:02',
    ),
  ];

  static final List<ExtractionAlert> alerts = [
    const ExtractionAlert(
      id: 1,
      type: 'TRACEABILITY',
      message: 'Lot sans QR tenté en stockage — minerai #13',
      severity: 'critical',
      time: '08:40',
    ),
    const ExtractionAlert(
      id: 2,
      type: 'SECURITY',
      message: 'Visage non reconnu — fosse Nord',
      severity: 'medium',
      time: '08:12',
    ),
    const ExtractionAlert(
      id: 3,
      type: 'QR',
      message: 'Signature QR invalide détectée',
      severity: 'high',
      time: '07:55',
    ),
  ];

  static ExtractionQrLot? findQrByBatch(String batch) {
    for (final q in qrLots) {
      if (q.batchCode == batch) return q;
    }
    return null;
  }

  static ExtractionScanResult simulateExtractionScan({
    required String batchCode,
    required String locationName,
    bool faceMatched = true,
  }) {
    final lot = findQrByBatch(batchCode);
    if (!faceMatched) {
      return const ExtractionScanResult.failure(
        errorCode: 'FACE_NOT_RECOGNIZED',
        errorMessage: 'Visage non reconnu',
      );
    }
    if (lot == null || !lot.valid) {
      return const ExtractionScanResult.failure(
        errorCode: 'QR_INVALID',
        errorMessage: 'QR code invalide ou falsifié',
      );
    }
    if (lot.currentStatus != LotStatus.extracted) {
      return ExtractionScanResult.failure(
        errorCode: 'INVALID_TRANSITION',
        errorMessage:
            'Superviseur d\'extraction : transition non autorisée '
            '(${lot.currentStatus} → $targetStatus). '
            'Statut attendu : ${LotStatus.extracted}',
      );
    }
    return ExtractionScanResult.success(
      ExtractionLotMovement(
        id: 99,
        qrId: lot.id,
        mineralId: lot.mineralId,
        workerId: 12,
        previousStatus: LotStatus.extracted,
        newStatus: targetStatus,
        locationName: locationName,
        action: defaultAction,
        createdAtLabel: '18/05/2026 ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      ),
    );
  }

  static ExtractionMineral simulateCreateMineral({
    required String type,
    required double weight,
  }) {
    final id = minerals.isEmpty ? 1 : minerals.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
    final m = ExtractionMineral(
      id: id,
      type: type,
      weight: weight,
      status: 'extracted',
      latitude: -10.7167,
      longitude: 25.4667,
    );
    minerals = [...minerals, m];
    return m;
  }

  static ExtractionQrGenerateResult simulateGenerateQr(int mineralId) {
    final idx = minerals.indexWhere((m) => m.id == mineralId);
    if (idx < 0) {
      return const ExtractionQrGenerateResult(
        success: false,
        message: 'Minerai non trouvé (404)',
      );
    }
    final m = minerals[idx];
    if (m.hasQr) {
      return const ExtractionQrGenerateResult(
        success: false,
        message: 'QR déjà généré pour ce minerai',
      );
    }
    final batch = 'DRC-MINE-$mineralId-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).substring(0, 6).toUpperCase()}';
    final qr = ExtractionQrLot(
      id: 400 + mineralId,
      batchCode: batch,
      currentStatus: LotStatus.extracted,
      mineralId: mineralId,
      valid: true,
      originSite: 'Fosse Nord',
    );
    qrLots.add(qr);
    minerals = [
      ...minerals.sublist(0, idx),
      ExtractionMineral(
        id: m.id,
        type: m.type,
        weight: m.weight,
        status: m.status,
        latitude: m.latitude,
        longitude: m.longitude,
        hasQr: true,
        batchCode: batch,
      ),
      ...minerals.sublist(idx + 1),
    ];
    return ExtractionQrGenerateResult(
      success: true,
      message: 'POST /qrcodes/mineral/$mineralId — QR créé',
      qr: qr,
    );
  }
}

Color extractionSeverityColor(String severity) {
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

String extractionSeverityLabel(String severity) {
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

Color extractionStatusColor(String status) {
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
