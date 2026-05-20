/// Résultat d'une capture / reconnaissance faciale via caméra.
class FaceCaptureResult {
  const FaceCaptureResult({
    required this.matched,
    this.workerName,
    this.imagePath,
  });

  final bool matched;
  final String? workerName;
  /// Chemin image pour `multipart` (`POST /traceability/*/scan`, `/face/*`).
  final String? imagePath;
}
