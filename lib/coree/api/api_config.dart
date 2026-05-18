import 'package:shared_preferences/shared_preferences.dart';

/// Configuration HTTP partagée (base URL + JWT).
class ApiConfig {
  ApiConfig._();

  static const _tokenKey = 'bongisa_access_token';

  /// Émulateur Android : `10.0.2.2` — appareil physique : IP LAN du PC.
  static const String defaultBaseUrl = 'http://10.0.2.2:8000';

  static String baseUrl = defaultBaseUrl;
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
