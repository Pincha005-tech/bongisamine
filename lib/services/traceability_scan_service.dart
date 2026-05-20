import 'api_service.dart';

/// Choix de l'endpoint scan selon le rôle app (§5.3 INTEGRATION_FRONTEND).
class TraceabilityScanService {
  TraceabilityScanService._();

  static String segmentForRole(String appRole) {
    switch (appRole) {
      case 'supervisor_extraction':
        return 'extraction';
      case 'supervisor_transport':
        return 'transport';
      case 'supervisor_reception':
        return 'reception';
      case 'supervisor':
        return 'scan';
      default:
        return 'extraction';
    }
  }

  static Future<ApiScanResult> submit({
    required String appRole,
    required String imagePath,
    required String qrData,
    required String qrSignature,
    String? locationName,
    double? latitude,
    double? longitude,
    String? comment,
    String? action,
  }) {
    return ApiService.postTraceabilityScan(
      segment: segmentForRole(appRole),
      imagePath: imagePath,
      qrData: qrData,
      qrSignature: qrSignature,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      comment: comment,
      action: action,
    );
  }
}
