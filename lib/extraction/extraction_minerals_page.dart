import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import 'extraction_mock_data.dart';
import 'extraction_widgets.dart';

/// Minerais, génération QR et traçabilité — mocks API extraction.
class ExtractionMineralsPage extends StatefulWidget {
  const ExtractionMineralsPage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<ExtractionMineralsPage> createState() => _ExtractionMineralsPageState();
}

class _ExtractionMineralsPageState extends State<ExtractionMineralsPage> {
  final _searchCtrl = TextEditingController();
  String? _selectedBatch;
  List<ExtractionLotMovement> _history = [];
  ExtractionQrGenerateResult? _lastQrResult;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final code = _searchCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() {
      _selectedBatch = code;
      _history = ExtractionMockData.historyForBatch(code);
    });
  }

  Future<void> _showAddMineral() async {
    final typeCtrl = TextEditingController(text: 'Cobalt');
    final weightCtrl = TextEditingController(text: '500');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau minerai'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeCtrl,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: weightCtrl,
              decoration: const InputDecoration(labelText: 'Poids (kg)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Créer')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final weight = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0;
    ExtractionMockData.simulateCreateMineral(
      type: typeCtrl.text.trim(),
      weight: weight,
    );
    typeCtrl.dispose();
    weightCtrl.dispose();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('POST /minerals/ — minerai créé (mock)')),
    );
  }

  void _generateQr(int mineralId) {
    final result = ExtractionMockData.simulateGenerateQr(mineralId);
    setState(() => _lastQrResult = result);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final minerals = ExtractionMockData.minerals;
    final qr = _selectedBatch != null
        ? ExtractionMockData.findQrByBatch(_selectedBatch!)
        : null;

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
                'POST /minerals/ · POST /qrcodes/mineral/{id} · GET /traceability/batch/…',
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
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'GET /qrcodes/{id}/image — ${m.batchCode} (mock)',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.image_outlined, size: 18),
                                label: const Text('Voir QR'),
                              ),
                            const SizedBox(width: 8),
                            if (m.hasQr)
                              TextButton(
                                onPressed: () => widget.onNavigateTab?.call(1),
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
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Nouveau lot : ${_lastQrResult!.qr!.batchCode}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
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
                      decoration: const InputDecoration(
                        hintText: 'DRC-MINE-10-E8A201',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _search, child: const Text('Historique')),
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
