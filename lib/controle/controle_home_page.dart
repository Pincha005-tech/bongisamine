import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_builder.dart';
import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/traceability/status_style.dart';
import '../coree/theme/app_page_style.dart';
import '../services/api_service.dart';
import 'controle_models.dart';
import 'controle_role.dart';
import 'controle_widgets.dart';

class ControleHomePage extends StatefulWidget {
  const ControleHomePage({super.key, this.onNavigateTab, this.active = true});

  final void Function(int tabIndex)? onNavigateTab;

  /// Onglet Accueil visible — recharge les pointages à chaque retour.
  final bool active;

  @override
  State<ControleHomePage> createState() => _ControleHomePageState();
}

class _ControleHomePageState extends State<ControleHomePage> {
  int _totalWorkers = 0;
  int _presentToday = 0;
  int _facesRegistered = 0;
  int _pendingCheckIn = 0;
  List<ControleAttendance> _todayAttendances = [];
  List<ControleWorker> _pending = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  @override
  void didUpdateWidget(ControleHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _load();
    }
  }

  Future<void> _load() async {
    final workerRows = await ApiService.fetchWorkersPaginated(limit: 200);
    final attRows = await ApiService.fetchAttendancesToday();
    final alerts = await ApiService.fetchAlerts(limit: 5);

    final workers = workerRows
        .map(
          (m) => ControleWorker(
            id: m['id'] as int? ?? 0,
            firstName: m['first_name'] as String? ?? '',
            lastName: m['last_name'] as String? ?? '',
            role: m['role'] as String? ?? '',
            badgeId: m['badge_id'] as String? ?? '',
            departmentRole: m['department_role'] as String?,
            faceRegistered: m['face_registered'] == true,
          ),
        )
        .toList();

    final nameById = {for (final w in workers) w.id: w.fullName};
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

    final presentIds = attendances
        .where((a) => a.status == 'present' || a.status == 'late')
        .map((a) => a.workerId)
        .toSet();

    final pending = workers
        .where((w) => !presentIds.contains(w.id))
        .toList();

    if (!mounted) return;
    setState(() {
      _todayAttendances = attendances;
      _pending = pending;
      _totalWorkers = workers.length;
      _presentToday = presentIds.length;
      _facesRegistered = workers.where((w) => w.faceRegistered).length;
      _pendingCheckIn = pending.length;
      _loading = false;
    });

    if (alerts.isEmpty && mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return AuthBuilder(
      builder: (context, auth) {
        final top = MediaQuery.paddingOf(context).top;
        return DecoratedBox(
      decoration: context.appPageDecoration,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: top + 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Material(
                  color: context.appCardColor,
                  elevation: 3,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, ${auth.name}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.appTitleAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contrôle d\'accès & RH terrain — Bongisa Mine',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.appOnSurfaceMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip(
                              Icons.badge_outlined,
                              controleRoleBadge(auth.user?.role ?? kRoleAgentControle),
                            ),
                            _chip(Icons.verified_user_outlined, 'Ouvriers · Visage · Pointage'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final w = (c.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: w,
                            child: ControleKpiTile(
                              label: 'Ouvriers',
                              value: '$_totalWorkers',
                              icon: Icons.groups_outlined,
                              accent: AppColors.primary,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: ControleKpiTile(
                              label: 'Présents (jour)',
                              value: '$_presentToday',
                              icon: Icons.how_to_reg_outlined,
                              accent: AppColors.success,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: ControleKpiTile(
                              label: 'Visages enregistrés',
                              value: '$_facesRegistered',
                              icon: Icons.face_outlined,
                              accent: const Color(0xFF8B5CF6),
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: ControleKpiTile(
                              label: 'Sans pointage',
                              value: '$_pendingCheckIn',
                              icon: Icons.pending_actions_outlined,
                              accent: AppColors.warning,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => widget.onNavigateTab?.call(2),
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login_rounded, color: AppColors.cream),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pointage entrée',
                                    style: TextStyle(
                                      color: AppColors.cream,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onNavigateTab?.call(1),
                          icon: const Icon(Icons.person_add_outlined),
                          label: const Text('Ouvriers'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_pending.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: ControleSectionTitle('En attente de pointage'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: _pending.length.clamp(0, 5),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final w = _pending[i];
                      return Material(
                        color: context.appCardColor,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          onTap: () => widget.onNavigateTab?.call(2),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.cream,
                            child: Text(
                              w.firstName.isNotEmpty ? w.firstName[0] : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          title: Text(w.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${w.badgeId} · ${w.departmentRole ?? w.role}'),
                          trailing: w.faceRegistered
                              ? const Icon(Icons.face, color: AppColors.success, size: 20)
                              : const Icon(Icons.face_retouching_off, color: AppColors.warning, size: 20),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SliverToBoxAdapter(
                child: ControleSectionTitle('Pointages du jour'),
              ),
              if (_todayAttendances.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Text(
                      'Aucun pointage aujourd\'hui. Enregistrez une entrée dans l\'onglet '
                      'Pointage, puis revenez ici ou tirez vers le bas pour actualiser.',
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
                    itemCount: _todayAttendances.length.clamp(0, 8),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final a = _todayAttendances[i];
                      final color = attendanceStatusColor(a.status);
                      return Material(
                        color: context.appCardColor,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          title: Text(
                            a.workerName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'Entrée ${a.checkInLabel ?? "—"}'
                            '${a.checkOutLabel != null ? " · Sortie ${a.checkOutLabel}" : ""}',
                          ),
                          trailing: ControleStatusChip(
                            attendanceStatusLabel(a.status),
                            color: color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _chip(IconData icon, String label) {
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
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
