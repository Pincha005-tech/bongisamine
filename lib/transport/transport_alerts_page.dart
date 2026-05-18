import 'package:flutter/material.dart';

import '../coree/theme/app_page_style.dart';
import 'transport_mock_data.dart';

/// Alertes transport — mock aligné modèle Alert backend.
class TransportAlertsPage extends StatelessWidget {
  const TransportAlertsPage({super.key});

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
              padding: EdgeInsets.fromLTRB(20, top + 20, 20, 8),
              child: Text(
                'Alertes & sécurité',
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
              child: Text(
                'Transitions invalides, QR, visage, GPS — données mock.',
                style: TextStyle(
                  fontSize: 13,
                  color: context.appOnSurfaceMuted,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            sliver: SliverList.separated(
              itemCount: TransportMockData.alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = TransportMockData.alerts[i];
                final c = transportSeverityColor(a.severity);
                return Material(
                  color: context.appCardColor,
                  elevation: 1,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: c.withValues(alpha: 0.15),
                      child: Icon(Icons.shield_outlined, color: c, size: 20),
                    ),
                    title: Text(
                      a.message,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: context.appOnSurface,
                      ),
                    ),
                    subtitle: Text(
                      '${a.type} · ${transportSeverityLabel(a.severity)} · ${a.time}'
                      '${a.source != null ? "\n${a.source}" : ""}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appOnSurfaceMuted,
                      ),
                    ),
                    isThreeLine: a.source != null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
