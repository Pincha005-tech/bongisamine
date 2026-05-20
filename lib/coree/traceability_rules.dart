/// Règles alignées sur `mine_back/app/core/roles.py` et `traceability_service.py`.
class TraceabilityRules {
  TraceabilityRules._();

  static const Map<String, String> targetByRole = {
    'SUPERVISOR_EXTRACTION': 'STORED',
    'SUPERVISOR_TRANSPORT': 'IN_TRANSPORT',
    'SUPERVISOR_RECEPTION': 'DEPOT_RECEIVED',
  };

  static const Map<String, String> previousByTarget = {
    'STORED': 'EXTRACTED',
    'IN_TRANSPORT': 'STORED',
    'DEPOT_RECEIVED': 'IN_TRANSPORT',
  };

  static const List<String> statusChain = [
    'EXTRACTED',
    'STORED',
    'IN_TRANSPORT',
    'DEPOT_RECEIVED',
    'EXPORT_READY',
    'EXPORTED',
  ];

  static const Set<String> fullAccessRoles = {
    'ADMIN',
    'SUPERVISOR',
    'STATE_AUTHORITY',
  };

  static String normalize(String? status) {
    if (status == null || status.trim().isEmpty) return 'EXTRACTED';
    return status.toUpperCase().replaceAll('-', '_');
  }

  static String? targetForRole(String apiRole) => targetByRole[apiRole];

  static String? requiredPreviousForRole(String apiRole) {
    final target = targetForRole(apiRole);
    if (target == null) return null;
    return previousByTarget[target];
  }

  static bool hasFullAccess(String apiRole) => fullAccessRoles.contains(apiRole);

  /// Vérifie si le lot est au bon statut avant le scan pour ce rôle.
  static bool canScan(String apiRole, String? currentStatus) {
    if (hasFullAccess(apiRole)) return true;
    final required = requiredPreviousForRole(apiRole);
    if (required == null) return false;
    return normalize(currentStatus) == normalize(required);
  }

  static String? nextStatusInChain(String? currentStatus) {
    final current = normalize(currentStatus);
    final index = statusChain.indexOf(current);
    if (index >= 0 && index < statusChain.length - 1) {
      return statusChain[index + 1];
    }
    return null;
  }

  static String roleHint(String apiRole) {
    if (hasFullAccess(apiRole)) {
      return 'Compte administrateur : prochaine étape automatique dans la chaîne.';
    }
    final target = targetForRole(apiRole);
    final prev = requiredPreviousForRole(apiRole);
    if (target == null) {
      return 'Rôle non configuré pour le scan terrain.';
    }
    return 'Scannez un lot en statut $prev → passage à $target.';
  }

  static String blockedMessage(String apiRole, String? currentStatus) {
    final current = normalize(currentStatus);
    if (hasFullAccess(apiRole)) {
      return 'Transition impossible depuis le statut $current.';
    }
    final target = targetForRole(apiRole);
    final prev = requiredPreviousForRole(apiRole);
    return 'Ce lot est en « $current ». '
        'En tant que superviseur, vous devez scanner un lot encore en « $prev » '
        '(pour le faire passer à $target).';
  }
}
