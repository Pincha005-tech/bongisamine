import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity_log.dart';
import '../models/gps_tracker.dart';
import '../models/worker_item.dart';
import 'api_config.dart';

/// Client HTTP aligné sur les routes `mine_back` (FastAPI).
class ApiService {
  ApiService._();

  static const baseUrl = ApiConfig.baseUrl;
  static const _tokenKey = 'bongisa_access_token';
  static const _defaultTimeout = Duration(seconds: 8);

  static String? _accessToken;

  static String? get accessToken => _accessToken;

  static Future<void> loadStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
  }

  static Future<void> setAccessToken(String? token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  static Map<String, String> headers({bool auth = false}) {
    final map = <String, String>{'Content-Type': 'application/json'};
    if (auth && _accessToken != null && _accessToken!.isNotEmpty) {
      map['Authorization'] = 'Bearer $_accessToken';
    }
    return map;
  }

  static String normalizeRole(String? backendRole) {
    final r = (backendRole ?? 'AGENT').toUpperCase();
    switch (r) {
      case 'ADMIN':
        return 'admin';
      case 'SUPERVISOR':
      case 'STATE_AUTHORITY':
        return 'supervisor';
      default:
        return 'worker';
    }
  }

  static String backendRoleFromContext(String frontRole) {
    switch (frontRole) {
      case 'admin':
        return 'ADMIN';
      case 'supervisor':
        return 'SUPERVISOR';
      default:
        return 'AGENT';
    }
  }

  /// `POST /auth/login` — [username] = e-mail ou identifiant saisi.
  static Future<({bool ok, Map<String, dynamic>? data, String? error})> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: headers(),
            body: jsonEncode({
              'username': username.trim(),
              'password': password,
            }),
          )
          .timeout(_defaultTimeout);

      if (res.statusCode != 200) {
        return (ok: false, data: null, error: 'Identifiants incorrects');
      }

      final data = jsonDecode(res.body);
      if (data is! Map<String, dynamic>) {
        return (ok: false, data: null, error: 'Réponse invalide');
      }

      final token = data['access_token'] as String?;
      if (token != null) await setAccessToken(token);
      return (ok: true, data: data, error: null);
    } catch (_) {
      return (ok: false, data: null, error: 'Serveur inaccessible');
    }
  }

  /// `POST /auth/register` puis connexion automatique.
  static Future<({bool ok, String? error})> register({
    required String username,
    required String password,
    String role = 'AGENT',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: headers(),
            body: jsonEncode({
              'username': username.trim(),
              'password': password,
              'role': role,
            }),
          )
          .timeout(_defaultTimeout);

      if (res.statusCode != 200 && res.statusCode != 201) {
        return (ok: false, error: 'Inscription refusée');
      }

      final loginResult = await login(username: username, password: password);
      if (!loginResult.ok) {
        return (ok: false, error: loginResult.error ?? 'Connexion impossible');
      }
      return (ok: true, error: null);
    } catch (_) {
      return (ok: false, error: 'Serveur inaccessible');
    }
  }

  /// `GET /auth/me`
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: headers(auth: true),
          )
          .timeout(_defaultTimeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          final username = data['username'] as String? ?? '';
          return {
            'name': username,
            'email': username,
            'role': normalizeRole(data['role'] as String?),
            'status': data['status'],
          };
        }
      }
    } catch (_) {}

    return {
      'name': 'Utilisateur',
      'email': '',
      'role': 'worker',
    };
  }

  /// Non exposé par le backend.
  static Future<bool> updateProfile(String name, String email) async => false;

  /// Non exposé par le backend.
  static Future<bool> changePassword(String oldPass, String newPass) async =>
      false;

  /// `GET /user/data` remplacé par agrégat local + `/auth/me`.
  static Future<Map<String, dynamic>> getUserData() async {
    final profile = await getUserProfile();
    return {
      'logs': [
        'Connexion',
        if (profile['name'] != null) 'Profil : ${profile['name']}',
      ],
    };
  }

  static Future<bool> deleteAccount() async => false;

  /// `POST /qrcodes/mineral/{mineral_id}`
  static Future<String?> generateQR(int mineralId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/qrcodes/mineral/$mineralId'),
            headers: headers(auth: true),
          )
          .timeout(_defaultTimeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map) {
          return data['qr_path'] as String?;
        }
      }
    } catch (_) {}
    return null;
  }

  /// `GET /dashboard/`
  static Future<Map<String, dynamic>?> fetchDashboard() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/dashboard/'))
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
      }
    } catch (_) {}
    return null;
  }

  /// `GET /reports/daily`
  static Future<Map<String, dynamic>?> fetchDailyReport() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/reports/daily'))
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
      }
    } catch (_) {}
    return null;
  }

  /// `GET /workers/`
  static Future<List<WorkerItem>?> fetchWorkers() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/workers/'))
          .timeout(_defaultTimeout);
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      if (data is! List) return null;

      return data
          .whereType<Map>()
          .map((e) => _workerFromApi(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static WorkerItem _workerFromApi(Map<String, dynamic> map) {
    final first = map['first_name'] as String? ?? '';
    final last = map['last_name'] as String? ?? '';
    final name = '$first $last'.trim();
    final dept = map['department_role'] as String? ??
        map['role'] as String? ??
        '—';
    return WorkerItem(
      id: '${map['id']}',
      name: name.isEmpty ? 'Travailleur ${map['id']}' : name,
      status: WorkerStatus.active,
      department: dept,
      lastScan: '—',
    );
  }

  static String _formatActivityTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      final local = dt.toLocal();
      final now = DateTime.now();
      if (local.year == now.year &&
          local.month == now.month &&
          local.day == now.day) {
        return '${local.hour.toString().padLeft(2, '0')}:'
            '${local.minute.toString().padLeft(2, '0')}';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (local.year == yesterday.year &&
          local.month == yesterday.month &&
          local.day == yesterday.day) {
        return 'Hier ${local.hour.toString().padLeft(2, '0')}:'
            '${local.minute.toString().padLeft(2, '0')}';
      }
      return '${local.day.toString().padLeft(2, '0')}/'
          '${local.month.toString().padLeft(2, '0')} '
          '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  static Future<Map<int, String>> _workerNamesById() async {
    final workers = await fetchWorkers();
    if (workers == null) return {};
    final map = <int, String>{};
    for (final w in workers) {
      final id = int.tryParse(w.id);
      if (id != null) map[id] = w.name;
    }
    return map;
  }

  /// Flux d'activités : `GET /attendances/` + `GET /alerts/paginated`.
  static Future<List<ActivityLog>?> fetchActivitiesPage({
    required int page,
    int pageSize = 5,
  }) async {
    try {
      final names = await _workerNamesById();

      final attRes = await http
          .get(Uri.parse('$baseUrl/attendances/'))
          .timeout(_defaultTimeout);
      if (attRes.statusCode != 200) return null;

      final attData = jsonDecode(attRes.body);
      if (attData is! List) return null;

      final entries = <({DateTime at, ActivityLog log})>[];

      for (final raw in attData.whereType<Map>()) {
        final row = Map<String, dynamic>.from(raw);
        final workerId = row['worker_id'] as int?;
        final name = names[workerId] ?? 'Travailleur ${workerId ?? '?'}';

        final checkIn = row['check_in'] as String?;
        if (checkIn != null) {
          final status = row['status'] as String? ?? 'present';
          entries.add((
            at: DateTime.parse(checkIn),
            log: ActivityLog(
              name: name,
              action: status == 'late' ? 'Entrée (retard)' : 'Entrée site',
              time: _formatActivityTime(checkIn),
            ),
          ));
        }

        final checkOut = row['check_out'] as String?;
        if (checkOut != null) {
          entries.add((
            at: DateTime.parse(checkOut),
            log: ActivityLog(
              name: name,
              action: 'Sortie site',
              time: _formatActivityTime(checkOut),
            ),
          ));
        }
      }

      final alertRes = await http
          .get(
            Uri.parse('$baseUrl/alerts/paginated?page=1&limit=50'),
          )
          .timeout(_defaultTimeout);

      if (alertRes.statusCode == 200) {
        final alertBody = jsonDecode(alertRes.body);
        if (alertBody is Map) {
          final list = alertBody['data'];
          if (list is List) {
            for (final raw in list.whereType<Map>()) {
              final row = Map<String, dynamic>.from(raw);
              final created = row['created_at'] as String?;
              if (created == null) continue;
              entries.add((
                at: DateTime.parse(created),
                log: ActivityLog(
                  name: 'Système',
                  action: row['message'] as String? ?? 'Alerte',
                  time: _formatActivityTime(created),
                ),
              ));
            }
          }
        }
      }

      entries.sort((a, b) => b.at.compareTo(a.at));

      final start = (page - 1) * pageSize;
      if (start >= entries.length) return [];
      final end = (start + pageSize).clamp(0, entries.length);
      return entries.sublist(start, end).map((e) => e.log).toList();
    } catch (_) {
      return null;
    }
  }

  /// Pas de `GET /trackers` : retourne `null` (démo côté UI).
  static Future<List<GpsTracker>?> fetchGpsTrackers() async => null;

  /// `GET /alerts/paginated`
  static Future<List<Map<String, dynamic>>> fetchAlerts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/alerts/paginated?page=$page&limit=$limit'),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body);
      if (body is Map && body['data'] is List) {
        return body['data']
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// `GET /minerals/`
  static Future<List<Map<String, dynamic>>> fetchMinerals() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/minerals/'))
          .timeout(_defaultTimeout);
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// `GET /mineral-history/`
  static Future<List<Map<String, dynamic>>> fetchMineralHistory() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/mineral-history/'))
          .timeout(_defaultTimeout);
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// `GET /attendances/today`
  static Future<List<Map<String, dynamic>>> fetchAttendancesToday() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/attendances/today'))
          .timeout(_defaultTimeout);
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// `GET /transactions/`
  static Future<int?> fetchTransactionsCount() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/transactions/'))
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) return data.length;
      }
    } catch (_) {}
    return null;
  }

  /// `GET /blockchain/` (JWT + rôle admin/auditor)
  static Future<List<Map<String, dynamic>>?> fetchBlockchain() async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/blockchain/'),
            headers: headers(auth: true),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return null;
  }

  /// `GET /blockchain/verify`
  static Future<bool?> fetchBlockchainValid() async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/blockchain/verify'),
            headers: headers(auth: true),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map) return data['valid'] as bool?;
      }
    } catch (_) {}
    return null;
  }

  static String formatDisplayDate(DateTime dt) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String formatDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  static String roleLabel(String? role) {
    switch ((role ?? '').toLowerCase()) {
      case 'admin':
        return 'ADMIN';
      case 'supervisor':
        return 'SUPERVISOR';
      case 'authority':
        return 'STATE_AUTHORITY';
      default:
        return 'AGENT';
    }
  }

  static String normalizeMineralStatus(String? raw) {
    if (raw == null || raw.isEmpty) return 'EXTRACTED';
    return raw.toUpperCase().replaceAll(' ', '_');
  }

  /// `POST /qrcodes/verify`
  static Future<Map<String, dynamic>?> verifyQr({
    required String data,
    required String signature,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/qrcodes/verify'),
            headers: headers(auth: true),
            body: jsonEncode({'data': data, 'signature': signature}),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map<String, dynamic>) return body;
      }
    } catch (_) {}
    return null;
  }
}
