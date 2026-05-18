import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import 'reception_mock_data.dart';
import 'reception_widgets.dart';

/// Lots & traçabilité — mock `GET /traceability/batch/{code}` + QR.
class ReceptionLotsPage extends StatefulWidget {
  const ReceptionLotsPage({super.key});

  @override
  State<ReceptionLotsPage> createState() => _ReceptionLotsPageState();
}

class _ReceptionLotsPageState extends State<ReceptionLotsPage> {
  final _searchCtrl = TextEditingController();
  String? _selectedBatch;
  List<ReceptionLotMovement> _history = [];

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
      _history = ReceptionMockData.historyForBatch(code);
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final qr = _selectedBatch != null
        ? ReceptionMockData.findQrByBatch(_selectedBatch!)
        : null;

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
                    onPressed: _search,
                    child: const Text('Historique'),
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  qr.valid
                                      ? 'POST /qrcodes/verify — valide (mock)'
                                      : 'QR invalide (mock)',
                                ),
                              ),
                            );
                          },
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
                'Essayez : DRC-MINE-8-A3D91C',
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
