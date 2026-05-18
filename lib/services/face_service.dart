import '../coree/api/api_client.dart';

class FaceService {
  FaceService._();

  static Future<FaceRegisterResult> register(int workerId, String imagePath) async {
    final data = await ApiClient.postMultipart(
      '/face/register/$workerId',
      fileField: 'file',
      filePath: imagePath,
    );
    final map = Map<String, dynamic>.from(data as Map);
    return FaceRegisterResult(
      success: map['success'] as bool? ?? false,
      message: map['message'] as String? ?? '',
      faceId: map['face_id'] as int?,
      workerId: map['worker_id'] as int?,
    );
  }

  static Future<FaceRecognizeResult> recognize(String imagePath) async {
    final data = await ApiClient.postMultipart(
      '/face/recognize',
      fileField: 'file',
      filePath: imagePath,
    );
    final map = Map<String, dynamic>.from(data as Map);
    return FaceRecognizeResult(
      success: map['success'] as bool? ?? false,
      match: map['match'] as bool? ?? false,
      workerId: map['worker_id'] as int?,
      message: map['message'] as String? ?? '',
    );
  }
}

class FaceRegisterResult {
  const FaceRegisterResult({
    required this.success,
    required this.message,
    this.faceId,
    this.workerId,
  });

  final bool success;
  final String message;
  final int? faceId;
  final int? workerId;
}

class FaceRecognizeResult {
  const FaceRecognizeResult({
    required this.success,
    required this.match,
    required this.message,
    this.workerId,
  });

  final bool success;
  final bool match;
  final String message;
  final int? workerId;
}
