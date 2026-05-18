import 'package:flutter/material.dart';

/// Données agrégées pour le centre de contrôle administrateur.
class AdminDashboardSnapshot {
  const AdminDashboardSnapshot({
    required this.backendConnected,
    required this.userName,
    required this.roleLabel,
    required this.todayLabel,
    this.presentToday = 0,
    this.lateToday = 0,
    this.completedToday = 0,
    this.workersTotal = 0,
    this.mineralsTotal = 0,
    this.mineralsInTransport = 0,
    this.mineralsBlocked = 0,
    this.totalWeightKg = 0,
    this.criticalAlerts = 0,
    this.alertsTotal = 0,
    this.qrcodesTotal = 0,
    this.lotMovements = 0,
    this.transactionsCount = 0,
    this.blocksTotal = 0,
    this.blockchainValid,
    this.statusByMineral = const {},
    this.alerts = const [],
    this.recentHistory = const [],
    this.todayAttendances = const [],
    this.recentBlocks = const [],
    this.dailyReport,
  });

  final bool backendConnected;
  final String userName;
  final String roleLabel;
  final String todayLabel;

  final int presentToday;
  final int lateToday;
  final int completedToday;
  final int workersTotal;
  final int mineralsTotal;
  final int mineralsInTransport;
  final int mineralsBlocked;
  final double totalWeightKg;
  final int criticalAlerts;
  final int alertsTotal;
  final int qrcodesTotal;
  final int lotMovements;
  final int transactionsCount;
  final int blocksTotal;
  final bool? blockchainValid;

  final Map<String, int> statusByMineral;
  final List<AdminAlertRow> alerts;
  final List<AdminHistoryRow> recentHistory;
  final List<AdminAttendanceRow> todayAttendances;
  final List<AdminBlockRow> recentBlocks;
  final Map<String, dynamic>? dailyReport;
}

class AdminAlertRow {
  const AdminAlertRow({
    required this.message,
    required this.severity,
    required this.time,
    required this.type,
  });

  final String message;
  final String severity;
  final String time;
  final String type;
}

class AdminHistoryRow {
  const AdminHistoryRow({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final String title;
  final String subtitle;
  final String time;
}

class AdminAttendanceRow {
  const AdminAttendanceRow({
    required this.workerName,
    required this.status,
    required this.checkIn,
    required this.checkOut,
  });

  final String workerName;
  final String status;
  final String checkIn;
  final String checkOut;
}

class AdminBlockRow {
  const AdminBlockRow({
    required this.index,
    required this.eventLabel,
    required this.hashPreview,
    required this.time,
  });

  final int index;
  final String eventLabel;
  final String hashPreview;
  final String time;
}

class AdminStatTone {
  const AdminStatTone(this.color);
  final Color color;
}
