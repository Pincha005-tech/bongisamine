const String kRoleSupervisorExtraction = 'supervisor_extraction';

bool roleUsesExtractionShell(String? role) => role == kRoleSupervisorExtraction;

String extractionRoleBadge(String role) {
  switch (role) {
    case kRoleSupervisorExtraction:
      return 'SUPERVISOR EXTRACTION';
    case 'supervisor_transport':
      return 'SUPERVISOR TRANSPORT';
    case 'supervisor_reception':
      return 'SUPERVISOR RECEPTION';
    default:
      return role.toUpperCase();
  }
}
