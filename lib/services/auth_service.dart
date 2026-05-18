import '../coree/api/api_client.dart';
import '../coree/api/api_config.dart';

class AuthService {
  AuthService._();

  static Future<LoginResult> login(String username, String password) async {
    final data = await ApiClient.post(
      '/auth/login',
      body: {'username': username, 'password': password},
      auth: false,
    );
    final map = Map<String, dynamic>.from(data as Map);
    final token = map['access_token'] as String;
    final user = Map<String, dynamic>.from(map['user'] as Map);
    await ApiConfig.setToken(token);
    return LoginResult(
      accessToken: token,
      userId: user['id'] as int,
      username: user['username'] as String,
      apiRole: user['role'] as String,
    );
  }

  static Future<MeResult> me() async {
    final data = await ApiClient.get('/auth/me');
    final map = Map<String, dynamic>.from(data as Map);
    return MeResult(
      userId: map['id'] as int,
      username: map['username'] as String,
      apiRole: map['role'] as String,
      status: map['status'] as String? ?? 'active',
    );
  }

  static Future<void> logout() async {
    await ApiConfig.clearSession();
  }
}

class LoginResult {
  const LoginResult({
    required this.accessToken,
    required this.userId,
    required this.username,
    required this.apiRole,
  });

  final String accessToken;
  final int userId;
  final String username;
  final String apiRole;
}

class MeResult {
  const MeResult({
    required this.userId,
    required this.username,
    required this.apiRole,
    required this.status,
  });

  final int userId;
  final String username;
  final String apiRole;
  final String status;
}
