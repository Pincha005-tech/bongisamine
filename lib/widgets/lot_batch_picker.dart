import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/qr/batch_code_parser.dart';
import '../coree/theme/app_page_style.dart';
import '../pages/scan/live_qr_scan_screen.dart';

enum LotBatchInputMode { list, scan }

/// Sélection d'un lot : liste déroulante ou scan caméra QR → `batch_code`.
class LotBatchPicker extends StatefulWidget {
  const LotBatchPicker({
    super.key,
    required this.batchCodes,
    required this.selectedBatch,
    required this.onBatchChanged,
    this.onQrPayload,
    this.dropdownHint = 'Choisir un lot',
    this.listEmptyMessage,
    this.sectionTitle = '1. Lot (QR / batch_code)',
  });

  final List<String> batchCodes;
  final String? selectedBatch;
  final ValueChanged<String?> onBatchChanged;
  final ValueChanged<QrScanPayload?>? onQrPayload;
  final String dropdownHint;
  final String? listEmptyMessage;
  final String sectionTitle;

  @override
  State<LotBatchPicker> createState() => _LotBatchPickerState();
}

class _LotBatchPickerState extends State<LotBatchPicker> {
  LotBatchInputMode _mode = LotBatchInputMode.list;
  bool _scanning = false;

  Future<void> _openScanner() async {
    if (_scanning) return;
    setState(() => _scanning = true);
    try {
      final raw = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => const LiveQrScanScreen(
            title: 'Scanner le lot',
            hint: 'Cadrez le QR code du sac minier (batch_code) dans le carré.',
          ),
          fullscreenDialog: true,
        ),
      );
      if (!mounted || raw == null) return;
      final payload = parseQrScanPayload(raw);
      if (payload == null) {
        _snack('QR illisible');
        return;
      }
      final batch = payload.batchCode;
      widget.onBatchChanged(batch);
      widget.onQrPayload?.call(payload);
      if (!widget.batchCodes.contains(batch)) {
        _snack('Lot scanné : $batch (hors liste serveur)');
      } else {
        _snack('Lot scanné : $batch');
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final codes = widget.batchCodes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.sectionTitle,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: context.appOnSurface,
          ),
        ),
        const SizedBox(height: 10),
        SegmentedButton<LotBatchInputMode>(
          segments: const [
            ButtonSegment(
              value: LotBatchInputMode.list,
              label: Text('Liste'),
              icon: Icon(Icons.list_alt_rounded, size: 18),
            ),
            ButtonSegment(
              value: LotBatchInputMode.scan,
              label: Text('Scanner'),
              icon: Icon(Icons.qr_code_scanner_rounded, size: 18),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: 12),
        if (_mode == LotBatchInputMode.list) ...[
          if (widget.selectedBatch != null && widget.selectedBatch!.isNotEmpty)
            _SelectedBatchChip(
              batchCode: widget.selectedBatch!,
              onClear: () {
                widget.onBatchChanged(null);
                widget.onQrPayload?.call(null);
              },
            ),
          if (codes.isNotEmpty) ...[
            if (widget.selectedBatch != null) const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey('dropdown_${codes.join("|")}'),
              isExpanded: true,
              value: widget.selectedBatch != null &&
                      codes.contains(widget.selectedBatch)
                  ? widget.selectedBatch
                  : null,
              decoration: InputDecoration(
                hintText: widget.selectedBatch != null
                    ? 'Changer de lot'
                    : widget.dropdownHint,
              ),
              items: [
                for (final code in codes)
                  DropdownMenuItem(
                    value: code,
                    child: Text(
                      code,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ],
              selectedItemBuilder: (context) => [
                for (final code in codes)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      code,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ],
              onChanged: (v) {
                widget.onBatchChanged(v);
                widget.onQrPayload?.call(null);
              },
            ),
          ] else if (widget.selectedBatch == null)
            Text(
              widget.listEmptyMessage ?? 'Aucun lot disponible pour ce statut.',
              style: TextStyle(fontSize: 13, color: context.appOnSurfaceMuted),
            ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _scanning ? null : _openScanner,
              icon: _scanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.qr_code_scanner_rounded),
              label: Text(_scanning ? 'Ouverture caméra…' : 'Scanner le QR du lot'),
            ),
          ),
          if (widget.selectedBatch != null) ...[
            const SizedBox(height: 10),
            Material(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.selectedBatch!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        widget.onBatchChanged(null);
                        widget.onQrPayload?.call(null);
                      },
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.primary,
                      tooltip: 'Effacer',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Affichage non-éditable du lot (évite EditableText / crash metrics au dispose).
class _SelectedBatchChip extends StatelessWidget {
  const _SelectedBatchChip({
    required this.batchCode,
    required this.onClear,
  });

  final String batchCode;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lot sélectionné',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appOnSurfaceMuted,
                    ),
                  ),
                  Text(
                    batchCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 20),
              color: AppColors.primary,
              tooltip: 'Effacer',
            ),
          ],
        ),
      ),
    );
  }
}
