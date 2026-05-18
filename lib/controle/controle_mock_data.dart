import 'package:flutter/material.dart';

/// Ouvrier — aligné `WorkerResponse` backend.
class ControleWorker {
  const ControleWorker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.badgeId,
    this.departmentRole,
    this.faceRegistered = false,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String role;
  final String badgeId;
  final String? departmentRole;
  final bool faceRegistered;

  String get fullName => '$firstName $lastName';
}

class ControleAttendance {
  const ControleAttendance({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.status,
    this.checkInLabel,
    this.checkOutLabel,
  });

  final int id;
  final int workerId;
  final String workerName;
  final String status;
  final String? checkInLabel;
  final String? checkOutLabel;
}

class ControleHomeStats {
  const ControleHomeStats({
    required this.totalWorkers,
    required this.presentToday,
    required this.facesRegistered,
    required this.pendingCheckIn,
  });

  final int totalWorkers;
  final int presentToday;
  final int facesRegistered;
  final int pendingCheckIn;
}

class ControleFaceRegisterResult {
  const ControleFaceRegisterResult({
    required this.success,
    required this.message,
    this.faceId,
  });

  final bool success;
  final String message;
  final int? faceId;
}

class ControleFaceRecognizeResult {
  const ControleFaceRecognizeResult({
    required this.match,
    required this.message,
    this.workerId,
    this.workerName,
  });

  final bool match;
  final String message;
  final int? workerId;
  final String? workerName;
}

class ControleMockData {
  ControleMockData._();

  static List<ControleWorker> workers = [
    const ControleWorker(
      id: 1,
      firstName: 'Jean',
      lastName: 'Mukendi',
      role: 'mineur',
      badgeId: 'BADGE-001',
      departmentRole: 'Extraction',
      faceRegistered: true,
    ),
    const ControleWorker(
      id: 2,
      firstName: 'Marie',
      lastName: 'Kabila',
      role: 'mineur',
      badgeId: 'BADGE-002',
      departmentRole: 'Sécurité',
      faceRegistered: true,
    ),
    const ControleWorker(
      id: 3,
      firstName: 'Pierre',
      lastName: 'Tshibangu',
      role: 'technicien',
      badgeId: 'BADGE-003',
      departmentRole: 'Maintenance',
      faceRegistered: false,
    ),
    const ControleWorker(
      id: 4,
      firstName: 'Anne',
      lastName: 'Mbuyi',
      role: 'mineur',
      badgeId: 'BADGE-004',
      departmentRole: 'Extraction',
      faceRegistered: true,
    ),
    const ControleWorker(
      id: 5,
      firstName: 'Charles',
      lastName: 'Ilunga',
      role: 'logistique',
      badgeId: 'BADGE-005',
      departmentRole: 'Logistique',
      faceRegistered: false,
    ),
    const ControleWorker(
      id: 12,
      firstName: 'David',
      lastName: 'Kasongo',
      role: 'mineur',
      badgeId: 'BADGE-012',
      departmentRole: 'Extraction',
      faceRegistered: true,
    ),
  ];

  static List<ControleAttendance> todayAttendances = [
    const ControleAttendance(
      id: 101,
      workerId: 1,
      workerName: 'Jean Mukendi',
      status: 'present',
      checkInLabel: '06:42',
      checkOutLabel: null,
    ),
    const ControleAttendance(
      id: 102,
      workerId: 2,
      workerName: 'Marie Kabila',
      status: 'present',
      checkInLabel: '06:38',
      checkOutLabel: null,
    ),
    const ControleAttendance(
      id: 103,
      workerId: 4,
      workerName: 'Anne Mbuyi',
      status: 'checked_out',
      checkInLabel: '06:15',
      checkOutLabel: '14:02',
    ),
    const ControleAttendance(
      id: 104,
      workerId: 12,
      workerName: 'David Kasongo',
      status: 'present',
      checkInLabel: '07:10',
      checkOutLabel: null,
    ),
  ];

  static ControleHomeStats get homeStats => ControleHomeStats(
        totalWorkers: workers.length,
        presentToday: todayAttendances
            .where((a) => a.status == 'present' || a.status == 'checked_out')
            .length,
        facesRegistered: workers.where((w) => w.faceRegistered).length,
        pendingCheckIn: workers.length -
            todayAttendances
                .where((a) => a.status == 'present' || a.status == 'checked_out')
                .length,
      );

  static ControleWorker? findWorker(int id) {
    for (final w in workers) {
      if (w.id == id) return w;
    }
    return null;
  }

  static ControleWorker simulateCreateWorker({
    required String firstName,
    required String lastName,
    required String role,
    required String badgeId,
    String? departmentRole,
  }) {
    final id = workers.isEmpty
        ? 1
        : workers.map((w) => w.id).reduce((a, b) => a > b ? a : b) + 1;
    final w = ControleWorker(
      id: id,
      firstName: firstName,
      lastName: lastName,
      role: role,
      badgeId: badgeId,
      departmentRole: departmentRole,
    );
    workers = [...workers, w];
    return w;
  }

