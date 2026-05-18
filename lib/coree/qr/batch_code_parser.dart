import 'dart:convert';

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
