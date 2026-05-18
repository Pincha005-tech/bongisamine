import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';

/// Tableau de bord (données de démonstration — sans backend).
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

const List<_BarDatum> _weeklyBars = [
  _BarDatum('Lun', 72),
  _BarDatum('Mar', 85),
  _BarDatum('Mer', 78),
  _BarDatum('Jeu', 91),
  _BarDatum('Ven', 88),
  _BarDatum('Sam', 64),
  _BarDatum('Dim', 58),
];

const List<_MonthDatum> _monthlyLine = [
  _MonthDatum('Jan', 420),
  _MonthDatum('Fév', 480),
  _MonthDatum('Mar', 510),
  _MonthDatum('Avr', 495),
  _MonthDatum('Mai', 540),
  _MonthDatum('Juin', 580),
];

class _DashboardPageState extends State<DashboardPage> {
  bool _refreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final auth = context.watch<AuthController>();
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
                          child: const _StatCard(
                            icon: Icons.groups_rounded,
                            label: 'Travailleurs',
                            value: '1 247',
                            delta: '+3.2 %',
                            positive: true,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: const _StatCard(
                            icon: Icons.document_scanner_outlined,
                            label: 'Scans',
                            value: '856',
                            delta: '+12 %',
                            positive: true,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: const _StatCard(
                            icon: Icons.layers_rounded,
                            label: 'Actifs',
                            value: '98.2 %',
                            delta: '−0.4 %',
                            positive: false,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: const _StatCard(
                            icon: Icons.trending_up_rounded,
                            label: 'Productivité',
                            value: '87',
                            delta: '+5.1 %',
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
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _WeeklyBarChartCard(data: _weeklyBars),
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
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _MonthlyLineChartCard(data: _monthlyLine),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Material(
                  color: context.appCardColor,
                  elevation: 2,
                  shadowColor: AppColors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.skyBlue,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Mode démonstration — les chiffres sont fictifs. '
                            'Connectez le backend pour des données réelles.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: context.appOnSurfaceMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
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
