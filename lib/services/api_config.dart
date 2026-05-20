/// URL de l'API FastAPI (`mine_back`) — voir `INTEGRATION_FRONTEND.md`.
///
/// Build avec URL Render :
/// `flutter run --dart-define=API_BASE_URL=https://bongisa-mine-api.onrender.com`
///
/// - Émulateur Android : `http://10.0.2.2:8000`
/// - Appareil physique : IP LAN du PC
/// - iOS simulateur : `http://127.0.0.1:8000`
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bongisa-mine-api.onrender.com',
  );

  static const Duration defaultTimeout = Duration(seconds: 30);
}
