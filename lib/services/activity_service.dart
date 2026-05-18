import '../coree/api/api_client.dart';
import '../models/paginated_response.dart';
import '../models/transaction_model.dart';

/// Activités terrain : transactions + historique minéral (pas d'endpoint `/activities`).
class ActivityService {
  ActivityService._();

  static Future<List<ActivityItem>> fetchPage({int page = 1, int limit = 20}) async {
    final items = <ActivityItem>[];

    try {
      final txData = await ApiClient.get(
        '/transactions/paginated',
        query: {'page': '$page', 'limit': '$limit'},
        auth: false,
      );
      final txPage = PaginatedResponse.fromJson(
        Map<String, dynamic>.from(txData as Map),
        TransactionModel.fromJson,
      );
      for (final t in txPage.data) {
        items.add(
          ActivityItem(
            name: 'Transaction #${t.id}',
            action: t.action,
            time: _formatTime(t.createdAt),
          ),
        );
      }
    } catch (_) {}

    if (items.isEmpty && page == 1) {
      try {
        final hist = await ApiClient.get('/mineral-history/', auth: false);
        for (final e in (hist as List).take(limit)) {
          final m = Map<String, dynamic>.from(e as Map);
          items.add(
            ActivityItem(
              name: 'Minerai #${m['mineral_id']}',
              action: m['action'] as String? ?? 'Historique',
              time: _formatTime(
                DateTime.tryParse(m['created_at']?.toString() ?? ''),
              ),
            ),
          );
        }
      } catch (_) {}
    }

    return items;
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class ActivityItem {
  const ActivityItem({
    required this.name,
    required this.action,
    required this.time,
  });

  final String name;
  final String action;
  final String time;
}
