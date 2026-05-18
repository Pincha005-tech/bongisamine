import 'package:flutter/material.dart';

import '../coree/theme/app_page_style.dart';
import 'extraction_mock_data.dart';

class ExtractionAlertsPage extends StatelessWidget {
  const ExtractionAlertsPage({super.key});

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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            sliver: SliverList.separated(
              itemCount: ExtractionMockData.alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = ExtractionMockData.alerts[i];
                final c = extractionSeverityColor(a.severity);
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
                      '${a.type} · ${extractionSeverityLabel(a.severity)} · ${a.time}',
                      style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted),
                    ),
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
