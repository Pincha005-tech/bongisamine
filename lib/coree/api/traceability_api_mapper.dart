import '../../extraction/extraction_models.dart';
import '../../reception/reception_models.dart';
import '../../transport/transport_models.dart';

/// Mappe les réponses `LotMovementResponse` du backend vers les modèles UI.
class TraceabilityApiMapper {
  TraceabilityApiMapper._();

  static String formatCreatedAt(dynamic raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final mo = dt.month.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final mi = dt.minute.toString().padLeft(2, '0');
      return '$d/$mo/${dt.year} $h:$mi';
    } catch (_) {
      return raw.toString();
    }
  }

  static ExtractionLotMovement toExtraction(Map<String, dynamic> m) {
    return ExtractionLotMovement(
      id: m['id'] as int? ?? 0,
      qrId: m['qr_id'] as int? ?? 0,
      mineralId: m['mineral_id'] as int?,
      workerId: m['worker_id'] as int?,
      previousStatus: m['previous_status'] as String? ?? '—',
      newStatus: m['new_status'] as String? ?? '—',
      locationName: m['location_name'] as String?,
      action: m['action'] as String? ?? 'scan',
      createdAtLabel: formatCreatedAt(m['created_at']),
    );
  }

  static ReceptionLotMovement toReception(Map<String, dynamic> m) {
    return ReceptionLotMovement(
      id: m['id'] as int? ?? 0,
      qrId: m['qr_id'] as int? ?? 0,
      mineralId: m['mineral_id'] as int?,
      workerId: m['worker_id'] as int?,
      previousStatus: m['previous_status'] as String? ?? '—',
      newStatus: m['new_status'] as String? ?? '—',
      locationName: m['location_name'] as String?,
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      action: m['action'] as String? ?? 'scan',
      comment: m['comment'] as String?,
      createdAtLabel: formatCreatedAt(m['created_at']),
    );
  }

  static TransportLotMovement toTransport(Map<String, dynamic> m) {
    return TransportLotMovement(
      id: m['id'] as int? ?? 0,
      qrId: m['qr_id'] as int? ?? 0,
      mineralId: m['mineral_id'] as int?,
      workerId: m['worker_id'] as int?,
      previousStatus: m['previous_status'] as String? ?? '—',
      newStatus: m['new_status'] as String? ?? '—',
      locationName: m['location_name'] as String?,
      action: m['action'] as String? ?? 'scan',
      comment: m['comment'] as String?,
      createdAtLabel: formatCreatedAt(m['created_at']),
    );
  }
}
