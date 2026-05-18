import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_config.dart';
import '../api/api_exception.dart';
import '../../services/auth_service.dart';
import '../theme/theme_notifier.dart';
import 'app_roles.dart';
import 'auth_user.dart';

class AuthController extends ChangeNotifier {
  AuthController() {
    unawaited(_bootstrap());
  }

  static const _prefsKey = 'bongisa_user';

  AuthUser? user;
  bool isLoading = true;
  String? lastError;

  String _persona = AppRoles.supervisor;

  bool get isLoggedIn => user != null;
  String get role => _persona;
  String get apiRole => user?.apiRole ?? '';
  String get name => user?.name ?? 'Utilisateur';
  String get email => user?.email ?? '';
  String? get company => user?.company;
  bool get isAuthenticated => isLoggedIn;
  bool get isAgent => _persona == AppRoles.agent;
  bool get isSupervisor => _persona == AppRoles.supervisor;

  Future<void> _bootstrap() async {
    try {
      await ApiConfig.loadToken();
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (ApiConfig.token != null && raw != null && raw.isNotEmpty) {
        final stored = AuthUser.tryDecode(raw);
        if (stored != null) {
          try {
            final me = await AuthService.me();
            user = stored.copyWith(
              apiRole: me.apiRole,
              name: me.username,
              email: me.username,
            );
            _persona = stored.role;
          } catch (_) {
            user = stored;
            _persona = stored.role;
          }
        }
      }
    } catch (_) {}
    _syncStaticRole();
    isLoading = false;
    notifyListeners();
  }

  void _syncStaticRole() {
    UserRoleController.role = _persona;
  }

  Future<void> _persist() async {
    final u = user;
    if (u == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(u.toJson()));
  }

  /// Connexion API : [username] + [password], persona = agent ou superviseur.
  Future<bool> login(String username, String password) async {
    lastError = null;
    final u = username.trim();
    if (u.isEmpty || password.length < 4) {
      lastError = 'Identifiants invalides';
      return false;
    }

    try {
      final result = await AuthService.login(u, password);

      if (!AppRoles.matchesPersona(_persona, result.apiRole)) {
        await AuthService.logout();
        lastError = _persona == AppRoles.agent
            ? 'Ce compte n\'est pas un agent de contrôle'
            : 'Ce compte n\'est pas un superviseur';
        return false;
      }

      user = AuthUser(
        id: result.userId.toString(),
        name: result.username,
        email: result.username,
        role: _persona,
        apiRole: result.apiRole,
      );
      await _persist();
      _syncStaticRole();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      lastError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      lastError = 'Impossible de joindre le serveur';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(
    String name,
    String email,
    String company,
    String password,
  ) async {
    lastError =
        'Inscription désactivée sur mobile — contactez l\'administrateur.';
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await AuthService.logout();
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _syncStaticRole();
    notifyListeners();
  }

  void setPersona(String persona) {
    final p = AuthUser.normalizePersona(persona);
    if (p == AppRoles.agent || p == AppRoles.supervisor) {
      _persona = p;
      if (user != null) {
        user = user!.copyWith(role: p);
        unawaited(_persist());
      }
      _syncStaticRole();
      notifyListeners();
    }
  }
}

class AppQueryClient {
  const AppQueryClient();
}
