import '../models/admin_dashboard_snapshot.dart';
import 'api_service.dart';

class AdminDashboardLoader {
  static Future<AdminDashboardSnapshot> load() async {
    final profile = await ApiService.getUserProfile();
    final dashboard = await ApiService.fetchDashboard();
    final daily = await ApiService.fetchDailyReport();
    final minerals = await ApiService.fetchMinerals();
    final alertsRaw = await ApiService.fetchAlerts(limit: 8);
    final historyRaw = await ApiService.fetchMineralHistory();
    final attendancesRaw = await ApiService.fetchAttendancesToday();
    final workers = await ApiService.fetchWorkers();
    final txCount = await ApiService.fetchTransactionsCount();
    final blocks = await ApiService.fetchBlockchain();
    final chainValid = await ApiService.fetchBlockchainValid();

    final connected = dashboard != null || daily != null;
    final workerNames = <int, String>{};
    if (workers != null) {
      for (final w in workers) {
        final id = int.tryParse(w.id);
        if (id != null) workerNames[id] = w.name;
      }
    }

    var present = 0;
    var late = 0;
    var completed = 0;
    if (daily != null) {
      final att = daily['attendance'];
      if (att is Map) {
        present = att['total_present'] as int? ?? 0;
        late = att['total_late'] as int? ?? 0;
        completed = att['total_completed'] as int? ?? 0;
      }
    }

    final statusCounts = <String, int>{};
    var inTransport = 0;
    var blocked = 0;
    var weight = 0.0;
    for (final m in minerals) {
      final status = ApiService.normalizeMineralStatus(m['status'] as String?);
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      if (status.contains('TRANSPORT')) inTransport++;
      if (status.contains('BLOCK')) blocked++;
      final w = m['weight'];
      if (w is num) weight += w.toDouble();
    }

    final alerts = alertsRaw
        .map(
          (a) => AdminAlertRow(
            message: a['message'] as String? ?? 'Alerte',
            severity: (a['severity'] as String? ?? 'low').toLowerCase(),
            type: a['type'] as String? ?? 'info',
            time: ApiService.formatDateTime(a['created_at'] as String?),
          ),
        )
        .toList();

    final history = historyRaw.take(6).map((h) {
      final action = h['action'] as String? ?? 'Action';
      final desc = h['description'] as String? ?? '';
      final wid = h['worker_id'] as int?;
      final actor = wid != null
          ? (workerNames[wid] ?? 'Travailleur #$wid')
          : 'Système';
      return AdminHistoryRow(
        title: action,
        subtitle: desc.isEmpty ? actor : '$actor · $desc',
        time: ApiService.formatDateTime(h['created_at'] as String?),
      );
    }).toList();

    final attendances = attendancesRaw.take(8).map((a) {
      final wid = a['worker_id'] as int?;
      return AdminAttendanceRow(
        workerName: workerNames[wid] ?? 'Travailleur ${wid ?? '?'}',
        status: a['status'] as String? ?? 'present',
        checkIn: ApiService.formatDateTime(a['check_in'] as String?),
        checkOut: ApiService.formatDateTime(a['check_out'] as String?),
      );
    }).toList();

    final blockRows = <AdminBlockRow>[];
    if (blocks != null) {
      for (final b in blocks.take(5)) {
        final data = b['data'] as String? ?? '';
        blockRows.add(
          AdminBlockRow(
            index: b['index'] as int? ?? 0,
            eventLabel: _eventFromBlockData(data),
            hashPreview: _hashPreview(b['hash'] as String?),
            time: ApiService.formatDateTime(b['timestamp'] as String?),
          ),
        );
      }
    }

    return AdminDashboardSnapshot(
      backendConnected: connected,
      userName: profile['name'] as String? ?? 'Administrateur',
      roleLabel: ApiService.roleLabel(profile['role'] as String?),
      todayLabel: ApiService.formatDisplayDate(DateTime.now()),
      presentToday: present,
      lateToday: late,
      completedToday: completed,
      workersTotal: dashboard?['workers'] as int? ??
          (daily?['workers'] is Map
              ? (daily!['workers'] as Map)['total'] as int? ?? 0
              : 0),
      mineralsTotal:
          dashboard?['minerals'] as int? ?? minerals.length,
      mineralsInTransport: inTransport,
      mineralsBlocked: blocked,
      totalWeightKg: weight,
      criticalAlerts: dashboard?['critical_alerts'] as int? ??
          (daily?['alerts'] is Map
              ? (daily!['alerts'] as Map)['critical'] as int? ?? 0
              : 0),
      alertsTotal: dashboard?['alerts'] as int? ?? alerts.length,
      qrcodesTotal: dashboard?['qrcodes'] as int? ?? 0,
      lotMovements: dashboard?['lot_movements'] as int? ??
          (daily?['traceability'] is Map
              ? (daily!['traceability'] as Map)['total_movements'] as int? ?? 0
              : 0),
      transactionsCount: txCount ?? 0,
      blocksTotal: dashboard?['blocks'] as int? ?? (blocks?.length ?? 0),
      blockchainValid: chainValid,
      statusByMineral: statusCounts,
      alerts: alerts,
      recentHistory: history,
      todayAttendances: attendances,
      recentBlocks: blockRows,
      dailyReport: daily,
    );
  }

  static String _hashPreview(String? hash) {
    if (hash == null || hash.length < 12) return hash ?? '—';
    return '${hash.substring(0, 8)}…';
  }

  static String _eventFromBlockData(String data) {
    if (data.contains('FRAUD')) return 'FRAUD_DETECTED';
    if (data.contains('QR')) return 'QR_CREATED';
    if (data.contains('LOT') || data.contains('MOVEMENT')) {
      return 'LOT_MOVEMENT';
    }
    return 'ÉVÉNEMENT';
  }
}
