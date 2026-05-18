import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import 'admin_dashboard_mock_data.dart';

/// Hub sécurité : alertes, fraudes, blockchain, visage (aperçu).
class AdminSecurityHubPage extends StatelessWidget {
  const AdminSecurityHubPage({super.key, required this.onNavigateTab});

  final void Function(int tabIndex) onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, top + 24, 20, 8),
              child: Text(
                'Sécurité',
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
              child: Material(
                color: context.appCardColor,
                elevation: 2,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vue synthèse',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: context.appOnSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AdminDashboardMock.kpis.criticalAlerts} alertes critiques · '
                        '${AdminDashboardMock.kpis.fraudsDetected} fraude(s) · '
                        'Chaîne ${AdminDashboardMock.blockchain.chainValid ? "valide" : "anomalie"}',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: context.appOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: () => onNavigateTab(0),
                            child: const Text('Dashboard'),
                          ),
                          OutlinedButton(
                            onPressed: () => onNavigateTab(2),
                            child: const Text('Scan & visage'),
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
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(
                'Dernières alertes',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: context.appTitleAccent,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: AdminDashboardMock.alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = AdminDashboardMock.alerts[i];
                final c = severityColor(a.severity);
                return Material(
                  color: context.appCardColor,
                  elevation: 1,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: c.withValues(alpha: 0.15),
                      child: Icon(Icons.warning_amber_rounded, color: c, size: 20),
                    ),
                    title: Text(
                      a.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: context.appOnSurface,
                      ),
                    ),
                    subtitle: Text(
                      '${severityLabelFr(a.severity)} · ${a.time}',
                      style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted),
                    ),
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
