import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_builder.dart';
import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/api/traceability_api_mapper.dart';
import '../services/api_service.dart';
import 'reception_models.dart';
import 'reception_role.dart';
import 'reception_widgets.dart';

class ReceptionHomePage extends StatefulWidget {
  const ReceptionHomePage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<ReceptionHomePage> createState() => _ReceptionHomePageState();
}

class _ReceptionHomePageState extends State<ReceptionHomePage> {
  int _inTransportCount = 0;
  int _receptionsToday = 0;
  int _fraudAlerts = 0;
  int _criticalAlerts = 0;
  List<ReceptionQrLot> _inTransportLots = [];
  List<ReceptionLotMovement> _recentReceptions = [];
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

    final inTransport = <ReceptionQrLot>[];
    for (final q in qrs) {
      final status = (q['current_status'] as String? ?? '').toUpperCase();
      if (status != LotStatus.inTransport) continue;
      var batch = q['batch_code'] as String? ?? '';
      if (batch.isEmpty && q['data'] != null) {
        try {
          final p = jsonDecode(q['data'] as String);
          if (p is Map) batch = p['batch_code'] as String? ?? '';
        } catch (_) {}
      }
      inTransport.add(
        ReceptionQrLot(
          id: q['id'] as int? ?? 0,
          batchCode: batch,
          currentStatus: status,
          mineralId: q['mineral_id'] as int? ?? 0,
          qrDataPreview: (q['data'] as String?)?.substring(0, 40) ?? batch,
          valid: q['valid'] as bool? ?? true,
        ),
      );
    }

    var receptionsToday = 0;
    final recent = <ReceptionLotMovement>[];
    for (final h in history) {
      final action = (h['action'] as String? ?? '').toUpperCase();
      if (action.contains('RECEPTION') || action.contains('DEPOT')) {
        final created = DateTime.tryParse(h['created_at'] as String? ?? '');
        if (created != null &&
            created.year == today.year &&
            created.month == today.month &&
            created.day == today.day) {
          receptionsToday++;
        }
        if (recent.length < 5) {
          recent.add(
            ReceptionLotMovement(
              id: h['id'] as int? ?? 0,
              qrId: h['qr_id'] as int? ?? 0,
              mineralId: h['mineral_id'] as int?,
              workerId: h['worker_id'] as int?,
              previousStatus: h['previous_status'] as String? ?? LotStatus.inTransport,
              newStatus: h['new_status'] as String? ?? LotStatus.depotReceived,
              locationName: h['location_name'] as String?,
              action: h['action'] as String? ?? 'RECEPTION',
              createdAtLabel: TraceabilityApiMapper.formatCreatedAt(h['created_at']),
            ),
          );
        }
      }
    }

    final fraudAlerts = alerts
        .where((a) {
          final t = (a['type'] as String? ?? '').toUpperCase();
          return t.contains('FRAUD') || t.contains('FACE');
        })
        .length;

    if (!mounted) return;
    setState(() {
      _inTransportCount = inTransport.length;
      _inTransportLots = inTransport.take(6).toList();
      _receptionsToday = receptionsToday;
      _recentReceptions = recent;
      _fraudAlerts = fraudAlerts;
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
                          'Réception dépôt — Bongisa Mine RDC',
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
                              receptionRoleBadge(auth.user?.role ?? kRoleSupervisorReception),
                            ),
                            _chip(
                              Icons.swap_horiz_rounded,
                              ReceptionWorkflow.transitionLabel,
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
                            child: ReceptionKpiTile(
                              label: 'En IN_TRANSPORT',
                              value: '$_inTransportCount',
                              icon: Icons.local_shipping_outlined,
                              accent: const Color(0xFFF59E0B),
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: ReceptionKpiTile(
                              label: 'Réceptions (jour)',
                              value: '$_receptionsToday',
                              icon: Icons.inventory_outlined,
                              accent: AppColors.success,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: ReceptionKpiTile(
                              label: 'Alertes fraude',
                              value: '$_fraudAlerts',
                              icon: Icons.shield_outlined,
                              accent: AppColors.warning,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: ReceptionKpiTile(
                              label: 'Critiques',
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
                child: ReceptionSectionTitle('File IN_TRANSPORT'),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _inTransportLots.isEmpty
                    ? SliverToBoxAdapter(
                        child: Text(
                          'Aucun lot en transport',
                          style: TextStyle(color: context.appOnSurfaceMuted),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: _inTransportLots.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final lot = _inTransportLots[i];
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
                              trailing: ReceptionStatusBadge(
                                lot.currentStatus,
                                status: lot.currentStatus,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SliverToBoxAdapter(
                child: ReceptionSectionTitle('Réceptions récentes'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                sliver: _recentReceptions.isEmpty
                    ? SliverToBoxAdapter(
                        child: Text(
                          'Aucune réception récente',
                          style: TextStyle(color: context.appOnSurfaceMuted),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: _recentReceptions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final m = _recentReceptions[i];
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
