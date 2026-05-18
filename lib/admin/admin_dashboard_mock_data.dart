import 'package:flutter/material.dart';

/// Données de démonstration — remplacées par l’API plus tard.
class AdminSystemStatus {
  const AdminSystemStatus({
    required this.online,
    required this.synced,
    required this.backendConnected,
  });

  final bool online;
  final bool synced;
  final bool backendConnected;
}

class AdminKpis {
  const AdminKpis({
    required this.workersPresent,
    required this.activeLots,
    required this.lotsInTransport,
    required this.criticalAlerts,
    required this.fraudsDetected,
    required this.activeQrCodes,
    required this.transactionsToday,
    required this.blockchainValid,
  });

  final int workersPresent;
  final int activeLots;
  final int lotsInTransport;
  final int criticalAlerts;
  final int fraudsDetected;
  final int activeQrCodes;
  final int transactionsToday;
  final bool blockchainValid;
}

class LotStatusCount {
  const LotStatusCount(this.code, this.count, this.color);
  final String code;
  final int count;
  final Color color;
}

class LotMovementMock {
  const LotMovementMock({
    required this.batchCode,
    required this.fromStatus,
    required this.toStatus,
    required this.location,
    required this.dateLabel,
    required this.actorLabel,
  });

  final String batchCode;
  final String fromStatus;
  final String toStatus;
  final String location;
  final String dateLabel;
  final String actorLabel;
}

class AlertMock {
  const AlertMock({
    required this.title,
    required this.severity,
    required this.time,
  });

  final String title;
  final String severity;
  final String time;
}

class PresenceMock {
  const PresenceMock({
    required this.presentToday,
    required this.lateToday,
    required this.exitsToday,
  });

  final int presentToday;
  final int lateToday;
  final int exitsToday;
}

class CheckInOutMock {
  const CheckInOutMock({
    required this.worker,
    required this.type,
    required this.time,
  });

  final String worker;
  final String type;
  final String time;
}

class BlockchainMock {
  const BlockchainMock({
    required this.chainValid,
    required this.blockCount,
    required this.lastBlockHashPreview,
    required this.lastEventType,
    required this.actorHashPreview,
  });

  final bool chainValid;
  final int blockCount;
  final String lastBlockHashPreview;
  final String lastEventType;
  final String actorHashPreview;
}

class QrOverviewMock {
  const QrOverviewMock({
    required this.totalQr,
    required this.activeQr,
    required this.linkedToBlockedLots,
  });

  final int totalQr;
  final int activeQr;
  final int linkedToBlockedLots;
}

class QrRowMock {
  const QrRowMock({
    required this.batchCode,
    required this.status,
    required this.lotLabel,
    required this.createdAt,
  });

  final String batchCode;
  final String status;
  final String lotLabel;
  final String createdAt;
}

class IotContainerMock {
  const IotContainerMock({
    required this.code,
    required this.status,
    required this.gpsLabel,
    required this.batteryPercent,
    required this.speedKmh,
    required this.lastSignal,
    required this.alert,
  });

  final String code;
  final String status;
  final String gpsLabel;
  final int batteryPercent;
  final double speedKmh;
  final String lastSignal;
  final String? alert;
}

class DailyReportMock {
  const DailyReportMock({
    required this.dateLabel,
    required this.presenceSummary,
    required this.productionSummary,
    required this.alertsSummary,
    required this.chainSummary,
  });

  final String dateLabel;
  final String presenceSummary;
  final String productionSummary;
  final String alertsSummary;
  final String chainSummary;
}

class AdminDashboardMock {
  AdminDashboardMock._();

  static const system = AdminSystemStatus(
    online: true,
    synced: true,
    backendConnected: false,
  );

  static const kpis = AdminKpis(
    workersPresent: 186,
    activeLots: 42,
    lotsInTransport: 7,
    criticalAlerts: 3,
    fraudsDetected: 1,
    activeQrCodes: 128,
    transactionsToday: 54,
    blockchainValid: true,
  );

  static const totalMineralsTracked = 42;
  static const totalWeightExtractedT = 1240.5;
  static const blockedOrSuspiciousLots = 2;
  static const exportedLots = 11;

  static const lotByStatus = <LotStatusCount>[
    LotStatusCount('EXTRACTED', 8, Color(0xFF3B82F6)),
    LotStatusCount('STORED', 9, Color(0xFF8B5CF6)),
    LotStatusCount('IN_TRANSPORT', 7, Color(0xFFF59E0B)),
    LotStatusCount('DEPOT_RECEIVED', 6, Color(0xFF22C55E)),
    LotStatusCount('EXPORT_READY', 4, Color(0xFF1E3A8A)),
    LotStatusCount('EXPORTED', 11, Color(0xFF14532D)),
    LotStatusCount('BLOCKED', 2, Color(0xFFDC2626)),
  ];

