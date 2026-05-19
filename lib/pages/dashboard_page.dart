import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_builder.dart';
import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../services/api_service.dart';

/// Tableau de bord — KPIs depuis `GET /dashboard/` et `GET /reports/daily`.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _BarDatum {
  const _BarDatum(this.label, this.value);
  final String label;
  final double value;
}

class _MonthDatum {
  const _MonthDatum(this.label, this.value);
  final String label;
  final double value;
}

const _weekdayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

class _DashboardPageState extends State<DashboardPage> {
  bool _refreshing = false;
  bool _loading = true;
  Map<String, dynamic>? _dashboard;
  Map<String, dynamic>? _daily;
  List<_BarDatum> _weeklyBars = [];
  List<_MonthDatum> _monthlyLine = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<_BarDatum> _buildWeeklyBars(List<Map<String, dynamic>> history) {
    final now = DateTime.now();
    final counts = List<double>.filled(7, 0);
    for (final h in history) {
      final created = DateTime.tryParse(h['created_at'] as String? ?? '');
      if (created == null) continue;
      final diff = now.difference(created).inDays;
      if (diff >= 0 && diff < 7) {
        counts[6 - diff] += 1;
      }
    }
    return List.generate(7, (i) => _BarDatum(_weekdayLabels[i], counts[i]));
  }

