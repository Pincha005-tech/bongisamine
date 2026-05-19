import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../api/api_role_mapper.dart';
import '../theme/theme_notifier.dart';
import 'auth_user.dart';

/// Session JWT — `POST /auth/login`, `GET /auth/me`, persistance locale.
class AuthController extends ChangeNotifier {
  AuthController() {
    unawaited(_bootstrap());
  }

  static const _prefsKey = 'bongisa_user';

  AuthUser? user;
  bool isLoading = true;
  String? lastError;

  String _role = 'worker';

  bool get isLoggedIn => user != null;
  String get role => _role;
  String get name => user?.name ?? 'Utilisateur';
  String get email => user?.email ?? '';
  String? get company => user?.company;
  bool get isAuthenticated => isLoggedIn;
  bool get hasApiToken =>
      user?.accessToken != null && user!.accessToken!.isNotEmpty;

  Future<void> _bootstrap() async {
    try {
      await ApiService.loadStoredToken();
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final u = AuthUser.tryDecode(raw);
        if (u != null) {
          user = u;
          _role = AuthUser.normalizeRole(u.role);
          if (ApiService.accessToken != null) {
            final profile = await ApiService.getUserProfile();
            final apiRole = profile['role'] as String? ?? _role;
            _role = AuthUser.normalizeRole(apiRole);
            user = user!.copyWith(
              name: profile['name'] as String? ?? user!.name,
              email: profile['email'] as String? ?? user!.email,
              role: _role,
              accessToken: ApiService.accessToken,
            );
            await _persist();
          }
        }
      }
    } catch (_) {}
    _syncStaticRole();
    isLoading = false;
    notifyListeners();
  }

  void _syncStaticRole() {
    UserRoleController.role = _role;
  }

  Future<void> _persist() async {
    final u = user;
    if (u == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(u.toJson()));
  }

  Future<bool> login(String username, String password) async {
    lastError = null;
    final u = username.trim();
    if (u.isEmpty || password.length < 4) {
      lastError = 'Identifiant ou mot de passe invalide';
      return false;
    }

    final api = await ApiService.login(username: u, password: password);
    if (api.ok && api.data != null) {
      final data = api.data!;
      final apiUser = data['user'] as Map<String, dynamic>? ?? {};
      final token = data['access_token'] as String?;
      final backendRole = apiUser['role'] as String? ?? 'AGENT';
      _role = ApiRoleMapper.appRoleFromBackend(backendRole);
      user = AuthUser(
        id: '${apiUser['id'] ?? ''}',
        name: apiUser['username'] as String? ?? u,
        email: apiUser['username'] as String? ?? u,
        role: _role,
        accessToken: token,
      );
      await _persist();
      _syncStaticRole();
      notifyListeners();
      return true;
    }

    lastError = api.error ?? 'Connexion impossible';
    notifyListeners();
    return false;
  }

  Future<bool> signup(
    String name,
    String email,
    String company,
    String password,
  ) async {
    lastError = null;
    final n = name.trim();
    final u = email.trim();
    if (n.isEmpty || u.isEmpty || password.length < 4) return false;

    final reg = await ApiService.register(
      username: u,
      password: password,
      role: 'AGENT_CONTROLE',
    );
    if (!reg.ok) {
      lastError = reg.error;
      return false;
    }

    return login(u, password);
  }

  Future<void> logout() async {
    user = null;
    _role = 'worker';
    lastError = null;
    await ApiService.setAccessToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _syncStaticRole();
    notifyListeners();
  }

  void setRole(String newRole) {
    _role = AuthUser.normalizeRole(newRole);
    if (user != null) {
      user = user!.copyWith(role: _role);
      unawaited(_persist());
    }
    _syncStaticRole();
    notifyListeners();
  }
}

class AppQueryClient {
  const AppQueryClient();
}
