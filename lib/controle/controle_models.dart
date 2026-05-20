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
