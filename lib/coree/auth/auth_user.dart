import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Aligné sur `models/user` Expo (`AuthContext`).
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.company,
    this.accessToken,
  });

  final String id;
  final String name;
  final String email;
  /// `admin` | `supervisor` | `worker` | `agent` | `auditor` | `state_authority`
  final String role;
  final String? company;
  final String? accessToken;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        if (company != null && company!.isNotEmpty) 'company': company,
        if (accessToken != null && accessToken!.isNotEmpty)
          'access_token': accessToken,
      };

  static AuthUser fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      role: normalizeRole(json['role'] as String?),
      company: json['company'] as String?,
      accessToken: json['access_token'] as String?,
    );
  }

  static String normalizeRole(String? r) {
    final x = (r ?? 'worker').toLowerCase().trim();
    const allowed = <String>{
      'admin',
      'supervisor',
      'worker',
      'agent',
      'auditor',
      'state_authority',
    };
    if (allowed.contains(x)) return x;
    return 'worker';
  }

  static AuthUser? tryDecode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? company,
    String? accessToken,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      company: company ?? this.company,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}
