const String kRoleSupervisorTransport = 'supervisor_transport';

bool roleUsesTransportShell(String? role) => role == kRoleSupervisorTransport;

String transportRoleBadge(String role) {
  switch (role) {
    case kRoleSupervisorTransport:
      return 'SUPERVISOR TRANSPORT';
    case 'supervisor_reception':
      return 'SUPERVISOR RECEPTION';
    case 'supervisor_extraction':
      return 'SUPERVISOR EXTRACTION';
    default:
      return role.toUpperCase();
  }
}
