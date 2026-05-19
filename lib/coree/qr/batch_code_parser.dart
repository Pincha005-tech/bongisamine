import 'dart:convert';

/// Données QR pour les scans traçabilité (`qr_data` + `qr_signature`).
class QrScanPayload {
  const QrScanPayload({
    required this.batchCode,
    required this.qrData,
    required this.signature,
  });

  final String batchCode;
  final String qrData;
  final String signature;
}

/// Parse le contenu scanné pour l'API traçabilité.
QrScanPayload? parseQrScanPayload(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is Map) {
      final batch = decoded['batch_code'] ?? decoded['batchCode'];
      final sig = decoded['signature'];
      if (batch is String && sig is String && batch.isNotEmpty) {
        return QrScanPayload(
          batchCode: batch.trim().toUpperCase(),
          qrData: trimmed,
          signature: sig,
        );
      }
    }
  } catch (_) {}

  final batch = parseBatchCodeFromQrRaw(trimmed);
  if (batch == null) return null;
  return QrScanPayload(
    batchCode: batch,
    qrData: trimmed,
    signature: trimmed,
  );
}

/// Extrait un `batch_code` depuis le contenu brut d'un QR (JSON backend ou texte).
String? parseBatchCodeFromQrRaw(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is Map) {
      final fromKey = decoded['batch_code'] ?? decoded['batchCode'];
      if (fromKey is String && fromKey.trim().isNotEmpty) {
        return fromKey.trim().toUpperCase();
      }
    }
  } catch (_) {}

  final pattern = RegExp(r'DRC-MINE-[A-Z0-9\-]+', caseSensitive: false);
  final match = pattern.firstMatch(trimmed);
  if (match != null) return match.group(0)!.toUpperCase();

  if (trimmed.toUpperCase().startsWith('DRC-MINE-')) {
    return trimmed.toUpperCase();
  }

  return trimmed.toUpperCase();
}
