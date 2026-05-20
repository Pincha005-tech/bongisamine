import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_builder.dart';
import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/api/traceability_api_mapper.dart';
import '../services/api_service.dart';
import 'extraction_models.dart';
import 'extraction_role.dart';
import 'extraction_widgets.dart';

class ExtractionHomePage extends StatefulWidget {
  const ExtractionHomePage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<ExtractionHomePage> createState() => _ExtractionHomePageState();
}

class _ExtractionHomePageState extends State<ExtractionHomePage> {
  int _lotsExtracted = 0;
  int _stockagesToday = 0;
  int _mineralsWithoutQr = 0;
  int _criticalAlerts = 0;
  List<ExtractionQrLot> _extractedLots = [];
  List<ExtractionLotMovement> _recentStockages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final qrs = await ApiService.fetchQrcodes();
    final minerals = await ApiService.fetchMinerals();
    final alerts = await ApiService.fetchAlerts(limit: 50);
    final history = await ApiService.fetchMineralHistory();

    final qrMineralIds = qrs.map((q) => q['mineral_id'] as int?).whereType<int>().toSet();
    final today = DateTime.now();
    var stockagesToday = 0;
    final recentMoves = <ExtractionLotMovement>[];

    for (final h in history) {
      final action = (h['action'] as String? ?? '').toUpperCase();
      if (action.contains('STOCKAGE') || action.contains('STORED')) {
        final created = DateTime.tryParse(h['created_at'] as String? ?? '');
        if (created != null &&
            created.year == today.year &&
            created.month == today.month &&
            created.day == today.day) {
          stockagesToday++;
        }
        if (recentMoves.length < 5) {
          recentMoves.add(
            ExtractionLotMovement(
              id: h['id'] as int? ?? 0,
              qrId: h['qr_id'] as int? ?? 0,
              mineralId: h['mineral_id'] as int?,
              workerId: h['worker_id'] as int?,
              previousStatus: h['previous_status'] as String? ?? '—',
              newStatus: h['new_status'] as String? ?? 'STORED',
              locationName: h['location_name'] as String?,
              action: h['action'] as String? ?? 'STOCKAGE',
              createdAtLabel: TraceabilityApiMapper.formatCreatedAt(h['created_at']),
            ),
          );
        }
      }
    }

    final extracted = <ExtractionQrLot>[];
    for (final q in qrs) {
      final status = (q['current_status'] as String? ?? '').toUpperCase();
      if (status != LotStatus.extracted) continue;
      var batch = q['batch_code'] as String? ?? '';
      if (batch.isEmpty && q['data'] != null) {
        try {
          final p = jsonDecode(q['data'] as String);
          if (p is Map) batch = p['batch_code'] as String? ?? '';
        } catch (_) {}
      }
      extracted.add(
        ExtractionQrLot(
          id: q['id'] as int? ?? 0,
          batchCode: batch,
          currentStatus: status,
          mineralId: q['mineral_id'] as int? ?? 0,
          valid: q['valid'] as bool? ?? true,
          originSite: q['origin_site'] as String?,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _lotsExtracted = extracted.length;
      _extractedLots = extracted.take(6).toList();
      _stockagesToday = stockagesToday;
      _mineralsWithoutQr =
          minerals.where((m) => !qrMineralIds.contains(m['id'] as int?)).length;
      _criticalAlerts = alerts
          .where((a) => (a['severity'] as String? ?? '').toLowerCase() == 'critical')
          .length;
      _recentStockages = recentMoves;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthBuilder(
      builder: (context, auth) {
        final top = MediaQuery.paddingOf(context).top;
        final userName = auth.name;
        final userRole = auth.user?.role ?? kRoleSupervisorExtraction;

        return DecoratedBox(
      decoration: context.appPageDecoration,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: top + 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Material(
                  color: context.appCardColor,
                  elevation: 3,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, $userName',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.appTitleAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Extraction & stockage — Bongisa Mine RDC',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.appOnSurfaceMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip(
                              Icons.badge_outlined,
                              extractionRoleBadge(userRole),
                            ),
                            _chip(
                              Icons.swap_horiz_rounded,
                              ExtractionWorkflow.transitionLabel,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final w = (c.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: w,
                            child: ExtractionKpiTile(
                              label: 'Lots EXTRACTED',
                              value: '$_lotsExtracted',
                              icon: Icons.construction_outlined,
                              accent: const Color(0xFF3B82F6),
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: ExtractionKpiTile(
                              label: 'Stockages (jour)',
                              value: '$_stockagesToday',
                              icon: Icons.warehouse_outlined,
                              accent: AppColors.success,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: ExtractionKpiTile(
                              label: 'Sans QR',
                              value: '$_mineralsWithoutQr',
                              icon: Icons.qr_code_2_outlined,
                              accent: AppColors.warning,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: ExtractionKpiTile(
                              label: 'Alertes critiques',
                              value: '$_criticalAlerts',
                              icon: Icons.warning_amber_rounded,
                              accent: AppColors.error,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => widget.onNavigateTab?.call(1),
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code_scanner_rounded, color: AppColors.cream),
                                  SizedBox(width: 8),
                                  Text(
                                    'Stockage scan',
                                    style: TextStyle(
                                      color: AppColors.cream,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onNavigateTab?.call(2),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Minerais & QR'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: ExtractionSectionTitle('Lots à stocker (EXTRACTED)'),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _extractedLots.isEmpty
                    ? SliverToBoxAdapter(
                        child: Text(
                          'Aucun lot en EXTRACTED',
                          style: TextStyle(color: context.appOnSurfaceMuted),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: _extractedLots.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final lot = _extractedLots[i];
                          return Material(
                            color: context.appCardColor,
                            elevation: 1,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              onTap: () => widget.onNavigateTab?.call(1),
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.cream,
                                child: Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                              ),
                              title: Text(
                                lot.batchCode,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(
                                'Minerai #${lot.mineralId}'
                                '${lot.originSite != null ? " · ${lot.originSite}" : ""}',
                              ),
                              trailing: const ExtractionStatusBadge(
                                LotStatus.extracted,
                                status: LotStatus.extracted,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SliverToBoxAdapter(
                child: ExtractionSectionTitle('Derniers stockages'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                sliver: _recentStockages.isEmpty
                    ? SliverToBoxAdapter(
                        child: Text(
                          'Aucun stockage récent',
                          style: TextStyle(color: context.appOnSurfaceMuted),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: _recentStockages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final m = _recentStockages[i];
                          return Material(
                            color: context.appCardColor,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.warehouse_outlined, color: Color(0xFF8B5CF6)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lot #${m.mineralId} · ${m.action}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: context.appOnSurface,
                                          ),
                                        ),
                                        Text(
                                          '${m.previousStatus} → ${m.newStatus}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.appOnSurfaceMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    m.createdAtLabel.split(' ').last,
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
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