  static const movements = <LotMovementMock>[
    LotMovementMock(
      batchCode: 'DRC-MINE-8-A3D91C',
      fromStatus: 'STORED',
      toStatus: 'IN_TRANSPORT',
      location: 'Route Kolwezi-Likasi',
      dateLabel: '16/05/2026 10:30',
      actorLabel: 'Acteur a7f3…9c2',
    ),
    LotMovementMock(
      batchCode: 'DRC-MINE-2-B91E04',
      fromStatus: 'EXTRACTED',
      toStatus: 'STORED',
      location: 'Fosse Nord — Zone A',
      dateLabel: '16/05/2026 09:12',
      actorLabel: 'Superviseur hash e441…',
    ),
    LotMovementMock(
      batchCode: 'DRC-MINE-5-CC812A',
      fromStatus: 'IN_TRANSPORT',
      toStatus: 'DEPOT_RECEIVED',
      location: 'Dépôt central Likasi',
      dateLabel: '15/05/2026 17:45',
      actorLabel: 'Système IoT CNT-DRC-0001',
    ),
  ];

  static const alerts = <AlertMock>[
    AlertMock(
      title: 'Tentative de double scan — lot DRC-MINE-1',
      severity: 'critical',
      time: '10:22',
    ),
    AlertMock(
      title: 'QR invalide sur barrière Sud',
      severity: 'high',
      time: '09:58',
    ),
    AlertMock(
      title: 'Visage non reconnu — poste 3',
      severity: 'medium',
      time: '09:40',
    ),
    AlertMock(
      title: 'Batterie conteneur faible',
      severity: 'low',
      time: '08:15',
    ),
  ];

  static const presence = PresenceMock(
    presentToday: 186,
    lateToday: 14,
    exitsToday: 52,
  );

  static const recentChecks = <CheckInOutMock>[
    CheckInOutMock(worker: 'J. Mukendi', type: 'Check-in', time: '08:14'),
    CheckInOutMock(worker: 'M. Kabila', type: 'Check-out', time: '08:02'),
    CheckInOutMock(worker: 'P. Tshibangu', type: 'Check-in', time: '07:55'),
  ];

  static const blockchain = BlockchainMock(
    chainValid: true,
    blockCount: 1842,
    lastBlockHashPreview: '0x8f…c21',
    lastEventType: 'LOT_MOVEMENT',
    actorHashPreview: 'sha256:9a2f…e11',
  );

  static const qrOverview = QrOverviewMock(
    totalQr: 156,
    activeQr: 128,
    linkedToBlockedLots: 2,
  );

  static const recentQrs = <QrRowMock>[
    QrRowMock(
      batchCode: 'DRC-MINE-8-A3D91C',
      status: 'ACTIF',
      lotLabel: 'Cobalt brut — Fosse 8',
      createdAt: '15/05/2026 14:10',
    ),
    QrRowMock(
      batchCode: 'DRC-MINE-3-77AB01',
      status: 'ACTIF',
      lotLabel: 'Cuivre — Ligne B',
      createdAt: '15/05/2026 11:02',
    ),
    QrRowMock(
      batchCode: 'DRC-MINE-1-FF0099',
      status: 'BLOQUÉ',
      lotLabel: 'Anomalie pesée',
      createdAt: '14/05/2026 16:40',
    ),
  ];

  static const iotContainers = <IotContainerMock>[
    IotContainerMock(
      code: 'CNT-DRC-0001',
      status: 'IN_TRANSPORT',
      gpsLabel: '−11.6647, 27.4794',
      batteryPercent: 62,
      speedKmh: 38.5,
      lastSignal: '16/05/2026 10:28',
      alert: null,
    ),
    IotContainerMock(
      code: 'CNT-DRC-0002',
      status: 'ALERT',
      gpsLabel: '−11.6712, 27.4681',
      batteryPercent: 18,
      speedKmh: 0,
      lastSignal: '16/05/2026 09:50',
      alert: 'Batterie faible — arrêt prolongé',
    ),
  ];

  static const dailyReport = DailyReportMock(
    dateLabel: '16 mai 2026',
    presenceSummary: '186 présents, 14 retards, 52 sorties enregistrées.',
    productionSummary:
        '7 lots en transport, 1240,5 t cumulées extraites, 2 lots bloqués.',
    alertsSummary: '3 alertes critiques, 1 fraude signalée.',
    chainSummary: 'Chaîne valide — 1842 blocs — dernier LOT_MOVEMENT.',
  );
}

Color severityColor(String severity) {
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

String severityLabelFr(String severity) {
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

String formatFrenchFullDate(DateTime d) {
  const months = <String>[
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
