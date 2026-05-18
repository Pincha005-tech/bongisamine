import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'app_roles.dart';

@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.apiRole,
    this.company,
  });

  final String id;
  final String name;
  final String email;
  /// Persona UI : `agent` | `supervisor`
  final String role;
  /// Rôle API : `AGENT_CONTROLE`, `SUPERVISOR_EXTRACTION`, etc.
  final String apiRole;
  final String? company;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'apiRole': apiRole,
        if (company != null && company!.isNotEmpty) 'company': company,
      };

  static AuthUser fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      role: normalizePersona(json['role'] as String?),
      apiRole: json['apiRole'] as String? ?? json['api_role'] as String? ?? '',
      company: json['company'] as String?,
    );
  }

  static String normalizePersona(String? r) {
    final x = (r ?? 'supervisor').toLowerCase().trim().replaceAll('-', '_');
    if (x == 'agent_controle' || x == 'agent') return AppRoles.agent;
    if (x == 'supervisor' ||
        x.startsWith('supervisor_') ||
        x == 'superviseur') {
      return AppRoles.supervisor;
    }
    return AppRoles.supervisor;
  }

  static AuthUser? tryDecode(String raw) {
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? apiRole,
    String? company,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      apiRole: apiRole ?? this.apiRole,
      company: company ?? this.company,
    );
  }
}
