import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_builder.dart';
import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/api/traceability_api_mapper.dart';
import '../services/api_service.dart';
import 'transport_models.dart';
import 'transport_role.dart';
import 'transport_widgets.dart';

class TransportHomePage extends StatefulWidget {
  const TransportHomePage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<TransportHomePage> createState() => _TransportHomePageState();
}

class _TransportHomePageState extends State<TransportHomePage> {
  int _lotsStored = 0;
  int _loadsToday = 0;
  int _inTransport = 0;
  int _criticalAlerts = 0;
  List<TransportQrLot> _storedLots = [];
  List<TransportLotMovement> _recentLoads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final qrs = await ApiService.fetchQrcodes();
    final alerts = await ApiService.fetchAlerts(limit: 50);
    final history = await ApiService.fetchMineralHistory();
    final today = DateTime.now();

    final stored = <TransportQrLot>[];
    var inTransport = 0;
    for (final q in qrs) {
      final status = (q['current_status'] as String? ?? '').toUpperCase();
      if (status == LotStatus.inTransport) inTransport++;
      if (status != LotStatus.stored) continue;
      var batch = q['batch_code'] as String? ?? '';
      if (batch.isEmpty && q['data'] != null) {
        try {
          final p = jsonDecode(q['data'] as String);
          if (p is Map) batch = p['batch_code'] as String? ?? '';
        } catch (_) {}
      }
      stored.add(
        TransportQrLot(
          id: q['id'] as int? ?? 0,
          batchCode: batch,
          currentStatus: status,
          mineralId: q['mineral_id'] as int? ?? 0,
          valid: q['valid'] as bool? ?? true,
        ),
      );
    }

    var loadsToday = 0;
    final recent = <TransportLotMovement>[];
    for (final h in history) {
      final action = (h['action'] as String? ?? '').toUpperCase();
      if (action.contains('TRANSPORT') || action.contains('CHARGEMENT')) {
        final created = DateTime.tryParse(h['created_at'] as String? ?? '');
        if (created != null &&
            created.year == today.year &&
            created.month == today.month &&
            created.day == today.day) {
          loadsToday++;
        }
        if (recent.length < 5) {
          recent.add(
            TransportLotMovement(
              id: h['id'] as int? ?? 0,
              qrId: h['qr_id'] as int? ?? 0,
              mineralId: h['mineral_id'] as int?,
              workerId: h['worker_id'] as int?,
              previousStatus: h['previous_status'] as String? ?? 'STORED',
              newStatus: h['new_status'] as String? ?? LotStatus.inTransport,
              locationName: h['location_name'] as String?,
              action: h['action'] as String? ?? 'CHARGEMENT',
              createdAtLabel: TraceabilityApiMapper.formatCreatedAt(h['created_at']),
            ),
          );
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _lotsStored = stored.length;
      _storedLots = stored.take(6).toList();
      _inTransport = inTransport;
      _loadsToday = loadsToday;
      _recentLoads = recent;
      _criticalAlerts = alerts
          .where((a) => (a['severity'] as String? ?? '').toLowerCase() == 'critical')
          .length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthBuilder(
      builder: (context, auth) {
        final top = MediaQuery.paddingOf(context).top;
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
                          'Bonjour, ${auth.name}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.appTitleAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chargement & transport — Bongisa Mine RDC',
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
                              transportRoleBadge(auth.user?.role ?? kRoleSupervisorTransport),
                            ),
                            _chip(
                              Icons.swap_horiz_rounded,
                              TransportWorkflow.transitionLabel,
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
                            child: TransportKpiTile(
                              label: 'Lots STORED',
                              value: '$_lotsStored',
                              icon: Icons.inventory_2_outlined,
                              accent: const Color(0xFF8B5CF6),
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: TransportKpiTile(
                              label: 'Chargements (jour)',
                              value: '$_loadsToday',
                              icon: Icons.local_shipping_outlined,
                              accent: AppColors.success,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: TransportKpiTile(
                              label: 'En transport',
                              value: '$_inTransport',
                              icon: Icons.route_outlined,
                              accent: const Color(0xFFF59E0B),
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: TransportKpiTile(
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
              const SliverToBoxAdapter(
                child: TransportSectionTitle('Lots à charger (STORED)'),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _storedLots.isEmpty
                    ? SliverToBoxAdapter(
                        child: Text(
                          'Aucun lot en STORED',
                          style: TextStyle(color: context.appOnSurfaceMuted),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: _storedLots.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final lot = _storedLots[i];
                          return Material(
                            color: context.appCardColor,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              onTap: () => widget.onNavigateTab?.call(1),
                              title: Text(
                                lot.batchCode,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text('Minerai #${lot.mineralId}'),
                              trailing: TransportStatusBadge(
                                lot.currentStatus,
                                status: lot.currentStatus,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SliverToBoxAdapter(
                child: TransportSectionTitle('Chargements récents'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                sliver: _recentLoads.isEmpty
                    ? SliverToBoxAdapter(
                        child: Text(
                          'Aucun chargement récent',
                          style: TextStyle(color: context.appOnSurfaceMuted),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: _recentLoads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final m = _recentLoads[i];
                          return Material(
                            color: context.appCardColor,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              title: Text(
                                '${m.previousStatus} → ${m.newStatus}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text('${m.action} · ${m.locationName ?? "—"}'),
                              trailing: Text(
                                m.createdAtLabel.split(' ').last,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.appOnSurfaceMuted,
                                ),
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
