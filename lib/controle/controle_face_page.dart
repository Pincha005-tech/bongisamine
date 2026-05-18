import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/face/face_capture_result.dart';
import '../coree/theme/app_page_style.dart';
import '../pages/scan/face_scan_screen.dart';
import 'controle_mock_data.dart';

class ControleFacePage extends StatefulWidget {
  const ControleFacePage({super.key});

  @override
  State<ControleFacePage> createState() => _ControleFacePageState();
}

class _ControleFacePageState extends State<ControleFacePage> {
  int? _registerWorkerId;
  int? _recognizeWorkerId;
  bool _busy = false;
  ControleFaceRegisterResult? _registerResult;
  ControleFaceRecognizeResult? _recognizeResult;

  List<String> get _workerNames =>
      ControleMockData.workers.map((w) => w.fullName).toList();

  Future<FaceCaptureResult?> _captureFace({
    required String title,
    required String hint,
    required String actionLabel,
  }) async {
    return Navigator.push<FaceCaptureResult>(
      context,
      MaterialPageRoute(
        builder: (_) => FaceScanScreen(
          title: title,
          hint: hint,
          actionLabel: actionLabel,
          knownWorkerNames: _workerNames,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _register() async {
    final id = _registerWorkerId;
    if (id == null) {
      _snack('Sélectionnez un ouvrier');
      return;
    }
    setState(() => _busy = true);
    final face = await _captureFace(
      title: 'Enregistrer l\'empreinte',
      hint:
          'Cadrez le visage de l\'ouvrier dans l\'ovale, puis confirmez l\'enregistrement.',
      actionLabel: 'Enregistrer le visage',
    );
    if (!mounted) return;
    if (face == null || !face.matched) {
      setState(() => _busy = false);
      if (face == null) return;
      _snack('Aucun visage détecté — enregistrement annulé');
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final r = ControleMockData.simulateRegisterFace(id);
    setState(() {
      _busy = false;
      _registerResult = r;
    });
    _snack(r.message);
  }

  Future<void> _recognize() async {
    setState(() => _busy = true);
    final face = await _captureFace(
      title: 'Contrôle d\'accès',
      hint: 'Cadrez le visage pour vérification à l\'entrée du site.',
      actionLabel: 'Vérifier le visage',
    );
    if (!mounted) return;
    if (face == null) {
      setState(() => _busy = false);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final r = ControleMockData.simulateRecognizeFace(
      selectedWorkerId: _recognizeWorkerId,
      simulateMatch: face.matched,
    );
    setState(() {
      _busy = false;
      _recognizeResult = r;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final withoutFace = ControleMockData.workers.where((w) => !w.faceRegistered).toList();

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, top + 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Empreinte faciale',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: context.appTitleAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'POST /face/register/{id} · POST /face/recognize',
                    style: TextStyle(fontSize: 13, color: context.appOnSurfaceMuted),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: context.appCardColor,
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enregistrement',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: context.appOnSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        key: ValueKey(_registerWorkerId),
                        isExpanded: true,
                        initialValue: _registerWorkerId,
                        decoration: const InputDecoration(
                          hintText: 'Ouvrier sans visage ou à mettre à jour',
                        ),
                        items: [
                          for (final w in ControleMockData.workers)
                            DropdownMenuItem(
                              value: w.id,
                              child: Text(
                                '${w.fullName} ${w.faceRegistered ? "(déjà)" : ""}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _registerWorkerId = v),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _register,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Capturer & enregistrer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_registerResult != null)
            SliverToBoxAdapter(child: _resultCard(
              'POST /face/register/{worker_id}',
              _registerResult!.success,
              _registerResult!.message,
            )),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Material(
                color: context.appCardColor,
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reconnaissance (contrôle accès)',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: context.appOnSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        key: ValueKey(_recognizeWorkerId),
                        isExpanded: true,
                        initialValue: _recognizeWorkerId,
                        decoration: const InputDecoration(
                          hintText: 'Ouvrier attendu (optionnel)',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Auto (mock)'),
                          ),
                          for (final w in ControleMockData.workers.where((w) => w.faceRegistered))
                            DropdownMenuItem(
                              value: w.id,
                              child: Text(
                                w.fullName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _recognizeWorkerId = v),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _recognize,
                          icon: _busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.face_retouching_natural),
                          label: Text(_busy ? 'Caméra…' : 'Scanner visage (caméra)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_recognizeResult != null)
            SliverToBoxAdapter(child: _resultCard(
              'POST /face/recognize',
              _recognizeResult!.match,
              _recognizeResult!.match
                  ? '${_recognizeResult!.message} — ${_recognizeResult!.workerName} (#${_recognizeResult!.workerId})'
                  : _recognizeResult!.message,
            )),
          if (withoutFace.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${withoutFace.length} ouvrier(s) sans empreinte : '
                  '${withoutFace.map((w) => w.firstName).join(", ")}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appOnSurfaceMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  Widget _resultCard(String endpoint, bool ok, String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: (ok ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(endpoint, style: TextStyle(fontSize: 11, color: context.appOnSurfaceMuted)),
              const SizedBox(height: 6),
              Text(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ok ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
