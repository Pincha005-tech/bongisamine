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

import 'transport_models.dart';

import 'transport_widgets.dart';



class TransportScanPage extends StatefulWidget {

  const TransportScanPage({super.key, this.onNavigateTab});



  final void Function(int tabIndex)? onNavigateTab;



  @override

  State<TransportScanPage> createState() => _TransportScanPageState();

}



class _TransportScanPageState extends State<TransportScanPage> {

  final _locationCtrl = TextEditingController(text: 'Quai chargement Kolwezi');

  final _commentCtrl = TextEditingController();

  String? _selectedBatch;

  QrScanPayload? _qrPayload;

  bool _faceOk = false;

  String? _faceWorkerName;

  String? _faceImagePath;

  bool _busy = false;

  TransportScanResult? _lastResult;

  TransportSecureReadResult? _secureReadResult;

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

              TransportWorkflow.scanSourceStatus)

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



  Future<void> _runSecureRead() async {

    if (_qrPayload == null || !_faceOk || _faceImagePath == null) {

      _snack('Lot scanné + visage requis');

      return;

    }

    final auth = context.read<AuthController>();

    if (!auth.hasApiToken) {

      _snack('Session expirée — reconnectez-vous');

      return;

    }



    setState(() => _busy = true);

    final body = await ApiService.postFaceQrSecureRead(

      imagePath: _faceImagePath!,

      qrData: _qrPayload!.qrData,

      qrSignature: _qrPayload!.signature,

    );

    if (!mounted) return;

    setState(() {

      _busy = false;

      _secureReadResult = TransportSecureReadResult(

        valid: body?['success'] == true || body?['valid'] == true,

        message: body?['message'] as String? ?? 'Réponse API',

        step: body?['step'] as String?,

        batchCode: body?['batch_code'] as String?,

        currentStatus: body?['current_status'] as String?,

      );

    });

  }



  Future<void> _submitTransport() async {

    if (_selectedBatch == null || !_faceOk || _faceImagePath == null) {

      _snack('Lot + visage (caméra) requis');

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

      action: TransportWorkflow.defaultAction,

    );



    if (!mounted) return;

    setState(() {

      _busy = false;

      if (api.ok && api.body != null) {

        _lastResult = TransportScanResult.success(

          TraceabilityApiMapper.toTransport(api.body!),

        );

        _snack('Lot chargé');

        _load();

      } else {

        _lastResult = TransportScanResult.failure(

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

                    'Scan transport',

                    style: TextStyle(

                      fontSize: 24,

                      fontWeight: FontWeight.w800,

                      color: context.appTitleAccent,

                    ),

                  ),

                  const SizedBox(height: 6),

                  Text(

                    'Visage + QR → ${TransportWorkflow.targetStatus} '

                    '(action ${TransportWorkflow.defaultAction})',

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

                        dropdownHint: 'Choisir un lot en STORED',

                        listEmptyMessage: 'Aucun lot en STORED sur le serveur.',

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

                      onPressed: _busy ? null : _runSecureRead,

                      icon: const Icon(Icons.lock_outline_rounded),

                      label: const Text('Lecture sécurisée'),

                    ),

                  ),

                  const SizedBox(width: 10),

                  Expanded(

                    child: FilledButton.icon(

                      onPressed: _busy ? null : _submitTransport,

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

                      label: const Text('Charger'),

                    ),

                  ),

                ],

              ),

            ),

          ),

          if (_secureReadResult != null)

            SliverToBoxAdapter(child: _buildSecureReadCard(context, _secureReadResult!)),

          if (_lastResult != null)

            SliverToBoxAdapter(child: _buildScanResultCard(context, _lastResult!)),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

        ],

      ),

    );

  }



  Widget _buildSecureReadCard(BuildContext context, TransportSecureReadResult r) {

    return Padding(

      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

      child: Material(

        color: (r.valid ? AppColors.success : AppColors.error).withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(14),

        child: Padding(

          padding: const EdgeInsets.all(14),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                'POST /security/face-qr-secure-read',

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

                  color: r.valid ? AppColors.success : AppColors.error,

                ),

              ),

              if (r.step != null)

                Text('Étape : ${r.step}', style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted)),

              if (r.currentStatus != null)

                Text('Statut lot : ${r.currentStatus}', style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted)),

            ],

          ),

        ),

      ),

    );

  }



  Widget _buildScanResultCard(BuildContext context, TransportScanResult r) {

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

                  'Échec — POST /traceability/transport/scan',

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

                'Succès — lot en transport',

                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.success),

              ),

              const SizedBox(height: 8),

              Row(

                children: [

                  TransportStatusBadge(m.previousStatus, status: m.previousStatus),

                  const Padding(

                    padding: EdgeInsets.symmetric(horizontal: 6),

                    child: Icon(Icons.arrow_forward_rounded, size: 16),

                  ),

                  TransportStatusBadge(m.newStatus, status: m.newStatus),

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


