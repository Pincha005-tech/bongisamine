import 'package:shared_preferences/shared_preferences.dart';

/// Configuration HTTP partagée (base URL + JWT).
class ApiConfig {
  ApiConfig._();

  static const _tokenKey = 'bongisa_access_token';
  static const _baseUrlKey = 'bongisa_api_base_url';

  /// Même API que le centre de contrôle web (Render).
  static const String productionBaseUrl = 'https://bongisa-mine-api.onrender.com';

  /// Dev local — émulateur Android.
  static const String localAndroidBaseUrl = 'http://10.0.2.2:8000';

  static String baseUrl = productionBaseUrl;
  static String? _token;

  static String? get token => _token;

  static Map<String, String> jsonHeaders({bool withAuth = true}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (withAuth && _token != null) 'Authorization': 'Bearer $_token',
      };

  static Map<String, String> authHeadersOnly() => {
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<void> setBaseUrl(String url) async {
    final trimmed = url.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) return;
    baseUrl = trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, trimmed);
  }

  static Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_baseUrlKey);
    if (saved != null && saved.trim().isNotEmpty) {
      baseUrl = saved.trim().replaceAll(RegExp(r'/+$'), '');
    }
  }

  static Future<void> resetBaseUrlToProduction() async {
    await setBaseUrl(productionBaseUrl);
  }

  static Future<void> setToken(String? value) async {
    _token = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, value);
    }
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_tokenKey);
    _token = (t != null && t.isNotEmpty) ? t : null;
  }

  static Future<void> clearSession() async {
    await setToken(null);
  }
}
