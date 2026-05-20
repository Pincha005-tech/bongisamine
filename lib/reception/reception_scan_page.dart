import 'dart:convert';



import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../coree/auth/auth_controller.dart';

import '../coree/colors/app_colors.dart';

import '../coree/qr/batch_code_parser.dart';

import '../coree/theme/app_page_style.dart';

import '../coree/api/traceability_api_mapper.dart';

import '../services/api_service.dart';

import '../services/traceability_scan_service.dart';

import '../widgets/face_capture_picker.dart';

import '../widgets/lot_batch_picker.dart';

import 'reception_models.dart';

import 'reception_widgets.dart';



class ReceptionScanPage extends StatefulWidget {

  const ReceptionScanPage({super.key, this.onNavigateTab});



  final void Function(int tabIndex)? onNavigateTab;



  @override

  State<ReceptionScanPage> createState() => _ReceptionScanPageState();

}



class _ReceptionScanPageState extends State<ReceptionScanPage> {

  final _locationCtrl = TextEditingController(text: 'Dépôt réception Likasi');

  final _commentCtrl = TextEditingController();

  String? _selectedBatch;

  QrScanPayload? _qrPayload;

  bool _faceOk = false;

  String? _faceWorkerName;

  String? _faceImagePath;

  bool _busy = false;

  ReceptionScanResult? _lastResult;

  ReceptionFraudCheckResult? _fraudResult;

  List<String> _batchCodes = [];

