/// Personas UI mobile (navigation) et rôles API backend.
class AppRoles {
  AppRoles._();

  /// Persona agent de contrôle → API `AGENT_CONTROLE`
  static const agent = 'agent';

  /// Persona superviseur terrain → API `SUPERVISOR_*` ou `SUPERVISOR`
  static const supervisor = 'supervisor';

  static const Set<String> supervisorApiRoles = {
    'SUPERVISOR',
    'SUPERVISOR_EXTRACTION',
    'SUPERVISOR_TRANSPORT',
    'SUPERVISOR_RECEPTION',
  };

  static const String agentApiRole = 'AGENT_CONTROLE';

  static String label(String persona) {
    switch (persona) {
      case agent:
        return 'Agent de contrôle';
      case supervisor:
        return 'Superviseur';
      default:
        return persona;
    }
  }

  static bool isSupervisorApiRole(String apiRole) =>
      supervisorApiRoles.contains(apiRole);

  static bool matchesPersona(String persona, String apiRole) {
    if (persona == agent) return apiRole == agentApiRole;
    if (persona == supervisor) return isSupervisorApiRole(apiRole);
    return false;
  }
}
