import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import 'controle_mock_data.dart';
import 'controle_role.dart';
import 'controle_widgets.dart';

class ControleHomePage extends StatefulWidget {
  const ControleHomePage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<ControleHomePage> createState() => _ControleHomePageState();
}

class _ControleHomePageState extends State<ControleHomePage> {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final auth = context.watch<AuthController>();
    final stats = ControleMockData.homeStats;
    final pending = ControleMockData.workers.where((w) {
      return !ControleMockData.todayAttendances.any(
        (a) =>
            a.workerId == w.id &&
            (a.status == 'present' || a.status == 'checked_out'),
      );
    }).toList();

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 600));
          if (mounted) setState(() {});
        },
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
                            value: '${stats.totalWorkers}',
                            icon: Icons.groups_outlined,
                            accent: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: ControleKpiTile(
                            label: 'Présents (jour)',
                            value: '${stats.presentToday}',
                            icon: Icons.how_to_reg_outlined,
                            accent: AppColors.success,
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: ControleKpiTile(
                            label: 'Visages enregistrés',
                            value: '${stats.facesRegistered}',
                            icon: Icons.face_outlined,
                            accent: const Color(0xFF8B5CF6),
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: ControleKpiTile(
                            label: 'Sans pointage',
                            value: '${stats.pendingCheckIn}',
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
            if (pending.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: ControleSectionTitle('En attente de pointage'),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: pending.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final w = pending[i];
                    return Material(
                      color: context.appCardColor,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        onTap: () => widget.onNavigateTab?.call(2),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.cream,
                          child: Text(
                            w.firstName[0],
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
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      title: Text(a.workerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        'Entrée ${a.checkInLabel ?? "—"}'
                        '${a.checkOutLabel != null ? " · Sortie ${a.checkOutLabel}" : ""}',
                      ),
                      trailing: ControleStatusChip(
                        controleAttendanceLabel(a.status),
                        color: color,
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
