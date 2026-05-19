import 'package:flutter/material.dart';

import '../coree/theme/app_page_style.dart';
import '../coree/traceability/status_style.dart';
import '../services/api_service.dart';

class ExtractionAlertsPage extends StatefulWidget {
  const ExtractionAlertsPage({super.key});

  @override
  State<ExtractionAlertsPage> createState() => _ExtractionAlertsPageState();
}

class _ExtractionAlertsPageState extends State<ExtractionAlertsPage> {
  List<Map<String, dynamic>> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final rows = await ApiService.fetchAlerts(limit: 30);
    if (!mounted) return;
    setState(() {
      _alerts = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_alerts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Aucune alerte',
                    style: TextStyle(color: context.appOnSurfaceMuted),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                sliver: SliverList.separated(
                  itemCount: _alerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final a = _alerts[i];
                    final severity = (a['severity'] as String? ?? 'low').toLowerCase();
                    final c = alertSeverityColor(severity);
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
                          a['message'] as String? ?? 'Alerte',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: context.appOnSurface,
                          ),
                        ),
                        subtitle: Text(
                          '${a['type'] ?? "—"} · ${alertSeverityLabel(severity)} · '
                          '${ApiService.formatDateTime(a['created_at'] as String?)}',
                          style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted),
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
}
