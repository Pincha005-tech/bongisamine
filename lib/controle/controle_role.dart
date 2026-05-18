const String kRoleAgentControle = 'agent_controle';

bool roleUsesControleShell(String? role) => role == kRoleAgentControle;

String controleRoleBadge(String role) {
  switch (role) {
    case kRoleAgentControle:
      return 'AGENT CONTROLE';
    default:
      return role.toUpperCase();
  }
}
