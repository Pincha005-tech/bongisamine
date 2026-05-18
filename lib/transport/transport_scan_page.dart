import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../widgets/face_capture_picker.dart';
import '../widgets/lot_batch_picker.dart';
import '../controle/controle_mock_data.dart';
import 'transport_mock_data.dart';
import 'transport_widgets.dart';

/// Scan transport — mock `POST /traceability/transport/scan` + lecture sécurisée.
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
  bool _faceOk = false;
  String? _faceWorkerName;
  bool _busy = false;
  TransportScanResult? _lastResult;
  TransportSecureReadResult? _secureReadResult;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _runSecureRead() async {
    final batch = _selectedBatch;
    if (batch == null) {
      _snack('Sélectionnez un lot (batch_code)');
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _secureReadResult = TransportMockData.simulateSecureRead(
        batchCode: batch,
        faceMatched: _faceOk,
      );
    });
  }

  Future<void> _submitTransport() async {
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
    final result = TransportMockData.simulateTransportScan(
      batchCode: batch,
      locationName: _locationCtrl.text.trim(),
      faceMatched: _faceOk,
    );
    setState(() {
      _busy = false;
      _lastResult = result;
    });
    if (result.success) {
      _snack('Lot chargé : ${TransportMockData.targetStatus}');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final stored = TransportMockData.qrLots
        .where((q) => q.currentStatus == LotStatus.stored)
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
                    'Scan transport',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: context.appTitleAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Visage + QR → ${TransportMockData.targetStatus} '
                    '(action ${TransportMockData.defaultAction})',
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
                        batchCodes: stored.map((q) => q.batchCode).toList(),
                        selectedBatch: _selectedBatch,
                        dropdownHint: 'Choisir un lot en STORED',
                        listEmptyMessage: 'Aucun lot en STORED.',
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
    final ok = r.success;
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
                  color: ok ? AppColors.success : AppColors.error,
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
