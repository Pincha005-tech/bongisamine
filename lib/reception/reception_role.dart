/// Rôles superviseurs alignés sur `mine_back/app/core/roles.py`.
const String kRoleSupervisorReception = 'supervisor_reception';
const String kRoleSupervisorExtraction = 'supervisor_extraction';
const String kRoleSupervisorTransport = 'supervisor_transport';

bool roleUsesReceptionShell(String? role) => role == kRoleSupervisorReception;

String receptionRoleBadge(String role) {
  switch (role) {
    case kRoleSupervisorReception:
      return 'SUPERVISOR RECEPTION';
    case kRoleSupervisorExtraction:
      return 'SUPERVISOR EXTRACTION';
    case kRoleSupervisorTransport:
      return 'SUPERVISOR TRANSPORT';
    case 'supervisor':
      return 'SUPERVISOR';
    default:
      return role.toUpperCase();
  }
}
