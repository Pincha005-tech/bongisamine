import 'package:flutter/material.dart';

import '../coree/theme/app_page_style.dart';
import 'controle_mock_data.dart';
import 'controle_widgets.dart';

class ControleAttendancePage extends StatefulWidget {
  const ControleAttendancePage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<ControleAttendancePage> createState() => _ControleAttendancePageState();
}

class _ControleAttendancePageState extends State<ControleAttendancePage> {
  int? _selectedWorkerId;
  bool _busy = false;

  Future<void> _checkIn() async {
    final id = _selectedWorkerId;
    if (id == null) {
      _snack('Sélectionnez un ouvrier');
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final r = ControleMockData.simulateCheckIn(id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r == null) {
      _snack('Déjà pointé en entrée');
      return;
    }
    _snack('POST /attendances/check-in — ${r.checkInLabel}');
    setState(() {});
  }

  Future<void> _checkOut() async {
    final id = _selectedWorkerId;
    if (id == null) {
      _snack('Sélectionnez un ouvrier');
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final r = ControleMockData.simulateCheckOut(id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r == null) {
      _snack('Pas de pointage entrée actif');
      return;
    }
    _snack('POST /attendances/check-out — ${r.checkOutLabel}');
    setState(() {});
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pointage',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: context.appTitleAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'GET /attendances/today · check-in / check-out',
                    style: TextStyle(fontSize: 13, color: context.appOnSurfaceMuted),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: context.appCardColor,
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        key: ValueKey(_selectedWorkerId),
                        isExpanded: true,
                        initialValue: _selectedWorkerId,
                        decoration: const InputDecoration(labelText: 'Ouvrier'),
                        items: [
                          for (final w in ControleMockData.workers)
                            DropdownMenuItem(
                              value: w.id,
                              child: Text(
                                '${w.fullName} (${w.badgeId})',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _selectedWorkerId = v),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _busy ? null : _checkIn,
                              icon: const Icon(Icons.login_rounded),
                              label: const Text('Entrée'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : _checkOut,
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Sortie'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: ControleSectionTitle('Aujourd\'hui (GET /attendances/today)')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            sliver: SliverList.separated(
              itemCount: ControleMockData.todayAttendances.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = ControleMockData.todayAttendances[i];
                final color = controleStatusColor(a.status);
                return Material(
                  color: context.appCardColor,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    leading: Icon(
                      a.status == 'present' ? Icons.login_rounded : Icons.logout_rounded,
                      color: color,
                    ),
                    title: Text(a.workerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      'Entrée ${a.checkInLabel ?? "—"}'
                      '${a.checkOutLabel != null ? " · Sortie ${a.checkOutLabel}" : ""}',
                    ),
                    trailing: ControleStatusChip(controleAttendanceLabel(a.status), color: color),
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