  static bool simulateUpdateWorker(
    int id, {
    String? firstName,
    String? lastName,
    String? role,
    String? badgeId,
    String? departmentRole,
  }) {
    final idx = workers.indexWhere((w) => w.id == id);
    if (idx < 0) return false;
    final o = workers[idx];
    workers = [
      ...workers.sublist(0, idx),
      ControleWorker(
        id: o.id,
        firstName: firstName ?? o.firstName,
        lastName: lastName ?? o.lastName,
        role: role ?? o.role,
        badgeId: badgeId ?? o.badgeId,
        departmentRole: departmentRole ?? o.departmentRole,
        faceRegistered: o.faceRegistered,
      ),
      ...workers.sublist(idx + 1),
    ];
    return true;
  }

  static bool simulateDeleteWorker(int id) {
    final before = workers.length;
    workers = workers.where((w) => w.id != id).toList();
    todayAttendances =
        todayAttendances.where((a) => a.workerId != id).toList();
    return workers.length < before;
  }

  static ControleAttendance? simulateCheckIn(int workerId) {
    final w = findWorker(workerId);
    if (w == null) return null;
    final existing = todayAttendances.indexWhere((a) => a.workerId == workerId);
    if (existing >= 0 && todayAttendances[existing].status == 'present') {
      return null;
    }
    final now = _timeLabel();
    final att = ControleAttendance(
      id: 200 + workerId,
      workerId: workerId,
      workerName: w.fullName,
      status: 'present',
      checkInLabel: now,
    );
    if (existing >= 0) {
      todayAttendances = [
        ...todayAttendances.sublist(0, existing),
        att,
        ...todayAttendances.sublist(existing + 1),
      ];
    } else {
      todayAttendances = [...todayAttendances, att];
    }
    return att;
  }

  static ControleAttendance? simulateCheckOut(int workerId) {
    final idx = todayAttendances.indexWhere(
      (a) => a.workerId == workerId && a.status == 'present',
    );
    if (idx < 0) return null;
    final a = todayAttendances[idx];
    final updated = ControleAttendance(
      id: a.id,
      workerId: a.workerId,
      workerName: a.workerName,
      status: 'checked_out',
      checkInLabel: a.checkInLabel,
      checkOutLabel: _timeLabel(),
    );
    todayAttendances = [
      ...todayAttendances.sublist(0, idx),
      updated,
      ...todayAttendances.sublist(idx + 1),
    ];
    return updated;
  }

  static ControleFaceRegisterResult simulateRegisterFace(int workerId) {
    final idx = workers.indexWhere((w) => w.id == workerId);
    if (idx < 0) {
      return const ControleFaceRegisterResult(
        success: false,
        message: 'Ouvrier non trouvé',
      );
    }
    final o = workers[idx];
    if (o.faceRegistered) {
      return const ControleFaceRegisterResult(
        success: false,
        message: 'Visage déjà enregistré',
      );
    }
    workers = [
      ...workers.sublist(0, idx),
      ControleWorker(
        id: o.id,
        firstName: o.firstName,
        lastName: o.lastName,
        role: o.role,
        badgeId: o.badgeId,
        departmentRole: o.departmentRole,
        faceRegistered: true,
      ),
      ...workers.sublist(idx + 1),
    ];
    return ControleFaceRegisterResult(
      success: true,
      message: 'Visage enregistré',
      faceId: 1000 + workerId,
    );
  }

  static ControleFaceRecognizeResult simulateRecognizeFace({
    required int? selectedWorkerId,
    bool simulateMatch = true,
  }) {
    if (!simulateMatch) {
      return const ControleFaceRecognizeResult(
        match: false,
        message: 'Aucun visage reconnu',
      );
    }
    final id = selectedWorkerId ?? workers.firstWhere((w) => w.faceRegistered).id;
    final w = findWorker(id);
    if (w == null || !w.faceRegistered) {
      return const ControleFaceRecognizeResult(
        match: false,
        message: 'Visage non enregistré pour cet ouvrier',
      );
    }
    return ControleFaceRecognizeResult(
      match: true,
      message: 'Visage reconnu',
      workerId: w.id,
      workerName: w.fullName,
    );
  }

  static String _timeLabel() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }
}

Color controleStatusColor(String status) {
  switch (status) {
    case 'present':
      return const Color(0xFF22C55E);
    case 'checked_out':
      return const Color(0xFF94A3B8);
    case 'absent':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF6B7280);
  }
}

String controleAttendanceLabel(String status) {
  switch (status) {
    case 'present':
      return 'Présent';
    case 'checked_out':
      return 'Sorti';
    default:
      return status;
  }
}