  List<_MonthDatum> _buildMonthlyLine(List<Map<String, dynamic>> history) {
    final now = DateTime.now();
    final monthLabels = <String>[];
    final counts = <double>[];
    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      monthLabels.add(_monthShort(d.month));
      counts.add(0);
    }
    for (final h in history) {
      final created = DateTime.tryParse(h['created_at'] as String? ?? '');
      if (created == null) continue;
      for (var i = 0; i < 6; i++) {
        final anchor = DateTime(now.year, now.month - (5 - i), 1);
        if (created.year == anchor.year && created.month == anchor.month) {
          counts[i] += 1;
          break;
        }
      }
    }
    return List.generate(6, (i) => _MonthDatum(monthLabels[i], counts[i]));
  }

  String _monthShort(int month) {
    const names = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return names[(month - 1).clamp(0, 11)];
  }

  Future<void> _loadData() async {
    final dashboard = await ApiService.fetchDashboard();
    final daily = await ApiService.fetchDailyReport();
    final history = await ApiService.fetchMineralHistory();
    if (!mounted) return;
    setState(() {
      _dashboard = dashboard;
      _daily = daily;
      _weeklyBars = _buildWeeklyBars(history);
      _monthlyLine = _buildMonthlyLine(history);
      _loading = false;
      _refreshing = false;
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await _loadData();
  }

  String _statWorkers() {
    final w = _dashboard?['workers'] ?? _daily?['workers'];
    if (w is int) return '$w';
    if (w is Map && w['total'] != null) return '${w['total']}';
    return '—';
  }

  String _statScans() {
    final q = _dashboard?['qrcodes'];
    if (q is int) return '$q';
    final m = _dashboard?['lot_movements'];
    if (m is int) return '$m';
    return '—';
  }

  String _statActive() {
    final att = _daily?['attendance'];
    if (att is Map) {
      final present = att['total_present'] as int? ?? 0;
      final total = (_dashboard?['workers'] as int?) ?? present;
      if (total > 0) {
        return '${(present / total * 100).toStringAsFixed(1)} %';
      }
    }
    return '—';
  }

  String _statProductivity() {
    final trace = _daily?['traceability'];
    if (trace is Map && trace['total_movements'] != null) {
      return '${trace['total_movements']}';
    }
    final m = _dashboard?['lot_movements'];
    if (m is int) return '$m';
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return AuthBuilder(
      builder: (context, auth) {
        final topPad = MediaQuery.paddingOf(context).top;
        final displayName = auth.name;

        return DecoratedBox(
      decoration: context.appPageDecoration,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, topPad + 24, 20, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour,',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: context.appOnSurfaceMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: context.appTitleAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.engineering_rounded,
                        size: 28,
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_refreshing)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primary,
                  backgroundColor: AppColors.creamDark,
                ),
              ),
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final gap = 12.0;
                      final w = (constraints.maxWidth - gap) / 2;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          SizedBox(
                            width: w,
                            child: _StatCard(
                              icon: Icons.groups_rounded,
                              label: 'Travailleurs',
                              value: _statWorkers(),
                              delta: 'API',
                              positive: true,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: _StatCard(
                              icon: Icons.document_scanner_outlined,
                              label: 'QR / mouvements',
                              value: _statScans(),
                              delta: 'API',
                              positive: true,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: _StatCard(
                              icon: Icons.layers_rounded,
                              label: 'Présence',
                              value: _statActive(),
                              delta: 'jour',
                              positive: true,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: _StatCard(
                              icon: Icons.trending_up_rounded,
                              label: 'Mouvements',
                              value: _statProductivity(),
                              delta: 'traçabilité',
                              positive: true,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Production hebdomadaire',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _WeeklyBarChartCard(
                  data: _weeklyBars.isEmpty
                      ? List.generate(7, (i) => _BarDatum(_weekdayLabels[i], 0))
                      : _weeklyBars,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Tendance mensuelle (tonnes)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MonthlyLineChartCard(
                  data: _monthlyLine.isEmpty
                      ? List.generate(6, (i) => _MonthDatum(_monthShort(i + 1), 0))
                      : _monthlyLine,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.delta,
    required this.positive,
  });

  final IconData icon;
  final String label;
  final String value;
  final String delta;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final deltaColor =
        positive ? AppColors.success : AppColors.warning;

    return Material(
      color: context.appCardColor,
      elevation: 3,
      shadowColor: AppColors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const Spacer(),
                Text(
                  delta,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: deltaColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.appOnSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.appOnSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBarChartCard extends StatefulWidget {
  const _WeeklyBarChartCard({required this.data});

  final List<_BarDatum> data;

  @override
  State<_WeeklyBarChartCard> createState() => _WeeklyBarChartCardState();
}

class _WeeklyBarChartCardState extends State<_WeeklyBarChartCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final maxY = widget.data
            .map((e) => e.value)
            .reduce((a, b) => a > b ? a : b) *
        1.15;

    return Material(
      color: context.appCardColor,
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_touchedIndex != null)
              _ChartSummaryChip(
                label: widget.data[_touchedIndex!].label,
                value: '${widget.data[_touchedIndex!].value.toInt()} t',
              ),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
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
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.gray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= widget.data.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              widget.data[i].label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.gray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < widget.data.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: widget.data[i].value,
                            width: 18,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            color: _touchedIndex == i
                                ? AppColors.skyBlue
                                : AppColors.primary,
                          ),
                        ],
                      ),
                  ],
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.spot == null) {
                        setState(() => _touchedIndex = null);
                        return;
                      }
                      setState(
                        () => _touchedIndex =
                            response.spot!.touchedBarGroupIndex,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyLineChartCard extends StatefulWidget {
  const _MonthlyLineChartCard({required this.data});

  final List<_MonthDatum> data;

  @override
  State<_MonthlyLineChartCard> createState() =>
      _MonthlyLineChartCardState();
}

class _MonthlyLineChartCardState extends State<_MonthlyLineChartCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < widget.data.length; i++)
        FlSpot(i.toDouble(), widget.data[i].value),
    ];
    final maxY = widget.data
            .map((e) => e.value)
            .reduce((a, b) => a > b ? a : b) *
        1.1;

    return Material(
      color: context.appCardColor,
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_touchedIndex != null)
              _ChartSummaryChip(
                label: widget.data[_touchedIndex!].label,
                value: '${widget.data[_touchedIndex!].value.toInt()} t',
              ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
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
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.gray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= widget.data.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              widget.data[i].label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.gray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) {
                          final i = spot.x.toInt();
                          final selected = _touchedIndex == i;
                          return FlDotCirclePainter(
                            radius: selected ? 5 : 3,
                            color: selected
                                ? AppColors.skyBlue
                                : AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: AppColors.cream,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.lineBarSpots == null ||
                          response.lineBarSpots!.isEmpty) {
                        setState(() => _touchedIndex = null);
                        return;
                      }
                      setState(
                        () => _touchedIndex =
                            response.lineBarSpots!.first.spotIndex,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSummaryChip extends StatelessWidget {
  const _ChartSummaryChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$label · $value',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
