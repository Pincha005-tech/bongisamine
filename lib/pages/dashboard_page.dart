import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../services/api_service.Dart';

/// Données alignées sur `expo/app/(tabs)/dashboard.tsx`
const List<_BarDatum> _barData = [
  _BarDatum('Lun', 45),
  _BarDatum('Mar', 62),
  _BarDatum('Mer', 38),
  _BarDatum('Jeu', 75),
  _BarDatum('Ven', 55),
  _BarDatum('Sam', 30),
  _BarDatum('Dim', 20),
];

/// Indice de productivité mensuel (0–100) — 12 mois.
const List<_MonthDatum> _monthlyProductivity = [
  _MonthDatum('Jan', 62),
  _MonthDatum('Fév', 68),
  _MonthDatum('Mar', 71),
  _MonthDatum('Avr', 69),
  _MonthDatum('Mai', 74),
  _MonthDatum('Jun', 78),
  _MonthDatum('Jul', 82),
  _MonthDatum('Aoû', 80),
  _MonthDatum('Sep', 85),
  _MonthDatum('Oct', 88),
  _MonthDatum('Nov', 91),
  _MonthDatum('Déc', 95),
];

class _MonthDatum {
  const _MonthDatum(this.label, this.value);
  final String label;
  final int value;
}

int get _weekScanTotal => _barData.fold(0, (s, d) => s + d.value);

_BarDatum get _peakDay {
  return _barData.reduce(
    (a, b) => a.value >= b.value ? a : b,
  );
}

class _BarDatum {
  const _BarDatum(this.label, this.value);
  final String label;
  final int value;
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userName = 'Utilisateur';

  @override
  void initState() {
    super.initState();
    unawaited(_loadUserName());
  }

