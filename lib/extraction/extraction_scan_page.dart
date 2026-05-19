import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_controller.dart';
import '../coree/utils/keyboard_utils.dart';
import '../coree/colors/app_colors.dart';
import '../coree/qr/batch_code_parser.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/api/traceability_api_mapper.dart';
import '../services/api_service.dart';
import '../services/traceability_scan_service.dart';
import '../widgets/face_capture_picker.dart';
import '../widgets/lot_batch_picker.dart';
import 'extraction_models.dart';
import 'extraction_widgets.dart';

class ExtractionScanPage extends StatefulWidget {
  const ExtractionScanPage({
    super.key,
    this.onNavigateTab,
  });

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<ExtractionScanPage> createState() => ExtractionScanPageState();
}

class ExtractionScanPageState extends State<ExtractionScanPage> {
  final _locationCtrl = TextEditingController(text: 'Fosse Nord — Zone A');
  final _locationFocus = FocusNode();
  String? _selectedBatch;
  QrScanPayload? _qrPayload;
  bool _faceOk = false;
  String? _faceWorkerName;
  String? _faceImagePath;
  bool _busy = false;
  ExtractionScanResult? _lastResult;
  List<String> _batchCodes = [];
  List<String> _workerNames = [];
  bool _loadingBatches = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  /// Préremplit le lot (depuis Minerais → Scanner).
  void applyBatchPrefill(String batchCode) => _selectBatch(batchCode);

  void _selectBatch(String batchCode) {
    final pending = batchCode.trim();
    if (pending.isEmpty) return;

    String? match;
    for (final c in _batchCodes) {
      if (c.toUpperCase() == pending.toUpperCase()) {
        match = c;
        break;
      }
    }
    final selected = match ?? pending;
    final codes = List<String>.from(_batchCodes);
    if (!codes.contains(selected)) codes.insert(0, selected);

    setState(() {
      _batchCodes = codes;
      _selectedBatch = selected;
      _qrPayload = null;
    });
  }

  void _ensureSelectedInBatchCodes() {
    final sel = _selectedBatch;
    if (sel != null && sel.isNotEmpty && !_batchCodes.contains(sel)) {
      _batchCodes = [sel, ..._batchCodes];
    }
  }

  Future<void> _load() async {
    if (_loadingBatches) return;
    _loadingBatches = true;
    final qrs = await ApiService.fetchQrcodes();
    final workers = await ApiService.fetchWorkersPaginated(limit: 100);
    _loadingBatches = false;
    if (!mounted) return;
    setState(() {
      _batchCodes = qrs
          .where((q) =>
              (q['current_status'] as String? ?? '').toUpperCase() ==
              ExtractionWorkflow.scanSourceStatus)
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
      _ensureSelectedInBatchCodes();
    });
  }

  Future<void> _submitStockage() async {
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
      action: ExtractionWorkflow.defaultAction,
    );

    if (!mounted) return;
    setState(() {
      _busy = false;
      if (api.ok && api.body != null) {
        _lastResult = ExtractionScanResult.success(
          TraceabilityApiMapper.toExtraction(api.body!),
        );
        _snack('Lot stocké');
        _load();
      } else {
        _lastResult = ExtractionScanResult.failure(
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
                    'Scan stockage',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: context.appTitleAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Visage + QR → ${ExtractionWorkflow.targetStatus} '
                    '(action ${ExtractionWorkflow.defaultAction})',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appOnSurfaceMuted,
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
                        dropdownHint: 'Choisir un lot en EXTRACTED',
                        listEmptyMessage:
                            'Aucun lot en EXTRACTED sur le serveur.',
                        onBatchChanged: (v) => setState(() {
                          _selectedBatch = v;
                          if (v == null) _qrPayload = null;
                        }),
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
                      TextField(
                        controller: _locationCtrl,
                        focusNode: _locationFocus,
                        decoration: const InputDecoration(
                          labelText: 'Lieu (location_name)',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
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
              child: FilledButton.icon(
                onPressed: _busy ? null : _submitStockage,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.cream,
                        ),
                      )
                    : const Icon(Icons.warehouse_outlined),
                label: const Text('Enregistrer le stockage'),
              ),
            ),
          ),
          if (_lastResult != null)
            SliverToBoxAdapter(child: _buildResultCard(context, _lastResult!)),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, ExtractionScanResult r) {
    if (!r.success) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Material(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(r.errorMessage ?? 'Erreur'),
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
              Row(
                children: [
                  ExtractionStatusBadge(m.previousStatus, status: m.previousStatus),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward_rounded, size: 16),
                  ),
                  ExtractionStatusBadge(m.newStatus, status: m.newStatus),
                ],
              ),
              const SizedBox(height: 8),
              Text('Lieu : ${m.locationName ?? "—"}'),
            ],
          ),
        ),
      ),
    );
  }
}
