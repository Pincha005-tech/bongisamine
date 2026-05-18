import '../coree/api/api_config.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';

/// Façade rétrocompatible — délègue aux services dédiés.
class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final me = await AuthService.me();
      return {
        'name': me.username,
        'email': me.username,
        'role': me.apiRole,
        'username': me.username,
        'status': me.status,
      };
    } catch (_) {
      return {
        'name': 'Utilisateur',
        'email': '',
        'role': 'WORKER',
      };
    }
  }

  static Future<bool> changePassword(String oldPass, String newPass) async {
    // Endpoint non exposé par mine_back — à implémenter côté API.
    return false;
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final s = await DashboardService.stats();
    return {
      'workers': s.workers,
      'minerals': s.minerals,
      'qrcodes': s.qrcodes,
      'alerts': s.alerts,
      'critical_alerts': s.criticalAlerts,
      'attendances': s.attendances,
      'lot_movements': s.lotMovements,
    };
  }
}
