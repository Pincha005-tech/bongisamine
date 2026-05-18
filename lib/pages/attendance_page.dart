import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../models/attendance_model.dart';
import '../models/worker_model.dart';
import '../services/attendance_service.dart';
import '../services/worker_service.dart';

/// Pointage entrée / sortie — `AGENT_CONTROLE`.
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<WorkerModel> _workers = [];
  List<AttendanceModel> _today = [];
  bool _loading = true;
  String? _error;
  int? _selectedWorkerId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final workers = await WorkerService.list();
      final today = await AttendanceService.today();
      if (!mounted) return;
      setState(() {
        _workers = workers;
        _today = today;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger les présences';
      });
    }
  }

  Future<void> _checkIn() async {
    final id = _selectedWorkerId;
    if (id == null) {
      _snack('Sélectionnez un ouvrier', isError: true);
      return;
    }
    try {
      final r = await AttendanceService.checkIn(id);
      _snack(r.message, isError: !r.success);
      if (r.success) await _load();
    } catch (e) {
      _snack(e.toString(), isError: true);
    }
  }

  Future<void> _checkOut() async {
    final id = _selectedWorkerId;
    if (id == null) {
      _snack('Sélectionnez un ouvrier', isError: true);
      return;
    }
    try {
      final r = await AttendanceService.checkOut(id);
      _snack(r.message, isError: !r.success);
      if (r.success) await _load();
    } catch (e) {
      _snack(e.toString(), isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    context.read<AuthController>();

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, topPad + 24, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Présences',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: context.appTitleAccent,
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButtonFormField<int>(
                        value: _selectedWorkerId,
                        decoration: InputDecoration(
                          labelText: 'Ouvrier',
                          filled: true,
                          fillColor: context.appCardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _workers
                            .map(
                              (w) => DropdownMenuItem(
                                value: w.id,
                                child: Text(w.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedWorkerId = v),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _checkIn,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.login_rounded),
                              label: const Text('Entrée'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _checkOut,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.cream,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Sortie'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Text(
                        'Aujourd\'hui (${_today.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.appTitleAccent,
                        ),
                      ),
                    ),
                  ),
                  if (_today.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'Aucun pointage aujourd\'hui',
                            style: TextStyle(color: context.appOnSurfaceMuted),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final a = _today[index];
                          String? worker;
                          for (final w in _workers) {
                            if (w.id == a.workerId) {
                              worker = w.fullName;
                              break;
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Material(
                              color: context.appCardColor,
                              borderRadius: BorderRadius.circular(14),
                              child: ListTile(
                                title: Text(
                                  worker ?? 'Ouvrier #${a.workerId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  '${a.status} • Entrée ${a.checkInLabel}',
                                ),
                                trailing: Icon(
                                  a.status == 'completed'
                                      ? Icons.check_circle_rounded
                                      : Icons.schedule_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _today.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }
}
