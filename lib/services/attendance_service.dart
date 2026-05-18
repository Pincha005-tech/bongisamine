import '../coree/api/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  AttendanceService._();

  static Future<({bool success, String message, AttendanceModel? attendance})>
      checkIn(int workerId) async {
    final data = await ApiClient.post(
      '/attendances/check-in',
      body: {'worker_id': workerId},
    );
    return _parseResult(data);
  }

  static Future<({bool success, String message, AttendanceModel? attendance})>
      checkOut(int workerId) async {
    final data = await ApiClient.post(
      '/attendances/check-out',
      body: {'worker_id': workerId},
    );
    return _parseResult(data);
  }

  static Future<List<AttendanceModel>> list() async {
    final data = await ApiClient.get('/attendances/');
    return (data as List)
        .map(
          (e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  static Future<List<AttendanceModel>> today() async {
    final data = await ApiClient.get('/attendances/today');
    return (data as List)
        .map(
          (e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  static ({bool success, String message, AttendanceModel? attendance})
      _parseResult(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final att = map['attendance'];
    return (
      success: map['success'] as bool? ?? false,
      message: map['message'] as String? ?? '',
      attendance: att is Map
          ? AttendanceModel.fromJson(Map<String, dynamic>.from(att))
          : null,
    );
  }
}
