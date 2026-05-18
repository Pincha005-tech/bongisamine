import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import 'extraction_mock_data.dart';
import 'extraction_role.dart';
import 'extraction_widgets.dart';

class ExtractionHomePage extends StatelessWidget {
  const ExtractionHomePage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final auth = context.watch<AuthController>();
    final stats = ExtractionMockData.homeStats;
    final extracted = ExtractionMockData.qrLots
        .where((q) => q.currentStatus == LotStatus.extracted)
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
                              extractionRoleBadge(auth.user?.role ?? kRoleSupervisorExtraction),
                            ),
                            _chip(
                              Icons.swap_horiz_rounded,
                              ExtractionMockData.transitionExtraction,
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
                          child: ExtractionKpiTile(
                            label: 'Lots EXTRACTED',
                            value: '${stats.lotsExtracted}',
                            icon: Icons.construction_outlined,
                            accent: const Color(0xFF3B82F6),
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: ExtractionKpiTile(
                            label: 'Stockages (jour)',
                            value: '${stats.stockagesToday}',
                            icon: Icons.warehouse_outlined,
                            accent: AppColors.success,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: ExtractionKpiTile(
                            label: 'Sans QR',
                            value: '${stats.mineralsWithoutQr}',
                            icon: Icons.qr_code_2_outlined,
                            accent: AppColors.warning,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: ExtractionKpiTile(
                            label: 'Alertes critiques',
                            value: '${stats.criticalAlerts}',
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
                          onTap: () => onNavigateTab?.call(1),
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
                        onPressed: () => onNavigateTab?.call(2),
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
              sliver: SliverList.separated(
                itemCount: extracted.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final lot = extracted[i];
                  return Material(
                    color: context.appCardColor,
                    elevation: 1,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      onTap: () => onNavigateTab?.call(1),
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
              sliver: SliverList.separated(
                itemCount: ExtractionMockData.recentStockages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final m = ExtractionMockData.recentStockages[i];
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
