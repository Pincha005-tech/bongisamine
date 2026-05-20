/// Mapping rôles `mine_back` ↔ rôles app Flutter.
class ApiRoleMapper {
  ApiRoleMapper._();

  static const supervisorBackendRoles = {
    'SUPERVISOR',
    'SUPERVISOR_EXTRACTION',
    'SUPERVISOR_TRANSPORT',
    'SUPERVISOR_RECEPTION',
  };

  /// `POST /auth/login` → rôle stocké dans l'app.
  static String appRoleFromBackend(String? backendRole) {
    switch ((backendRole ?? '').toUpperCase()) {
      case 'ADMIN':
        return 'admin';
      case 'SUPERVISOR_EXTRACTION':
        return 'supervisor_extraction';
      case 'SUPERVISOR_TRANSPORT':
        return 'supervisor_transport';
      case 'SUPERVISOR_RECEPTION':
        return 'supervisor_reception';
      case 'SUPERVISOR':
        return 'supervisor';
      case 'AGENT_CONTROLE':
        return 'agent_controle';
      case 'AUDITOR':
        return 'auditor';
      case 'STATE_AUTHORITY':
        return 'state_authority';
      case 'AGENT':
        return 'agent';
      default:
        return 'worker';
    }
  }

  static bool isSupervisorAppRole(String role) {
    return role == 'supervisor' ||
        role == 'supervisor_extraction' ||
        role == 'supervisor_transport' ||
        role == 'supervisor_reception';
  }

  static bool backendRoleMatchesApp(String backendRole, String appRole) {
    return appRoleFromBackend(backendRole) == appRole;
  }
}
