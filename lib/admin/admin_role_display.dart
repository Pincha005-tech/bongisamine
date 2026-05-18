/// Libellés affichés pour le centre de contrôle (aligné cahier des charges).
String adminRoleBadge(String role) {
  switch (role) {
    case 'admin':
      return 'ADMIN';
    case 'supervisor':
      return 'SUPERVISOR';
    case 'agent':
      return 'AGENT';
    case 'auditor':
      return 'AUDITOR';
    case 'state_authority':
      return 'STATE_AUTHORITY';
    case 'worker':
    default:
      return 'AGENT';
  }
}

bool roleUsesAdminShell(String? role) => role == 'admin';