  List<String> _workerNames = [];



  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _load());

  }



  @override

  void dispose() {

    _locationCtrl.dispose();

    _commentCtrl.dispose();

    super.dispose();

  }



  Future<void> _load() async {

    final qrs = await ApiService.fetchQrcodes();

    final workers = await ApiService.fetchWorkersPaginated(limit: 100);

    if (!mounted) return;

    setState(() {

      _batchCodes = qrs

          .where((q) =>

              (q['current_status'] as String? ?? '').toUpperCase() ==

              ReceptionWorkflow.scanSourceStatus)

          .map((q) {

            var batch = q['batch_code'] as String? ?? '';

            if (batch.isEmpty && q['data'] != null) {

              try {

                final p = jsonDecode(q['data'] as String);

                if (p is Map) batch = p['batch_code'] as String? ?? '';

              } catch (_) {}

            }

            return batch;

          })

          .where((b) => b.isNotEmpty)

          .toList();

      _workerNames = workers

          .map((w) =>

              '${w['first_name'] ?? ''} ${w['last_name'] ?? ''}'.trim())

          .where((n) => n.isNotEmpty)

          .toList();

    });

  }



  Future<void> _runFraudCheck() async {

    if (_selectedBatch == null || _qrPayload == null) {

      _snack('Scannez ou sélectionnez un lot');

      return;

    }

    if (!_faceOk || _faceImagePath == null) {

      _snack('Capturez d\'abord le visage');

      return;

    }

    final auth = context.read<AuthController>();

    if (!auth.hasApiToken) {

      _snack('Session expirée — reconnectez-vous');

      return;

    }



    setState(() => _busy = true);

    final body = await ApiService.postFaceQrFraudCheck(

      imagePath: _faceImagePath!,

      qrData: _qrPayload!.qrData,

      qrSignature: _qrPayload!.signature,

    );

    if (!mounted) return;

    setState(() {

      _busy = false;

      if (body != null) {

        final fraud = body['fraud_detected'] == true;

        _fraudResult = ReceptionFraudCheckResult(

          passed: body['success'] == true && !fraud,

          message: body['message'] as String? ??

              (fraud ? 'Fraude détectée' : 'Contrôle OK'),

          riskLevel: body['step'] as String?,

        );

      } else {

        _fraudResult = const ReceptionFraudCheckResult(

          passed: false,

          message: 'Échec du contrôle fraude',

        );

      }

    });

  }



  Future<void> _submitReception() async {

    if (_selectedBatch == null) {

      _snack('Sélectionnez un lot');

      return;

    }

    if (!_faceOk || _faceImagePath == null) {

      _snack('Capturez le visage avec la caméra');

      return;

    }

    if (_qrPayload == null) {

      _snack('Scannez le QR du lot pour obtenir la signature');

      return;

    }

    final auth = context.read<AuthController>();

    if (!auth.hasApiToken) {

      _snack('Session expirée — reconnectez-vous');

      return;

    }



    setState(() {

      _busy = true;

      _lastResult = null;

    });



    final api = await TraceabilityScanService.submit(

      appRole: auth.role,

      imagePath: _faceImagePath!,

      qrData: _qrPayload!.qrData,

      qrSignature: _qrPayload!.signature,

      locationName: _locationCtrl.text.trim(),

      comment: _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),

      action: ReceptionWorkflow.defaultAction,

    );



    if (!mounted) return;

    setState(() {

      _busy = false;

      if (api.ok && api.body != null) {

        _lastResult = ReceptionScanResult.success(

          TraceabilityApiMapper.toReception(api.body!),

        );

        _snack('Lot enregistré');

        _load();

      } else {

        _lastResult = ReceptionScanResult.failure(

          errorCode: 'API_ERROR',

          errorMessage: api.errorMessage ?? 'Erreur scan',

        );

      }

    });

  }



  void _snack(String msg) {

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  }



  @override

  Widget build(BuildContext context) {

    final top = MediaQuery.paddingOf(context).top;



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

                    'Scan réception',

                    style: TextStyle(

                      fontSize: 24,

                      fontWeight: FontWeight.w800,

                      color: context.appTitleAccent,

                    ),

                  ),

                  const SizedBox(height: 6),

                  Text(

                    'Visage + QR → ${ReceptionWorkflow.targetStatus} '

                    '(action ${ReceptionWorkflow.defaultAction})',

                    style: TextStyle(

                      fontSize: 13,

                      color: context.appOnSurfaceMuted,

                      fontWeight: FontWeight.w500,

                    ),

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

                      LotBatchPicker(

                        batchCodes: _batchCodes,

                        selectedBatch: _selectedBatch,

                        dropdownHint: 'Choisir un lot en IN_TRANSPORT',

                        listEmptyMessage:

                            'Aucun lot en IN_TRANSPORT sur le serveur.',

                        onBatchChanged: (v) => setState(() => _selectedBatch = v),

                        onQrPayload: (p) => setState(() => _qrPayload = p),

                      ),

                      const SizedBox(height: 14),

                      FaceCapturePicker(

                        matched: _faceOk,

                        workerName: _faceWorkerName,

                        imagePath: _faceImagePath,

                        knownWorkerNames: _workerNames,

                        onCapture: (ok, {workerName, imagePath}) => setState(() {

                          _faceOk = ok;

                          _faceWorkerName = workerName;

                          _faceImagePath = imagePath;

                        }),

                      ),

                      const SizedBox(height: 8),

                      TextField(

                        controller: _locationCtrl,

                        decoration: const InputDecoration(

                          labelText: 'Lieu (location_name)',

                          prefixIcon: Icon(Icons.place_outlined),

                        ),

                      ),

                      const SizedBox(height: 10),

                      TextField(

                        controller: _commentCtrl,

                        decoration: const InputDecoration(

                          labelText: 'Commentaire (optionnel)',

                          prefixIcon: Icon(Icons.notes_outlined),

                        ),

                        maxLines: 2,

                      ),

                    ],

                  ),

                ),

              ),

            ),

          ),

          SliverToBoxAdapter(

            child: Padding(

              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

              child: Row(

                children: [

                  Expanded(

                    child: OutlinedButton.icon(

                      onPressed: _busy ? null : _runFraudCheck,

                      icon: const Icon(Icons.shield_outlined),

                      label: const Text('Pré-contrôle fraude'),

                    ),

                  ),

                  const SizedBox(width: 10),

                  Expanded(

                    child: FilledButton.icon(

                      onPressed: _busy ? null : _submitReception,

                      icon: _busy

                          ? const SizedBox(

                              width: 18,

                              height: 18,

                              child: CircularProgressIndicator(

                                strokeWidth: 2,

                                color: AppColors.cream,

                              ),

                            )

                          : const Icon(Icons.check_rounded),

                      label: const Text('Enregistrer'),

                    ),

                  ),

                ],

              ),

            ),

          ),

          if (_fraudResult != null)

            SliverToBoxAdapter(child: _buildFraudCard(context, _fraudResult!)),

          if (_lastResult != null)

            SliverToBoxAdapter(child: _buildScanResultCard(context, _lastResult!)),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

        ],

      ),

    );

  }



  Widget _buildFraudCard(BuildContext context, ReceptionFraudCheckResult r) {

    final ok = r.passed;

    return Padding(

      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

      child: Material(

        color: ok

            ? AppColors.success.withValues(alpha: 0.12)

            : AppColors.error.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(14),

        child: Padding(

          padding: const EdgeInsets.all(14),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                'POST /security/face-qr-fraud-check',

                style: TextStyle(

                  fontSize: 11,

                  fontWeight: FontWeight.w700,

                  color: context.appOnSurfaceMuted,

                ),

              ),

              const SizedBox(height: 6),

              Text(

                r.message,

                style: TextStyle(

                  fontWeight: FontWeight.w700,

                  color: ok ? AppColors.success : AppColors.error,

                ),

              ),

              if (r.riskLevel != null)

                Text(

                  'Étape : ${r.riskLevel}',

                  style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted),

                ),

            ],

          ),

        ),

      ),

    );

  }



  Widget _buildScanResultCard(BuildContext context, ReceptionScanResult r) {

    if (!r.success) {

      return Padding(

        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

        child: Material(

          color: AppColors.error.withValues(alpha: 0.1),

          borderRadius: BorderRadius.circular(14),

          child: Padding(

            padding: const EdgeInsets.all(14),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const Text(

                  'Échec — POST /traceability/reception/scan',

                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.error),

                ),

                const SizedBox(height: 6),

                Text(r.errorMessage ?? 'Erreur'),

                if (r.errorCode == 'INVALID_TRANSITION')

                  TextButton(

                    onPressed: () => widget.onNavigateTab?.call(3),

                    child: const Text('Voir les alertes'),

                  ),

              ],

            ),

          ),

        ),

      );

    }

    final m = r.movement!;

    return Padding(

      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

      child: Material(

        color: AppColors.success.withValues(alpha: 0.1),

        borderRadius: BorderRadius.circular(14),

        child: Padding(

          padding: const EdgeInsets.all(14),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const Text(

                'Succès — lot réceptionné',

                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.success),

              ),

              const SizedBox(height: 8),

              Row(

                children: [

                  ReceptionStatusBadge(m.previousStatus, status: m.previousStatus),

                  const Padding(

                    padding: EdgeInsets.symmetric(horizontal: 6),

                    child: Icon(Icons.arrow_forward_rounded, size: 16),

                  ),

                  ReceptionStatusBadge(m.newStatus, status: m.newStatus),

                ],

              ),

              const SizedBox(height: 8),

              Text('Lieu : ${m.locationName ?? "—"}'),

              Text('Action : ${m.action}'),

              Text('Horodatage : ${m.createdAtLabel}'),

            ],

          ),

        ),

      ),

    );

  }

}


