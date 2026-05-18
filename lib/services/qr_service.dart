import 'dart:convert';

import '../coree/api/api_client.dart';
import '../coree/api/api_config.dart';
import '../models/qr_code_model.dart';

class QrService {
  QrService._();

  static Future<QrCodeModel> createForMineral(int mineralId, {int? workerId}) async {
    final path = workerId != null
        ? '/qrcodes/mineral/$mineralId?worker_id=$workerId'
        : '/qrcodes/mineral/$mineralId';
    final data = await ApiClient.post(path);
    return QrCodeModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  static Future<Map<String, dynamic>> verify(String qrData, String signature) async {
    final data = await ApiClient.post(
      '/qrcodes/verify',
      body: {'data': qrData, 'signature': signature},
    );
    return Map<String, dynamic>.from(data as Map);
  }

  /// Parse le payload scanné et extrait data + signature pour l'API.
  static ({String data, String signature}) parseScannedPayload(String raw) {
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map) {
        final sig = parsed['signature'] as String?;
        if (sig != null) {
          return (data: raw, signature: sig);
        }
      }
    } catch (_) {}
    return (data: raw, signature: '');
  }

  static String imageUrl(int qrId) {
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    return '$base/qrcodes/$qrId/image';
  }
}