  Future<void> _loadUserName() async {
    final profile = await ApiService.getUserProfile();
    final name = profile['name'] as String?;
    if (!mounted || name == null || name.isEmpty) return;
    setState(() => _userName = name);
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    await _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

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
                padding: EdgeInsets.fromLTRB(20, topPad + 24, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour,',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.appOnSurfaceMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.appTitleAccent,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.engineering_rounded,
                        size: 24,
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                            value: '1 247',
                            change: '+3,2 %',
                            changeHint: 'vs semaine dernière',
                            up: true,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _StatCard(
                            icon: Icons.document_scanner_outlined,
                            label: 'Scans aujourd\'hui',
                            value: '856',
                            change: '+12 %',
                            changeHint: 'vs hier (764)',
                            up: true,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _StatCard(
                            icon: Icons.verified_user_outlined,
                            label: 'Taux de présence',
                            value: '98,2 %',
                            change: '-0,4 pt',
                            changeHint: 'objectif site : 97 %',
                            up: false,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _StatCard(
                            icon: Icons.trending_up_rounded,
                            label: 'Indice productivité',
                            value: '${_monthlyProductivity.last.value}',
                            change: '+5,1 %',
                            changeHint: 'sur 100 (mois en cours)',
                            up: true,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: _WeeklyBarChartCard()),
            const SliverToBoxAdapter(child: _MonthlyLineChartCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
    required this.change,
    required this.changeHint,
    required this.up,
  });

  final IconData icon;
  final String label;
  final String value;
  final String change;
  final String changeHint;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final changeColor = up ? AppColors.success : AppColors.error;

    return Material(
      color: context.appCardColor,
      elevation: 3,
      shadowColor: AppColors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.appIconTileBg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 22, color: context.appTitleAccent),
            ),
            const SizedBox(height: 10),
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
                color: context.appOnSurfaceMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  up ? Icons.north_east_rounded : Icons.south_east_rounded,
                  size: 14,
                  color: changeColor,
                ),
                const SizedBox(width: 2),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: changeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              changeHint,
              style: TextStyle(
                fontSize: 10,
                color: context.appOnSurfaceMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBarChartCard extends StatefulWidget {
  const _WeeklyBarChartCard();

  @override
  State<_WeeklyBarChartCard> createState() => _WeeklyBarChartCardState();
}

class _WeeklyBarChartCardState extends State<_WeeklyBarChartCard> {
  static const int _highlightIndex = 3;

  int? _touchedBarIndex;

  @override
  Widget build(BuildContext context) {
    const maxY = 80.0;
    final peak = _peakDay;
    final muted = context.appOnSurfaceMuted;
    final onSurface = context.appOnSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        color: context.appCardColor,
        elevation: 3,
        shadowColor: AppColors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scans de présence — 7 derniers jours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Chaque barre = nombre de passages enregistrés (QR ou visage) ce jour-là.',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              _ChartSummaryChip(
                icon: Icons.summarize_outlined,
                text:
                    '$_weekScanTotal scans cette semaine · Pic : ${peak.label} (${peak.value})',
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: context.appDividerOnPage,
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
                          reservedSize: 32,
                          interval: 20,
                          getTitlesWidget: (v, _) => Text(
                            v.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        axisNameWidget: Text(
                          'Scans',
                          style: TextStyle(
                            fontSize: 10,
                            color: muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        axisNameSize: 18,
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= _barData.length) {
                              return const SizedBox.shrink();
                            }
                            final d = _barData[i];
                            final isPeak = i == _highlightIndex;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                d.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isPeak
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isPeak
                                      ? context.appTitleAccent
                                      : muted,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, gi, rod, ri) {
                          final d = _barData[group.x.toInt()];
                          return BarTooltipItem(
                            '${d.label}\n${d.value} scans',
                            const TextStyle(
                              color: AppColors.cream,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          );
                        },
                      ),
                      touchCallback: (event, response) {
                        void apply() {
                          if (!mounted) return;
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.spot == null) {
                            if (_touchedBarIndex != null) {
                              setState(() => _touchedBarIndex = null);
                            }
                            return;
                          }
                          final index = response.spot!.touchedBarGroupIndex;
                          if (_touchedBarIndex != index) {
                            setState(() => _touchedBarIndex = index);
                          }
                        }

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          apply();
                        });
                      },
                    ),
                    barGroups: [
                      for (var i = 0; i < _barData.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: _barData[i].value.toDouble(),
                              width: 18,
                              color: _barColor(i, _touchedBarIndex == i),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                          showingTooltipIndicators:
                              _touchedBarIndex == i ? const [0] : const [],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _touchedBarIndex == null
                    ? Text(
                        key: const ValueKey('hint'),
                        'Touchez une barre pour afficher le détail du jour.',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Builder(
                        key: ValueKey('day-$_touchedBarIndex'),
                        builder: (context) {
                          final d = _barData[_touchedBarIndex!];
                          final pct = (d.value / _weekScanTotal * 100)
                              .toStringAsFixed(0);
                          return Text(
                            '${d.label} : ${d.value} scans ($pct % de la semaine)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: context.appTitleAccent,
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _LegendDot(color: AppColors.skyBlue, label: 'Jour normal'),
                  const SizedBox(width: 16),
                  _LegendDot(
                    color: AppColors.primary,
                    label: 'Jour le plus actif (${peak.label})',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _barColor(int index, bool touched) {
    if (touched) return AppColors.primaryLight;
    if (index == _highlightIndex) return AppColors.primary;
    return AppColors.skyBlue;
  }
}

class _MonthlyLineChartCard extends StatelessWidget {
  const _MonthlyLineChartCard();

  @override
  Widget build(BuildContext context) {
    final data = _monthlyProductivity;
    final last = data.last;
    final prev = data[data.length - 2];
    final delta = last.value - prev.value;
    final muted = context.appOnSurfaceMuted;
    final onSurface = context.appOnSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        color: context.appCardColor,
        elevation: 3,
        shadowColor: AppColors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Indice de productivité — 12 mois',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Score synthétique du site (0 = faible, 100 = excellent) basé sur présences et délais.',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              _ChartSummaryChip(
                icon: Icons.show_chart_rounded,
                text:
                    '${last.label} : ${last.value}/100 (${delta >= 0 ? '+' : ''}$delta vs ${prev.label})',
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    minY: 50,
                    maxY: 100,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: context.appDividerOnPage,
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
                          interval: 10,
                          getTitlesWidget: (v, _) => Text(
                            v.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: muted,
                            ),
                          ),
                        ),
                        axisNameWidget: Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 10,
                            color: muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        axisNameSize: 18,
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= data.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                data[i].label,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: muted,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) => spots.map((s) {
                          final m = data[s.x.toInt()];
                          return LineTooltipItem(
                            '${m.label}\n${m.value} / 100',
                            const TextStyle(
                              color: AppColors.cream,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < data.length; i++)
                            FlSpot(i.toDouble(), data[i].value.toDouble()),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, _, __, ___) {
                            final isLast = spot.x == data.length - 1;
                            return FlDotCirclePainter(
                              radius: isLast ? 5 : 3,
                              color: isLast
                                  ? AppColors.primary
                                  : AppColors.skyBlue,
                              strokeWidth: isLast ? 2 : 0,
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartSummaryChip extends StatelessWidget {
  const _ChartSummaryChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.appIconTileBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.appTitleAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.appOnSurface,
                height: 1.3,
              ),
            ),
          ),
        ],
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.appOnSurfaceMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
