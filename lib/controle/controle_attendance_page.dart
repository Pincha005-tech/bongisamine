import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../coree/auth/auth_controller.dart';

import '../coree/traceability/status_style.dart';

import '../coree/theme/app_page_style.dart';

import '../services/api_service.dart';

import 'controle_models.dart';

import 'controle_widgets.dart';



class ControleAttendancePage extends StatefulWidget {

  const ControleAttendancePage({super.key, this.onNavigateTab, this.active = true});



  final void Function(int tabIndex)? onNavigateTab;

  /// Onglet Pointage visible — recharge la liste à chaque retour.
  final bool active;



  @override

  State<ControleAttendancePage> createState() => _ControleAttendancePageState();

}



class _ControleAttendancePageState extends State<ControleAttendancePage> {

  int? _selectedWorkerId;

  bool _busy = false;

  List<ControleWorker> _workers = [];

  List<ControleAttendance> _todayAttendances = [];



  @override

  void initState() {

    super.initState();

    if (widget.active) {

      WidgetsBinding.instance.addPostFrameCallback((_) => _load());

    }

  }



  @override

  void didUpdateWidget(ControleAttendancePage oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (widget.active && !oldWidget.active) {

      _load();

    }

  }



  Future<void> _load() async {

    final workerRows = await ApiService.fetchWorkersPaginated(limit: 100);

    final attRows = await ApiService.fetchAttendancesToday();

    final nameById = <int, String>{};

    final workers = workerRows.map((m) {

      final w = ControleWorker(

        id: m['id'] as int? ?? 0,

        firstName: m['first_name'] as String? ?? '',

        lastName: m['last_name'] as String? ?? '',

        role: m['role'] as String? ?? '',

        badgeId: m['badge_id'] as String? ?? '',

        departmentRole: m['department_role'] as String?,

        faceRegistered: m['face_registered'] == true,

      );

      nameById[w.id] = w.fullName;

      return w;

    }).toList();



    final attendances = attRows.map((a) {

      final wid = a['worker_id'] as int? ?? 0;

      return ControleAttendance(

        id: a['id'] as int? ?? 0,

        workerId: wid,

        workerName: nameById[wid] ?? 'Travailleur #$wid',

        status: a['status'] as String? ?? 'present',

        checkInLabel: ApiService.formatDateTime(a['check_in'] as String?),

        checkOutLabel: a['check_out'] != null

            ? ApiService.formatDateTime(a['check_out'] as String?)

            : null,

      );

    }).toList();



    if (!mounted) return;

    setState(() {

      _workers = workers;

      _todayAttendances = attendances;

    });

  }



  Future<void> _checkIn() async {

    final id = _selectedWorkerId;

    if (id == null) {

      _snack('Sélectionnez un ouvrier');

      return;

    }

    final auth = context.read<AuthController>();

    if (!auth.hasApiToken) {

      _snack('Session expirée — reconnectez-vous');

      return;

    }



    setState(() => _busy = true);

    final body = await ApiService.attendanceCheck('check-in', id);

    if (!mounted) return;

    setState(() => _busy = false);

    if (body != null) {
      _snack('Entrée enregistrée');
      await _load();
    } else {
      final msg = await ApiService.attendanceCheckMessage('check-in', id);
      _snack(msg ?? 'Pointage refusé ou déjà enregistré');
    }
  }

  Future<void> _checkOut() async {

    final id = _selectedWorkerId;

    if (id == null) {

      _snack('Sélectionnez un ouvrier');

      return;

    }

    final auth = context.read<AuthController>();

    if (!auth.hasApiToken) {

      _snack('Session expirée — reconnectez-vous');

      return;

    }



    setState(() => _busy = true);

    final body = await ApiService.attendanceCheck('check-out', id);

    if (!mounted) return;

    setState(() => _busy = false);

    if (body != null) {
      _snack('Sortie enregistrée');
      await _load();
    } else {
      final msg = await ApiService.attendanceCheckMessage('check-out', id);
      _snack(msg ?? 'Pas de pointage entrée actif');
    }
  }



  void _snack(String msg) {

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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

                          for (final w in _workers)

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

          const SliverToBoxAdapter(
            child: ControleSectionTitle('Pointages du jour'),
          ),
          if (_todayAttendances.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Text(
                  'Aucun pointage aujourd\'hui. Enregistrez une entrée ci-dessus, '
                  'puis tirez vers le bas pour actualiser.',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appOnSurfaceMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              sliver: SliverList.separated(
                itemCount: _todayAttendances.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {

                final a = _todayAttendances[i];

                final color = attendanceStatusColor(a.status);

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

                    trailing: ControleStatusChip(attendanceStatusLabel(a.status), color: color),

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


