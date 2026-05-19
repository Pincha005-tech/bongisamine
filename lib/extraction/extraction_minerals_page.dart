import 'dart:convert';

import 'package:flutter/material.dart';
import '../coree/api/traceability_api_mapper.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/utils/keyboard_utils.dart';
import '../services/api_service.dart';
import '../widgets/qr_code_image_dialog.dart';
import 'extraction_models.dart';
import 'extraction_widgets.dart';

/// Minerais, génération QR et traçabilité — API uniquement.
class ExtractionMineralsPage extends StatefulWidget {
  const ExtractionMineralsPage({
    super.key,
    this.onNavigateTab,
    this.onOpenScanWithBatch,
  });

  final void Function(int tabIndex)? onNavigateTab;
  final void Function(String batchCode)? onOpenScanWithBatch;

  @override
  State<ExtractionMineralsPage> createState() => _ExtractionMineralsPageState();
}

class _ExtractionMineralsPageState extends State<ExtractionMineralsPage> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String? _selectedBatch;
  List<ExtractionLotMovement> _history = [];
  ExtractionQrGenerateResult? _lastQrResult;
  List<ExtractionMineral> _minerals = [];
  List<ExtractionQrLot> _qrLots = [];
  bool _loading = false;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCatalog());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final rawMinerals = await ApiService.fetchMinerals();
    final rawQrs = await ApiService.fetchQrcodes();
    final qrByMineral = <int, Map<String, dynamic>>{};
    for (final q in rawQrs) {
      final mid = q['mineral_id'] as int?;
      if (mid != null) qrByMineral[mid] = q;
    }
    final minerals = rawMinerals.map((m) {
      final id = m['id'] as int? ?? 0;
      final qr = qrByMineral[id];
      String? batch;
      if (qr != null && qr['batch_code'] != null) {
        batch = qr['batch_code'] as String?;
      } else if (qr?['data'] != null) {
        try {
          final parsed = jsonDecode(qr!['data'] as String);
          if (parsed is Map) batch = parsed['batch_code'] as String?;
        } catch (_) {}
      }
      return ExtractionMineral(
        id: id,
        type: m['type'] as String? ?? '—',
        weight: (m['weight'] as num?)?.toDouble() ?? 0,
        status: ApiService.normalizeMineralStatus(m['status'] as String?),
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
        hasQr: qr != null,
        batchCode: batch,
      );
    }).toList();

    final qrLots = rawQrs.map((q) {
      var batch = q['batch_code'] as String? ?? '';
      if (batch.isEmpty && q['data'] != null) {
        try {
          final parsed = jsonDecode(q['data'] as String);
          if (parsed is Map) batch = parsed['batch_code'] as String? ?? '';
        } catch (_) {}
      }
      return ExtractionQrLot(
        id: q['id'] as int? ?? 0,
        batchCode: batch,
        currentStatus: q['current_status'] as String? ?? LotStatus.extracted,
        mineralId: q['mineral_id'] as int? ?? 0,
        valid: q['valid'] as bool? ?? true,
        originSite: q['origin_site'] as String?,
      );
    }).toList();

    if (mounted) {
      setState(() {
        _minerals = minerals;
        _qrLots = qrLots;
        _loading = false;
      });
    }
  }

  Future<void> _search() async {
    final code = _searchCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() {
      _selectedBatch = code;
      _searching = true;
    });

    final rows = await ApiService.fetchBatchMovements(code);
    if (mounted) {
      setState(() {
        _history = rows.map(TraceabilityApiMapper.toExtraction).toList();
        _searching = false;
      });
    }
    if (_history.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun mouvement pour ce lot')),
      );
    }
  }

  ExtractionQrLot? _qrForBatch(String batch) {
    for (final q in _qrLots) {
      if (q.batchCode.toUpperCase() == batch.toUpperCase()) return q;
    }
    return null;
  }

  Future<void> _showAddMineral() async {
    KeyboardUtils.dismiss();
    final form = await showDialog<_AddMineralFormValues>(
      context: context,
      builder: (ctx) => const _AddMineralDialog(),
    );

    if (form == null || !mounted) return;

    final type = form.type;
    final weight = form.weightKg;

    final created = await ApiService.createMineral(
      type: type,
      weight: weight,
    );
    if (!mounted) return;
    if (created != null) {
      await _loadCatalog();
      _snack('POST /minerals/ — minerai #${created['id']} créé');
    } else {
      _snack('Échec création minerai');
    }
  }

  Future<void> _generateQr(int mineralId) async {
    final qr = await ApiService.generateQrForMineral(mineralId);
    if (!mounted) return;
    if (qr == null) {
      _snack('Échec génération QR');
      return;
    }
    var batch = qr['batch_code'] as String? ?? '';
    if (batch.isEmpty && qr['data'] != null) {
      try {
        final parsed = jsonDecode(qr['data'] as String);
        if (parsed is Map) batch = parsed['batch_code'] as String? ?? '';
      } catch (_) {}
    }
    await _loadCatalog();
    setState(() {
      _lastQrResult = ExtractionQrGenerateResult(
        success: true,
        message: 'POST /qrcodes/mineral/$mineralId — lot $batch',
        qr: ExtractionQrLot(
          id: qr['id'] as int? ?? 0,
          batchCode: batch,
          currentStatus: LotStatus.extracted,
          mineralId: mineralId,
          valid: true,
        ),
      );
    });
    _snack(_lastQrResult!.message);
    final qrId = qr['id'] as int?;
    if (qrId != null && qrId > 0 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showQrCodeImageDialog(
          context,
          qrId: qrId,
          batchCode: batch,
          subtitle: 'Minerai #$mineralId',
        );
      });
    }
  }

  Future<void> _showQrForMineral(ExtractionMineral m) async {
    var qrId = m.qrId;
    if (qrId == null || qrId <= 0) {
      for (final q in _qrLots) {
        if (q.mineralId == m.id) {
          qrId = q.id;
          break;
        }
      }
    }
    if (qrId == null || qrId <= 0) {
      _snack('QR introuvable pour le minerai #${m.id}');
      return;
    }
    await showQrCodeImageDialog(
      context,
      qrId: qrId,
      batchCode: m.batchCode ?? '—',
      subtitle: 'Minerai #${m.id} · ${m.type}',
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final minerals = _minerals;
    final qr = _selectedBatch != null ? _qrForBatch(_selectedBatch!) : null;

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, top + 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Minerais & QR',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.appTitleAccent,
                      ),
                    ),
                  ),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  FilledButton.tonalIcon(
                    onPressed: _showAddMineral,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Minerai'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'API : /minerals/ · /qrcodes/mineral/{id} · /traceability/batch/…',
                style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverList.separated(
              itemCount: minerals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final m = minerals[i];
                return Material(
                  color: context.appCardColor,
                  elevation: 1,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '#${m.id} · ${m.type}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: context.appOnSurface,
                                ),
                              ),
                            ),
                            Text(
                              '${m.weight} kg',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: context.appOnSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Statut : ${m.status}'
                          '${m.batchCode != null ? " · ${m.batchCode}" : ""}',
                          style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (!m.hasQr)
                              FilledButton.tonalIcon(
                                onPressed: () => _generateQr(m.id),
                                icon: const Icon(Icons.qr_code_rounded, size: 18),
                                label: const Text('Générer QR'),
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: () => _showQrForMineral(m),
                                icon: const Icon(Icons.image_outlined, size: 18),
                                label: const Text('Voir QR'),
                              ),
                            const SizedBox(width: 8),
                            if (m.hasQr)
                              TextButton(
                                onPressed: () {
                                  final batch = m.batchCode?.trim();
                                  if (batch != null &&
                                      batch.isNotEmpty &&
                                      widget.onOpenScanWithBatch != null) {
                                    widget.onOpenScanWithBatch!(batch);
                                  } else {
                                    widget.onNavigateTab?.call(1);
                                  }
                                },
                                child: const Text('Scanner'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_lastQrResult?.qr != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Material(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      final q = _lastQrResult!.qr!;
                      if (q.id > 0) {
                        showQrCodeImageDialog(
                          context,
                          qrId: q.id,
                          batchCode: q.batchCode,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.qr_code_2_rounded, color: AppColors.success),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Nouveau lot : ${_lastQrResult!.qr!.batchCode} — toucher pour voir le QR',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: ExtractionSectionTitle('Traçabilité par batch_code'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      decoration: const InputDecoration(
                        hintText: 'DRC-MINE-10-E8A201',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _searching ? null : _search,
                    child: _searching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Historique'),
                  ),
                ],
              ),
            ),
          ),
          if (qr != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Material(
                  color: context.appCardColor,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    title: Text(qr.batchCode, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('QR #${qr.id} · Minerai #${qr.mineralId}'),
                    trailing: ExtractionStatusBadge(qr.currentStatus, status: qr.currentStatus),
                  ),
                ),
              ),
            ),
          if (_history.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              sliver: SliverList.separated(
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final m = _history[i];
                  return Material(
                    color: context.appCardColor,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ExtractionStatusBadge(m.previousStatus, status: m.previousStatus),
                              const Icon(Icons.arrow_forward_rounded, size: 14),
                              ExtractionStatusBadge(m.newStatus, status: m.newStatus),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(m.locationName ?? '—'),
                          Text(
                            '${m.action} · ${m.createdAtLabel}',
                            style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _AddMineralFormValues {
  const _AddMineralFormValues({required this.type, required this.weightKg});

  final String type;
  final double weightKg;
}

class _AddMineralDialog extends StatefulWidget {
  const _AddMineralDialog();

  @override
  State<_AddMineralDialog> createState() => _AddMineralDialogState();
}

class _AddMineralDialogState extends State<_AddMineralDialog> {
  late final TextEditingController _typeCtrl;
  late final TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    _typeCtrl = TextEditingController(text: 'Cobalt');
    _weightCtrl = TextEditingController(text: '500');
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    Navigator.pop(
      context,
      _AddMineralFormValues(
        type: _typeCtrl.text.trim(),
        weightKg: double.tryParse(_weightCtrl.text.replaceAll(',', '.')) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau minerai'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _typeCtrl,
            decoration: const InputDecoration(labelText: 'Type'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _weightCtrl,
            decoration: const InputDecoration(labelText: 'Poids (kg)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
