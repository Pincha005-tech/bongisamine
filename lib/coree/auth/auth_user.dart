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
  });

  final String id;
  final String name;
  final String email;
  /// `admin` | `supervisor` | `worker`
  final String role;
  final String? company;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        if (company != null && company!.isNotEmpty) 'company': company,
      };

  static AuthUser fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      role: normalizeRole(json['role'] as String?),
      company: json['company'] as String?,
    );
  }

  static String normalizeRole(String? r) {
    final x = (r ?? 'worker').toLowerCase().trim();
    if (x == 'admin' || x == 'supervisor' || x == 'worker') return x;
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
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      company: company ?? this.company,
    );
  }
}
