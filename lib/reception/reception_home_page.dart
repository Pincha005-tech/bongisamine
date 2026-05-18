import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import 'reception_mock_data.dart';
import 'reception_role.dart';
import 'reception_widgets.dart';

/// Accueil superviseur réception — mock aligné dashboard + file IN_TRANSPORT.
class ReceptionHomePage extends StatelessWidget {
  const ReceptionHomePage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final auth = context.watch<AuthController>();
    final stats = ReceptionMockData.homeStats;
    final inTransport = ReceptionMockData.qrLots
        .where((q) => q.currentStatus == MineralLotStatus.inTransport)
        .toList();

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 600));
        },
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
                              ReceptionMockData.transitionReception,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                            label: 'En transport',
                            value: '${stats.lotsInTransport}',
                            icon: Icons.local_shipping_outlined,
                            accent: AppColors.warning,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: ReceptionKpiTile(
                            label: 'Réceptions (jour)',
                            value: '${stats.receptionsToday}',
                            icon: Icons.check_circle_outline,
                            accent: AppColors.success,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: ReceptionKpiTile(
                            label: 'Alertes critiques',
                            value: '${stats.criticalAlerts}',
                            icon: Icons.warning_amber_rounded,
                            accent: AppColors.error,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: ReceptionKpiTile(
                            label: 'QR invalides',
                            value: '${stats.invalidQrToday}',
                            icon: Icons.qr_code_2_rounded,
                            accent: AppColors.skyBlue,
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => onNavigateTab?.call(1),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, color: AppColors.cream),
                          SizedBox(width: 10),
                          Text(
                            'Scanner une arrivée',
                            style: TextStyle(
                              color: AppColors.cream,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
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
              child: ReceptionSectionTitle('Lots en attente (IN_TRANSPORT)'),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: inTransport.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final lot = inTransport[i];
                  return Material(
                    color: context.appCardColor,
                    elevation: 1,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      onTap: () => onNavigateTab?.call(2),
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.cream,
                        child: Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                      ),
                      title: Text(
                        lot.batchCode,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('Minerai #${lot.mineralId} · QR #${lot.id}'),
                      trailing: const ReceptionStatusBadge(
                        MineralLotStatus.inTransport,
                        status: MineralLotStatus.inTransport,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: ReceptionSectionTitle('Dernières réceptions'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              sliver: SliverList.separated(
                itemCount: ReceptionMockData.recentReceptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final m = ReceptionMockData.recentReceptions[i];
                  return Material(
                    color: context.appCardColor,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.login_rounded, color: AppColors.success),
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
        ),
      ),
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
