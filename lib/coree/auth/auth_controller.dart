import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_notifier.dart';
import 'auth_user.dart';

/// Équivalent Expo [`AuthContext.tsx`](contexts/AuthContext) : session locale,
/// persistance `bongisa_user`, login / signup mock, `setRole`, `logout`.
class AuthController extends ChangeNotifier {
  AuthController() {
    unawaited(_bootstrap());
  }

  static const _prefsKey = 'bongisa_user';

  AuthUser? user;
  bool isLoading = true;

  /// Rôle « contexte » (comme `role` dans le hook Expo), utilisé au prochain login.
  String _role = 'worker';

  bool get isLoggedIn => user != null;

  String get role => _role;

  /// Rétrocompat écrans existants.
  String get name => user?.name ?? 'Utilisateur';
  String get email => user?.email ?? '';
  String? get company => user?.company;
  bool get isAuthenticated => isLoggedIn;

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final u = AuthUser.tryDecode(raw);
        if (u != null) {
          user = u;
          _role = AuthUser.normalizeRole(u.role);
        }
      }
    } catch (_) {}
    _syncStaticRole();
    isLoading = false;
    notifyListeners();
  }

  void _syncStaticRole() {
    UserRoleController.role =
        _role == 'supervisor' ? 'supervisor' : _role;
  }

  Future<void> _persist() async {
    final u = user;
    if (u == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(u.toJson()));
  }

  /// Expo : délai 800 ms, email non vide + mot de passe ≥ 4, rôle = `role` courant.
  Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final e = email.trim();
    if (e.isNotEmpty && password.length >= 4) {
      final part = e.split('@').first;
      final displayName = part.isNotEmpty ? part : 'User';
      user = AuthUser(
        id: 'u-${DateTime.now().millisecondsSinceEpoch}',
        name: displayName,
        email: e,
        role: AuthUser.normalizeRole(_role),
      );
      await _persist();
      _syncStaticRole();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Expo : délai 1000 ms, rôle `worker`, entreprise optionnelle.
  Future<bool> signup(
    String name,
    String email,
    String company,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    final n = name.trim();
    final e = email.trim();
    if (n.isNotEmpty && e.isNotEmpty && password.length >= 4) {
      _role = 'worker';
      user = AuthUser(
        id: 'u-${DateTime.now().millisecondsSinceEpoch}',
        name: n,
        email: e,
        role: 'worker',
        company: company.trim().isEmpty ? null : company.trim(),
      );
      await _persist();
      _syncStaticRole();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _syncStaticRole();
    notifyListeners();
  }

  /// Expo : met à jour le rôle + persiste si un utilisateur est connecté.
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

/// Placeholder pour un futur client type TanStack Query (cache HTTP, etc.).
class AppQueryClient {
  const AppQueryClient();
}
