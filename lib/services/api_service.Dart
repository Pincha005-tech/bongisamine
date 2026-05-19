import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity_log.dart';
import '../models/gps_tracker.dart';
import '../models/worker_item.dart';
import '../coree/api/api_role_mapper.dart';
import 'api_config.dart';

/// Résultat scan traçabilité ou erreur métier.
class ApiScanResult {
  const ApiScanResult.success(this.body)
      : ok = true,
        errorMessage = null,
        statusCode = 200;

  const ApiScanResult.failure(this.errorMessage, {this.statusCode = 400})
      : ok = false,
        body = null;

  final bool ok;
  final Map<String, dynamic>? body;
  final String? errorMessage;
  final int statusCode;
}

/// Client HTTP aligné sur les routes `mine_back` (FastAPI).
class ApiService {
  ApiService._();

  static const baseUrl = ApiConfig.baseUrl;
  static const _tokenKey = 'bongisa_access_token';
  static const _defaultTimeout = ApiConfig.defaultTimeout;

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

  static String normalizeRole(String? backendRole) =>
      ApiRoleMapper.appRoleFromBackend(backendRole);

  static String? extractErrorMessage(dynamic body, int status) {
    if (body is Map && body['detail'] != null) {
      final d = body['detail'];
      if (d is String) return d;
      if (d is List && d.isNotEmpty) {
        final first = d.first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
      }
    }
    return 'Erreur HTTP $status';
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

      if (res.statusCode == 401 || res.statusCode == 403) {
        final err = jsonDecode(res.body);
        return (
          ok: false,
          data: null,
          error: extractErrorMessage(err, res.statusCode),
        );
      }
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
            'role': ApiRoleMapper.appRoleFromBackend(data['role'] as String?),
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

  /// `POST /qrcodes/mineral/{mineral_id}` — réponse complète QR.
  static Future<Map<String, dynamic>?> generateQrForMineral(int mineralId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/qrcodes/mineral/$mineralId'),
            headers: headers(auth: true),
          )
          .timeout(_defaultTimeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return null;
  }

  /// Alias rétrocompat — chemin image QR si présent.
  static Future<String?> generateQR(int mineralId) async {
    final data = await generateQrForMineral(mineralId);
    return data?['qr_path'] as String?;
  }

  /// `GET /qrcodes/{qr_id}/image` — PNG avec en-tête Authorization.
  static Future<List<int>?> fetchQrImageBytes(int qrId) async {
    if (qrId <= 0) return null;
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/qrcodes/$qrId/image'),
            headers: headers(auth: true),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        return res.bodyBytes;
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
          .get(
            Uri.parse('$baseUrl/workers/'),
            headers: headers(auth: true),
          )
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
          .get(
            Uri.parse('$baseUrl/attendances/'),
            headers: headers(auth: true),
          )
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
            headers: headers(auth: true),
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
          .get(
            Uri.parse('$baseUrl/minerals/'),
            headers: headers(auth: true),
          )
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

  /// `GET /attendances/today` (+ repli `GET /attendances/` filtré sur la date locale).
  static Future<List<Map<String, dynamic>>> fetchAttendancesToday() async {
    final today = await _getJsonList(
      Uri.parse('$baseUrl/attendances/today'),
      auth: true,
    );
    if (today.isNotEmpty) return today;

    final all = await _getJsonList(
      Uri.parse('$baseUrl/attendances/'),
      auth: true,
    );
    return _attendancesForLocalDate(all, DateTime.now());
  }

  static Future<List<Map<String, dynamic>>> _getJsonList(
    Uri uri, {
    bool auth = false,
  }) async {
    try {
      final res = await http
          .get(uri, headers: headers(auth: auth))
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

  static List<Map<String, dynamic>> _attendancesForLocalDate(
    List<Map<String, dynamic>> rows,
    DateTime day,
  ) {
    bool sameDay(DateTime dt) =>
        dt.year == day.year && dt.month == day.month && dt.day == day.day;

    return rows.where((row) {
      final raw = row['attendance_date'];
      if (raw == null) return false;
      if (raw is String) {
        final parsed = DateTime.tryParse(raw);
        if (parsed != null) return sameDay(parsed.toLocal());
        final dateOnly = raw.split('T').first;
        final parts = dateOnly.split('-');
        if (parts.length >= 3) {
          return int.tryParse(parts[0]) == day.year &&
              int.tryParse(parts[1]) == day.month &&
              int.tryParse(parts[2]) == day.day;
        }
      }
      return false;
    }).toList();
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

  /// `POST /traceability/{extraction|transport|reception}/scan` ou `/traceability/scan`
  static Future<ApiScanResult> postTraceabilityScan({
    required String segment,
    required String imagePath,
    required String qrData,
    required String qrSignature,
    String? locationName,
    double? latitude,
    double? longitude,
    String? comment,
    String? action,
  }) async {
    try {
      final path = segment == 'scan'
          ? '$baseUrl/traceability/scan'
          : '$baseUrl/traceability/$segment/scan';
      final request = http.MultipartRequest('POST', Uri.parse(path));
      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      request.fields['qr_data'] = qrData;
      request.fields['qr_signature'] = qrSignature;
      if (locationName != null && locationName.isNotEmpty) {
        request.fields['location_name'] = locationName;
      }
      if (latitude != null) request.fields['latitude'] = '$latitude';
      if (longitude != null) request.fields['longitude'] = '$longitude';
      if (comment != null && comment.isNotEmpty) {
        request.fields['comment'] = comment;
      }
      if (action != null && action.isNotEmpty) {
        request.fields['action'] = action;
      }
      final streamed = await request.send().timeout(_defaultTimeout);
      final res = await http.Response.fromStream(streamed);
      dynamic body;
      if (res.body.isNotEmpty) {
        try {
          body = jsonDecode(res.body);
        } catch (_) {
          body = res.body;
        }
      }
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiScanResult.success(
          body is Map<String, dynamic> ? body : {'raw': body},
        );
      }
      return ApiScanResult.failure(
        extractErrorMessage(body, res.statusCode),
        statusCode: res.statusCode,
      );
    } catch (_) {
      return const ApiScanResult.failure('Serveur inaccessible');
    }
  }

  /// `GET /traceability/batch/{batch_code}`
  static Future<List<Map<String, dynamic>>> fetchBatchMovements(
    String batchCode,
  ) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/traceability/batch/$batchCode'),
            headers: headers(auth: true),
          )
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

  /// `GET /traceability/workflow` (public)
  static Future<Map<String, dynamic>?> fetchWorkflow() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/traceability/workflow'))
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
      }
    } catch (_) {}
    return null;
  }

