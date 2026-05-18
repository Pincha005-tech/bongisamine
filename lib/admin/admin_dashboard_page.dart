import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import 'admin_dashboard_mock_data.dart';
import 'admin_role_display.dart';

/// Centre de contrôle général — rôle administrateur (données mock).
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _busy = false;

  Future<void> _refresh() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _busy = false);
  }

  void _go(int tab) => widget.onNavigateTab?.call(tab);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final auth = context.watch<AuthController>();
    final name = auth.name;
    final role = adminRoleBadge(auth.user?.role ?? 'admin');
    final today = formatFrenchFullDate(DateTime.now());
    final card = context.appCardColor;
    final onSurface = context.appOnSurface;
    final muted = context.appOnSurfaceMuted;

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: top + 12)),
            SliverToBoxAdapter(
              child: _AdminHeader(
                greetingName: name,
                roleBadge: role,
                todayLabel: today,
                system: AdminDashboardMock.system,
              ),
            ),
            if (_busy)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primary,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _KpiGrid(kpis: AdminDashboardMock.kpis),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionTitle('Actions rapides'),
            ),
            SliverToBoxAdapter(
              child: _QuickActions(
                onAddWorker: () => _snack(context, 'Ajouter worker — bientôt'),
                onAddMineral: () => _snack(context, 'Ajouter minerai — bientôt'),
                onGenerateQr: () => _snack(context, 'Générer QR — bientôt'),
                onScanQr: () => _go(2),
                onHistory: () => _snack(context, 'Historique — bientôt'),
                onAlerts: () => _go(4),
                onBlockchain: () => _snack(context, 'Explorateur blockchain — bientôt'),
                onDailyReport: () => _snack(context, 'Rapport journalier complet — bientôt'),
              ),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle('Production minière'),
            ),
            SliverToBoxAdapter(
              child: _ProductionSection(cardColor: card, onSurface: onSurface, muted: muted),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle('Traçabilité — derniers mouvements'),
            ),
            SliverToBoxAdapter(
              child: _TraceabilityList(cardColor: card, onSurface: onSurface, muted: muted),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle('Sécurité — alertes & fraudes'),
            ),
            SliverToBoxAdapter(
              child: _SecuritySection(cardColor: card, onSurface: onSurface, muted: muted),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle('Présence'),
            ),
            SliverToBoxAdapter(
              child: _PresenceSection(cardColor: card, onSurface: onSurface, muted: muted),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle('Blockchain'),
            ),
            SliverToBoxAdapter(
              child: _BlockchainCard(cardColor: card, onSurface: onSurface, muted: muted),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle('QR codes'),
            ),
            SliverToBoxAdapter(
              child: _QrSection(
                cardColor: card,
                onSurface: onSurface,
                muted: muted,
                onGenerate: () => _snack(context, 'Générer QR'),
                onScan: () => _go(2),
                onVerify: () => _snack(context, 'Vérifier QR'),
              ),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle('IoT & conteneurs'),
            ),
            SliverToBoxAdapter(
              child: _IotSection(cardColor: card, onSurface: onSurface, muted: muted),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle('Rapport journalier'),
            ),
            SliverToBoxAdapter(
              child: _DailyReportCard(
                cardColor: card,
                onSurface: onSurface,
                muted: muted,
                onFullReport: () => _snack(context, 'Rapport complet'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({
    required this.greetingName,
    required this.roleBadge,
    required this.todayLabel,
    required this.system,
  });

  final String greetingName;
  final String roleBadge;
  final String todayLabel;
  final AdminSystemStatus system;

  @override
  Widget build(BuildContext context) {
    final card = context.appCardColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Material(
        color: card,
        elevation: 4,
        shadowColor: AppColors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, $greetingName',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.appTitleAccent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Centre de contrôle minier — Bongisa Mine RDC',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.appOnSurfaceMuted,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeaderChip(icon: Icons.badge_outlined, label: roleBadge),
                  _HeaderChip(icon: Icons.calendar_today_outlined, label: 'Aujourd’hui : $todayLabel'),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Text(
                'Statut du système',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.appOnSurfaceMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(
                    ok: system.online,
                    label: system.online ? 'En ligne' : 'Hors ligne',
                  ),
                  _StatusPill(
                    ok: system.synced,
                    label: system.synced ? 'Synchronisé' : 'Sync en attente',
                  ),
                  _StatusPill(
                    ok: system.backendConnected,
                    label: system.backendConnected
                        ? 'Backend connecté'
                        : 'Mode démo (sans API)',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
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
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.ok, required this.label});

  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.info_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: context.appTitleAccent,
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.kpis});

  final AdminKpis kpis;

  @override
  Widget build(BuildContext context) {
    final items = <({String title, String value, IconData icon, Color color})>[
      (
        title: 'Présents',
        value: '${kpis.workersPresent}',
        icon: Icons.groups_rounded,
        color: AppColors.success,
      ),
      (
        title: 'Lots actifs',
        value: '${kpis.activeLots}',
        icon: Icons.inventory_2_outlined,
        color: AppColors.skyBlue,
      ),
      (
        title: 'En transport',
        value: '${kpis.lotsInTransport}',
        icon: Icons.local_shipping_outlined,
        color: AppColors.warning,
      ),
      (
        title: 'Alertes critiques',
        value: '${kpis.criticalAlerts}',
        icon: Icons.warning_amber_rounded,
        color: AppColors.error,
      ),
      (
        title: 'Fraudes',
        value: '${kpis.fraudsDetected}',
        icon: Icons.gpp_maybe_outlined,
        color: AppColors.error,
      ),
      (
        title: 'QR actifs',
        value: '${kpis.activeQrCodes}',
        icon: Icons.qr_code_2_rounded,
        color: AppColors.skyBlue,
      ),
      (
        title: 'Transactions (jour)',
        value: '${kpis.transactionsToday}',
        icon: Icons.swap_horiz_rounded,
        color: AppColors.success,
      ),
      (
        title: 'Blockchain',
        value: kpis.blockchainValid ? 'Valide' : 'Anomalie',
        icon: Icons.link_rounded,
        color: const Color(0xFFB8860B),
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final gap = 10.0;
        final w = (c.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final it in items)
              SizedBox(
                width: w,
                child: _KpiTile(
                  title: it.title,
                  value: it.value,
                  icon: it.icon,
                  accent: it.color,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appCardColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: context.appOnSurface,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.appOnSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onAddWorker,
    required this.onAddMineral,
    required this.onGenerateQr,
    required this.onScanQr,
    required this.onHistory,
    required this.onAlerts,
    required this.onBlockchain,
    required this.onDailyReport,
  });

  final VoidCallback onAddWorker;
  final VoidCallback onAddMineral;
  final VoidCallback onGenerateQr;
  final VoidCallback onScanQr;
  final VoidCallback onHistory;
  final VoidCallback onAlerts;
  final VoidCallback onBlockchain;
  final VoidCallback onDailyReport;

  @override
  Widget build(BuildContext context) {
    final actions = <({String label, IconData icon, VoidCallback onTap})>[
      (label: 'Ajouter worker', icon: Icons.person_add_alt_1_outlined, onTap: onAddWorker),
      (label: 'Ajouter minerai', icon: Icons.landscape_outlined, onTap: onAddMineral),
      (label: 'Générer QR', icon: Icons.qr_code_scanner_rounded, onTap: onGenerateQr),
      (label: 'Scanner QR', icon: Icons.document_scanner_outlined, onTap: onScanQr),
      (label: 'Historique', icon: Icons.history_rounded, onTap: onHistory),
      (label: 'Alertes', icon: Icons.notifications_active_outlined, onTap: onAlerts),
      (label: 'Blockchain', icon: Icons.account_tree_outlined, onTap: onBlockchain),
      (label: 'Rapport du jour', icon: Icons.summarize_outlined, onTap: onDailyReport),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: context.appCardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in actions)
                ActionChip(
                  avatar: Icon(a.icon, size: 18, color: AppColors.primary),
                  label: Text(a.label),
                  onPressed: a.onTap,
                  side: const BorderSide(color: AppColors.grayLight),
                  backgroundColor: AppColors.cream.withValues(alpha: 0.35),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductionSection extends StatelessWidget {
  const _ProductionSection({
    required this.cardColor,
    required this.onSurface,
    required this.muted,
  });

  final Color cardColor;
  final Color onSurface;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final data = AdminDashboardMock.lotByStatus;
    final maxC = data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AdminDashboardMock.totalMineralsTracked} lots suivis · '
                '${AdminDashboardMock.totalWeightExtractedT.toString().replaceAll('.', ',')} t extraites',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted),
              ),
              const SizedBox(height: 6),
              Text(
                '${AdminDashboardMock.blockedOrSuspiciousLots} bloqués / suspects · '
                '${AdminDashboardMock.exportedLots} exportés',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: muted),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    maxY: maxC * 1.2,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.grayLight.withValues(alpha: 0.8),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(
                            v.toInt().toString(),
                            style: TextStyle(fontSize: 9, color: muted, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= data.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                data[i].code.replaceAll('_', '\n'),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 7, color: muted, fontWeight: FontWeight.w600, height: 1.1),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < data.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: data[i].count.toDouble(),
                              width: 14,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              color: data[i].color,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in data)
                    _LegendDot(color: s.color, label: s.code),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: context.appOnSurfaceMuted),
        ),
      ],
    );
  }
}

