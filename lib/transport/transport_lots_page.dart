import 'dart:convert';

import 'package:flutter/material.dart';
import '../coree/api/traceability_api_mapper.dart';
import '../coree/theme/app_page_style.dart';
import '../services/api_service.dart';
import 'transport_models.dart';
import 'transport_widgets.dart';

/// Lots & traçabilité — `GET /traceability/batch/{code}` + QR.
class TransportLotsPage extends StatefulWidget {
  const TransportLotsPage({super.key});

  @override
  State<TransportLotsPage> createState() => _TransportLotsPageState();
}

class _TransportLotsPageState extends State<TransportLotsPage> {
  final _searchCtrl = TextEditingController();
  String? _selectedBatch;
  List<TransportLotMovement> _history = [];
  List<TransportQrLot> _qrLots = [];
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
        return TransportQrLot(
          id: q['id'] as int? ?? 0,
          batchCode: batch,
          currentStatus: q['current_status'] as String? ?? LotStatus.stored,
          mineralId: q['mineral_id'] as int? ?? 0,
          valid: q['valid'] as bool? ?? true,
        );
      }).toList();
    });
  }

  TransportQrLot? _qrForBatch(String batch) {
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
        _history = rows.map(TraceabilityApiMapper.toTransport).toList();
        _searching = false;
      });
    }
    if (_history.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun mouvement pour ce lot')),
      );
    }
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
                        hintText: 'batch_code',
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
                    title: Text(
                      qr.batchCode,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('QR #${qr.id} · Minerai #${qr.mineralId}'),
                    trailing: TransportStatusBadge(qr.currentStatus, status: qr.currentStatus),
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
                              TransportStatusBadge(m.previousStatus, status: m.previousStatus),
                              const Icon(Icons.arrow_forward_rounded, size: 14),
                              TransportStatusBadge(m.newStatus, status: m.newStatus),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Text(
                'Historique via GET /traceability/batch/{code}',
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
