import '../coree/api/api_client.dart';
import '../models/dashboard_stats.dart';

class DashboardService {
  DashboardService._();

  static Future<DashboardStats> stats() async {
    final data = await ApiClient.get('/dashboard/', auth: false);
    return DashboardStats.fromJson(Map<String, dynamic>.from(data as Map));
  }

  static Future<Map<String, dynamic>> dailyReport() async {
    final data = await ApiClient.get('/reports/daily', auth: false);
    return Map<String, dynamic>.from(data as Map);
  }
}
