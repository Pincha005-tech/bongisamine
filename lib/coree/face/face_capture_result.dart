/// Résultat d'une capture / reconnaissance faciale via caméra.
class FaceCaptureResult {
  const FaceCaptureResult({
    required this.matched,
    this.workerName,
  });

  final bool matched;
  final String? workerName;
}
