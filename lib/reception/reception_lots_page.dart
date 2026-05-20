import 'dart:convert';

import 'package:flutter/material.dart';
import '../coree/api/traceability_api_mapper.dart';
import '../coree/theme/app_page_style.dart';
import '../services/api_service.dart';
import 'reception_models.dart';
import 'reception_widgets.dart';

/// Lots & traçabilité — `GET /traceability/batch/{code}` + QR.
class ReceptionLotsPage extends StatefulWidget {
  const ReceptionLotsPage({super.key});

  @override
  State<ReceptionLotsPage> createState() => _ReceptionLotsPageState();
}

class _ReceptionLotsPageState extends State<ReceptionLotsPage> {
  final _searchCtrl = TextEditingController();
  String? _selectedBatch;
  List<ReceptionLotMovement> _history = [];
  List<ReceptionQrLot> _qrLots = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQrcodes());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQrcodes() async {
    final raw = await ApiService.fetchQrcodes();
    if (!mounted) return;
    setState(() {
      _qrLots = raw.map((q) {
        var batch = q['batch_code'] as String? ?? '';
        if (batch.isEmpty && q['data'] != null) {
          try {
            final parsed = jsonDecode(q['data'] as String);
            if (parsed is Map) batch = parsed['batch_code'] as String? ?? '';
          } catch (_) {}
        }
        return ReceptionQrLot(
          id: q['id'] as int? ?? 0,
          batchCode: batch,
          currentStatus: q['current_status'] as String? ?? MineralLotStatus.inTransport,
          mineralId: q['mineral_id'] as int? ?? 0,
          qrDataPreview: (q['data'] as String?)?.substring(0, 40) ?? batch,
          valid: q['valid'] as bool? ?? true,
        );
      }).toList();
    });
  }

  ReceptionQrLot? _qrForBatch(String batch) {
    for (final q in _qrLots) {
      if (q.batchCode.toUpperCase() == batch.toUpperCase()) return q;
    }
    return null;
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
        _history = rows.map(TraceabilityApiMapper.toReception).toList();
        _searching = false;
      });
    }
    if (_history.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun mouvement pour ce lot')),
      );
    }
  }

  Future<void> _verifyQr(ReceptionQrLot qr) async {
    final full = await ApiService.fetchQrcodes();
    Map<String, dynamic>? match;
    for (final q in full) {
      if (q['id'] == qr.id) {
        match = q;
        break;
      }
    }
    if (match == null || match['data'] == null || match['signature'] == null) {
      _snack('Données QR indisponibles');
      return;
    }
    final result = await ApiService.verifyQr(
      data: match['data'] as String,
      signature: match['signature'] as String,
    );
    if (!mounted) return;
    _snack(
      result != null && (result['valid'] == true || result['success'] == true)
          ? 'POST /qrcodes/verify — valide'
          : 'QR invalide ou signature incorrecte',
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final qr = _selectedBatch != null ? _qrForBatch(_selectedBatch!) : null;

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, top + 20, 20, 12),
              child: Text(
                'Lots & traçabilité',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.appTitleAccent,
                ),
              ),
            ),
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
                        hintText: 'batch_code (ex. DRC-MINE-8-A3D91C)',
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
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          qr.batchCode,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: context.appOnSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ReceptionStatusBadge(
                              qr.currentStatus,
                              status: qr.currentStatus,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'QR #${qr.id} · Minerai #${qr.mineralId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.appOnSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _verifyQr(qr),
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text('Vérifier QR'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_history.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: ReceptionSectionTitle('Mouvements (GET /traceability/batch/…)'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
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
                              ReceptionStatusBadge(m.previousStatus, status: m.previousStatus),
                              const Icon(Icons.arrow_forward_rounded, size: 14),
                              ReceptionStatusBadge(m.newStatus, status: m.newStatus),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.locationName ?? '—',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context.appOnSurface,
                            ),
                          ),
                          Text(
                            '${m.action} · ${m.createdAtLabel}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.appOnSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Text(
                'Saisissez un batch_code connu sur le serveur',
                style: TextStyle(
                  fontSize: 12,
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
}