  /// `POST /security/face-qr-fraud-check` (réception)
  static Future<Map<String, dynamic>?> postFaceQrFraudCheck({
    required String imagePath,
    required String qrData,
    required String qrSignature,
  }) async {
    return _postFaceQrSecurity(
      'face-qr-fraud-check',
      imagePath: imagePath,
      qrData: qrData,
      qrSignature: qrSignature,
    );
  }

  /// `POST /security/face-qr-secure-read`
  static Future<Map<String, dynamic>?> postFaceQrSecureRead({
    required String imagePath,
    required String qrData,
    required String qrSignature,
  }) async {
    return _postFaceQrSecurity(
      'face-qr-secure-read',
      imagePath: imagePath,
      qrData: qrData,
      qrSignature: qrSignature,
    );
  }

  static Future<Map<String, dynamic>?> _postFaceQrSecurity(
    String path, {
    required String imagePath,
    required String qrData,
    required String qrSignature,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/security/$path'),
      );
      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      request.fields['qr_data'] = qrData;
      request.fields['qr_signature'] = qrSignature;
      final res = await http.Response.fromStream(
        await request.send().timeout(_defaultTimeout),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body);
        if (body is Map<String, dynamic>) return body;
      }
    } catch (_) {}
    return null;
  }

  /// `POST /minerals/`
  static Future<Map<String, dynamic>?> createMineral({
    required String type,
    required double weight,
    String status = 'extracted',
    double? latitude,
    double? longitude,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/minerals/'),
            headers: headers(auth: true),
            body: jsonEncode({
              'type': type,
              'weight': weight,
              'status': status,
              if (latitude != null) 'latitude': latitude,
              if (longitude != null) 'longitude': longitude,
            }),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
      }
    } catch (_) {}
    return null;
  }

  /// `GET /qrcodes/`
  static Future<List<Map<String, dynamic>>> fetchQrcodes() async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/qrcodes/'),
            headers: headers(auth: true),
          )
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

  /// `POST /workers/`
  static Future<Map<String, dynamic>?> createWorker({
    required String firstName,
    required String lastName,
    required String role,
    required String badgeId,
    String? departmentRole,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/workers/'),
            headers: headers(auth: true),
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'role': role,
              'badge_id': badgeId,
              if (departmentRole != null) 'department_role': departmentRole,
            }),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
      }
    } catch (_) {}
    return null;
  }

  /// `PUT /workers/{id}`
  static Future<Map<String, dynamic>?> updateWorker(
    int id, {
    String? firstName,
    String? lastName,
    String? role,
    String? badgeId,
    String? departmentRole,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (role != null) body['role'] = role;
      if (badgeId != null) body['badge_id'] = badgeId;
      if (departmentRole != null) body['department_role'] = departmentRole;
      final res = await http
          .put(
            Uri.parse('$baseUrl/workers/$id'),
            headers: headers(auth: true),
            body: jsonEncode(body),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
      }
    } catch (_) {}
    return null;
  }

  /// `DELETE /workers/{id}`
  static Future<bool> deleteWorker(int id) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$baseUrl/workers/$id'),
            headers: headers(auth: true),
          )
          .timeout(_defaultTimeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// `POST /attendances/check-in` / `check-out`
  static Future<Map<String, dynamic>?> attendanceCheck(
    String action,
    int workerId,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/attendances/$action'),
            headers: headers(auth: true),
            body: jsonEncode({'worker_id': workerId}),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic> && data['success'] == true) {
          return data;
        }
        if (data is Map && data['success'] == true) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Message d'erreur renvoyé par check-in / check-out (`success: false`).
  static Future<String?> attendanceCheckMessage(
    String action,
    int workerId,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/attendances/$action'),
            headers: headers(auth: true),
            body: jsonEncode({'worker_id': workerId}),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
      }
    } catch (_) {}
    return null;
  }

  /// `POST /face/register/{worker_id}`
  static Future<Map<String, dynamic>?> registerFace(
    int workerId,
    String imagePath,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/face/register/$workerId'),
      );
      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      final res = await http.Response.fromStream(
        await request.send().timeout(_defaultTimeout),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
      }
    } catch (_) {}
    return null;
  }

  /// `POST /face/recognize`
  static Future<Map<String, dynamic>?> recognizeFace(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/face/recognize'),
      );
      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      final res = await http.Response.fromStream(
        await request.send().timeout(_defaultTimeout),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
      }
    } catch (_) {}
    return null;
  }

  static Future<List<Map<String, dynamic>>> fetchWorkersPaginated({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/workers/paginated?page=$page&limit=$limit'),
            headers: headers(auth: true),
          )
          .timeout(_defaultTimeout);
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body);
      if (body is Map && body['data'] is List) {
        return (body['data'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
