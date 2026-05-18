import '../coree/api/api_client.dart';
import '../models/lot_movement_model.dart';

class TraceabilityService {
  TraceabilityService._();

  static String scanPathForRole(String apiRole) {
    switch (apiRole) {
      case 'SUPERVISOR_EXTRACTION':
        return '/traceability/extraction/scan';
      case 'SUPERVISOR_TRANSPORT':
        return '/traceability/transport/scan';
      case 'SUPERVISOR_RECEPTION':
        return '/traceability/reception/scan';
      default:
        return '/traceability/scan';
    }
  }

  static Future<LotMovementModel> scan({
    required String apiRole,
    required String imagePath,
    required String qrData,
    required String qrSignature,
    String? locationName,
    double? latitude,
    double? longitude,
    String? comment,
    String? newStatus,
    String? action,
  }) async {
    final path = scanPathForRole(apiRole);
    final fields = <String, String>{
      'qr_data': qrData,
      'qr_signature': qrSignature,
      if (locationName != null) 'location_name': locationName,
      if (latitude != null) 'latitude': '$latitude',
      if (longitude != null) 'longitude': '$longitude',
      if (comment != null) 'comment': comment,
    };

    if (path == '/traceability/scan') {
      if (newStatus != null) fields['new_status'] = newStatus;
      if (action != null) fields['action'] = action;
    }

    final data = await ApiClient.postMultipart(
      path,
      fileField: 'file',
      filePath: imagePath,
      fields: fields,
    );
    return LotMovementModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  static Future<List<LotMovementModel>> batchHistory(String batchCode) async {
    final data = await ApiClient.get('/traceability/batch/$batchCode');
    return (data as List)
        .map(
          (e) => LotMovementModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}
