/// URL de l'API FastAPI (`mine_back`).
///
/// - Émulateur Android : `10.0.2.2` pointe vers la machine hôte.
/// - Appareil physique : IP LAN du PC (ex. `http://192.168.1.42:8000`).
/// - iOS simulateur : souvent `http://127.0.0.1:8000`.
abstract final class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000';
}
