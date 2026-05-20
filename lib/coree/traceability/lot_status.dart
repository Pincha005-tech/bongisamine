/// Statuts lots — alignés `mine_back` traceability_service.
class LotStatus {
  LotStatus._();

  static const extracted = 'EXTRACTED';
  static const stored = 'STORED';
  static const inTransport = 'IN_TRANSPORT';
  static const depotReceived = 'DEPOT_RECEIVED';
  static const exportReady = 'EXPORT_READY';
  static const exported = 'EXPORTED';
  static const blocked = 'BLOCKED';
}
