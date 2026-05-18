import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../widgets/face_capture_picker.dart';
import '../widgets/lot_batch_picker.dart';
import '../controle/controle_mock_data.dart';
import 'extraction_mock_data.dart';
import 'extraction_widgets.dart';

class ExtractionScanPage extends StatefulWidget {
  const ExtractionScanPage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<ExtractionScanPage> createState() => _ExtractionScanPageState();
}

class _ExtractionScanPageState extends State<ExtractionScanPage> {
  final _locationCtrl = TextEditingController(text: 'Fosse Nord — Zone A');
  String? _selectedBatch;
  bool _faceOk = false;
  String? _faceWorkerName;
  bool _busy = false;
  ExtractionScanResult? _lastResult;

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitStockage() async {
    final batch = _selectedBatch;
    if (batch == null) {
      _snack('Sélectionnez un lot');
      return;
    }
    setState(() {
      _busy = true;
      _lastResult = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final result = ExtractionMockData.simulateExtractionScan(
      batchCode: batch,
      locationName: _locationCtrl.text.trim(),
      faceMatched: _faceOk,
    );
    setState(() {
      _busy = false;
      _lastResult = result;
    });
    if (result.success) {
      _snack('Lot stocké : ${ExtractionMockData.targetStatus}');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final extracted = ExtractionMockData.qrLots
        .where((q) => q.currentStatus == LotStatus.extracted)
        .toList();

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
                    'Visage + QR → ${ExtractionMockData.targetStatus} '
                    '(action ${ExtractionMockData.defaultAction})',
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
                        batchCodes: extracted.map((q) => q.batchCode).toList(),
                        selectedBatch: _selectedBatch,
                        dropdownHint: 'Choisir un lot en EXTRACTED',
                        listEmptyMessage: 'Aucun lot en EXTRACTED.',
                        onBatchChanged: (v) => setState(() => _selectedBatch = v),
                      ),
                      const SizedBox(height: 14),
                      FaceCapturePicker(
                        matched: _faceOk,
                        workerName: _faceWorkerName,
                        knownWorkerNames: ControleMockData.workers
                            .map((w) => w.fullName)
                            .toList(),
                        onCapture: (ok, {workerName}) => setState(() {
                          _faceOk = ok;
                          _faceWorkerName = workerName;
                        }),
                      ),
                      TextField(
                        controller: _locationCtrl,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'POST /traceability/extraction/scan — multipart visage + qr_data + qr_signature',
                style: TextStyle(
                  fontSize: 11,
                  color: context.appOnSurfaceMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Échec — POST /traceability/extraction/scan',
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
                'Succès — lot stocké',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.success),
              ),
              const SizedBox(height: 8),
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
              Text('Action : ${m.action}'),
              Text('Horodatage : ${m.createdAtLabel}'),
            ],
          ),
        ),
      ),
    );
  }
}
