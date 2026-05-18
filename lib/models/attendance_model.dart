class AttendanceModel {
  const AttendanceModel({
    required this.id,
    required this.workerId,
    required this.attendanceDate,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.createdAt,
  });

  final int id;
  final int workerId;
  final String attendanceDate;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status;
  final DateTime? createdAt;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int,
      workerId: json['worker_id'] as int,
      attendanceDate: json['attendance_date']?.toString() ?? '',
      checkIn: json['check_in'] != null
          ? DateTime.tryParse(json['check_in'].toString())
          : null,
      checkOut: json['check_out'] != null
          ? DateTime.tryParse(json['check_out'].toString())
          : null,
      status: json['status'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  String get checkInLabel {
    if (checkIn == null) return '—';
    return '${checkIn!.hour.toString().padLeft(2, '0')}:${checkIn!.minute.toString().padLeft(2, '0')}';
  }
}
