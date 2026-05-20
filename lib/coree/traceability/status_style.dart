import 'package:flutter/material.dart';

import 'lot_status.dart';

Color lotStatusColor(String status) {
  switch (status) {
    case LotStatus.inTransport:
      return const Color(0xFFF59E0B);
    case LotStatus.stored:
      return const Color(0xFF8B5CF6);
    case LotStatus.extracted:
      return const Color(0xFF3B82F6);
    case LotStatus.depotReceived:
    case LotStatus.exportReady:
    case LotStatus.exported:
      return const Color(0xFF22C55E);
    case LotStatus.blocked:
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF6B7280);
  }
}

Color alertSeverityColor(String severity) {
  switch (severity) {
    case 'critical':
      return const Color(0xFFDC2626);
    case 'high':
      return const Color(0xFFEA580C);
    case 'medium':
      return const Color(0xFFFBBF24);
    default:
      return const Color(0xFF94A3B8);
  }
}

String alertSeverityLabel(String severity) {
  switch (severity) {
    case 'critical':
      return 'Critique';
    case 'high':
      return 'Élevé';
    case 'medium':
      return 'Modéré';
    default:
      return 'Info';
  }
}

Color attendanceStatusColor(String status) {
  switch (status) {
    case 'present':
      return const Color(0xFF22C55E);
    case 'late':
      return const Color(0xFFF59E0B);
    case 'absent':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF6B7280);
  }
}

String attendanceStatusLabel(String status) {
  switch (status) {
    case 'present':
      return 'Présent';
    case 'late':
      return 'Retard';
    case 'checked_out':
    case 'completed':
      return 'Terminé';
    case 'absent':
      return 'Absent';
    default:
      return status;
  }
}