class _TraceabilityList extends StatelessWidget {
  const _TraceabilityList({
    required this.cardColor,
    required this.onSurface,
    required this.muted,
  });

  final Color cardColor;
  final Color onSurface;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Column(
          children: [
            for (var i = 0; i < AdminDashboardMock.movements.length; i++) ...[
              if (i > 0) Divider(height: 1, color: muted.withValues(alpha: 0.2)),
              _MovementTile(m: AdminDashboardMock.movements[i], onSurface: onSurface, muted: muted),
            ],
          ],
        ),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({
    required this.m,
    required this.onSurface,
    required this.muted,
  });

  final LotMovementMock m;
  final Color onSurface;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.batchCode,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: onSurface),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _MiniBadge(m.fromStatus, AppColors.skyBlue),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.gray),
              ),
              _MiniBadge(m.toStatus, AppColors.warning),
            ],
          ),
          const SizedBox(height: 8),
          Text('Lieu : ${m.location}', style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
          Text('Date : ${m.dateLabel}', style: TextStyle(fontSize: 12, color: muted)),
          Text('Acteur : ${m.actorLabel}', style: TextStyle(fontSize: 12, color: muted, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge(this.text, this.bg);

  final String text;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: bg),
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({
    required this.cardColor,
    required this.onSurface,
    required this.muted,
  });

  final Color cardColor;
  final Color onSurface;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Column(
          children: [
            for (var i = 0; i < AdminDashboardMock.alerts.length; i++) ...[
              if (i > 0) Divider(height: 1, color: muted.withValues(alpha: 0.2)),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: severityColor(AdminDashboardMock.alerts[i].severity).withValues(alpha: 0.15),
                  child: Icon(
                    Icons.shield_outlined,
                    color: severityColor(AdminDashboardMock.alerts[i].severity),
                    size: 20,
                  ),
                ),
                title: Text(
                  AdminDashboardMock.alerts[i].title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: onSurface),
                ),
                subtitle: Text(
                  '${severityLabelFr(AdminDashboardMock.alerts[i].severity)} · ${AdminDashboardMock.alerts[i].time}',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PresenceSection extends StatelessWidget {
  const _PresenceSection({
    required this.cardColor,
    required this.onSurface,
    required this.muted,
  });

  final Color cardColor;
  final Color onSurface;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final p = AdminDashboardMock.presence;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PresenceStat('Présents', '${p.presentToday}', AppColors.success),
                  _PresenceStat('Retards', '${p.lateToday}', AppColors.warning),
                  _PresenceStat('Sorties', '${p.exitsToday}', AppColors.skyBlue),
                ],
              ),
              const SizedBox(height: 12),
              Text('Derniers pointages', style: TextStyle(fontWeight: FontWeight.w800, color: onSurface)),
              const SizedBox(height: 8),
              for (final c in AdminDashboardMock.recentChecks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        c.type == 'Check-in' ? Icons.login_rounded : Icons.logout_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${c.worker} · ${c.type}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onSurface),
                        ),
                      ),
                      Text(c.time, style: TextStyle(fontSize: 12, color: muted)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresenceStat extends StatelessWidget {
  const _PresenceStat(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: context.appOnSurfaceMuted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BlockchainCard extends StatelessWidget {
  const _BlockchainCard({
    required this.cardColor,
    required this.onSurface,
    required this.muted,
  });

  final Color cardColor;
  final Color onSurface;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final b = AdminDashboardMock.blockchain;
    final gold = const Color(0xFFB8860B);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_outlined, color: b.chainValid ? AppColors.success : AppColors.error),
                  const SizedBox(width: 8),
                  Text(
                    b.chainValid ? 'Chaîne valide' : 'Anomalie détectée',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: b.chainValid ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('Blocs : ${b.blockCount}', style: TextStyle(color: onSurface, fontWeight: FontWeight.w600)),
              Text('Dernier hash : ${b.lastBlockHashPreview}', style: TextStyle(color: muted, fontSize: 13)),
              Text('Dernier événement : ${b.lastEventType}', style: TextStyle(color: onSurface, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Acteur (anonymisé) : ${b.actorHashPreview}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrSection extends StatelessWidget {
  const _QrSection({
    required this.cardColor,
    required this.onSurface,
    required this.muted,
    required this.onGenerate,
    required this.onScan,
    required this.onVerify,
  });

  final Color cardColor;
  final Color onSurface;
  final Color muted;
  final VoidCallback onGenerate;
  final VoidCallback onScan;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final q = AdminDashboardMock.qrOverview;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total ${q.totalQr} · Actifs ${q.activeQr} · Liés lots bloqués ${q.linkedToBlockedLots}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonal(onPressed: onGenerate, child: const Text('Générer QR')),
                  FilledButton.tonal(onPressed: onScan, child: const Text('Scanner QR')),
                  OutlinedButton(onPressed: onVerify, child: const Text('Vérifier')),
                ],
              ),
              const SizedBox(height: 12),
              Text('Derniers QR', style: TextStyle(fontWeight: FontWeight.w800, color: onSurface)),
              const SizedBox(height: 8),
              for (final row in AdminDashboardMock.recentQrs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(row.batchCode, style: TextStyle(fontWeight: FontWeight.w800, color: onSurface)),
                            Text(row.lotLabel, style: TextStyle(fontSize: 12, color: muted)),
                            Text('Créé ${row.createdAt}', style: TextStyle(fontSize: 11, color: muted)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _MiniBadge(row.status, row.status == 'BLOQUÉ' ? AppColors.error : AppColors.success),
                          TextButton(onPressed: () {}, child: const Text('Voir QR')),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IotSection extends StatelessWidget {
  const _IotSection({
    required this.cardColor,
    required this.onSurface,
    required this.muted,
  });

  final Color cardColor;
  final Color onSurface;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final c in AdminDashboardMock.iotContainers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: cardColor,
                elevation: 2,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(c.code, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: onSurface)),
                          const Spacer(),
                          _MiniBadge(c.status, AppColors.skyBlue),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('GPS : ${c.gpsLabel}', style: TextStyle(fontSize: 12, color: muted)),
                      Text(
                        'Batterie ${c.batteryPercent}% · Vitesse ${c.speedKmh} km/h · Signal ${c.lastSignal}',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      if (c.alert != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Alerte IoT : ${c.alert}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DailyReportCard extends StatelessWidget {
  const _DailyReportCard({
    required this.cardColor,
    required this.onSurface,
    required this.muted,
    required this.onFullReport,
  });

  final Color cardColor;
  final Color onSurface;
  final Color muted;
  final VoidCallback onFullReport;

  @override
  Widget build(BuildContext context) {
    final r = AdminDashboardMock.dailyReport;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rapport du ${r.dateLabel}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: onSurface)),
              const SizedBox(height: 10),
              _Bullet('Présence', r.presenceSummary, muted, onSurface),
              _Bullet('Production', r.productionSummary, muted, onSurface),
              _Bullet('Alertes', r.alertsSummary, muted, onSurface),
              _Bullet('Chaîne', r.chainSummary, muted, onSurface),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onFullReport,
                  child: const Text('Voir rapport complet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.title, this.body, this.muted, this.onSurface);

  final String title;
  final String body;
  final Color muted;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13, height: 1.35, color: muted),
                children: [
                  TextSpan(
                    text: '$title : ',
                    style: TextStyle(fontWeight: FontWeight.w800, color: onSurface),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
