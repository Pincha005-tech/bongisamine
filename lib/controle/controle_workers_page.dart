import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import 'controle_mock_data.dart';

class ControleWorkersPage extends StatefulWidget {
  const ControleWorkersPage({super.key, this.onNavigateTab});

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<ControleWorkersPage> createState() => _ControleWorkersPageState();
}

class _ControleWorkersPageState extends State<ControleWorkersPage> {
  String _query = '';

  Future<void> _showWorkerForm({ControleWorker? existing}) async {
    final fn = TextEditingController(text: existing?.firstName ?? '');
    final ln = TextEditingController(text: existing?.lastName ?? '');
    final role = TextEditingController(text: existing?.role ?? 'mineur');
    final badge = TextEditingController(text: existing?.badgeId ?? '');
    final dept = TextEditingController(text: existing?.departmentRole ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Nouvel ouvrier' : 'Modifier ouvrier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: fn, decoration: const InputDecoration(labelText: 'Prénom')),
              TextField(controller: ln, decoration: const InputDecoration(labelText: 'Nom')),
              TextField(controller: role, decoration: const InputDecoration(labelText: 'Rôle')),
              TextField(controller: badge, decoration: const InputDecoration(labelText: 'badge_id')),
              TextField(
                controller: dept,
                decoration: const InputDecoration(labelText: 'Département'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enregistrer')),
        ],
      ),
    );

    if (ok != true || !mounted) {
      fn.dispose();
      ln.dispose();
      role.dispose();
      badge.dispose();
      dept.dispose();
      return;
    }

    if (existing == null) {
      ControleMockData.simulateCreateWorker(
        firstName: fn.text.trim(),
        lastName: ln.text.trim(),
        role: role.text.trim(),
        badgeId: badge.text.trim(),
        departmentRole: dept.text.trim().isEmpty ? null : dept.text.trim(),
      );
      _snack('POST /workers/ — ouvrier créé (mock)');
    } else {
      ControleMockData.simulateUpdateWorker(
        existing.id,
        firstName: fn.text.trim(),
        lastName: ln.text.trim(),
        role: role.text.trim(),
        badgeId: badge.text.trim(),
        departmentRole: dept.text.trim().isEmpty ? null : dept.text.trim(),
      );
      _snack('PUT /workers/${existing.id} — mis à jour (mock)');
    }
    fn.dispose();
    ln.dispose();
    role.dispose();
    badge.dispose();
    dept.dispose();
    setState(() {});
  }

  Future<void> _confirmDelete(ControleWorker w) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer ${w.fullName} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    ControleMockData.simulateDeleteWorker(w.id);
    _snack('DELETE /workers/${w.id} (mock)');
    setState(() {});
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final list = ControleMockData.workers.where((w) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return w.fullName.toLowerCase().contains(q) ||
          w.badgeId.toLowerCase().contains(q);
    }).toList();

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, top + 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ouvriers',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.appTitleAccent,
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _showWorkerForm(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Rechercher nom ou badge…',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            sliver: SliverList.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final w = list[i];
                return Material(
                  color: context.appCardColor,
                  elevation: 1,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        w.firstName[0],
                        style: const TextStyle(color: AppColors.cream, fontWeight: FontWeight.w800),
                      ),
                    ),
                    title: Text(w.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      '#${w.id} · ${w.badgeId} · ${w.departmentRole ?? w.role}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          w.faceRegistered ? Icons.face : Icons.face_retouching_off,
                          size: 20,
                          color: w.faceRegistered ? AppColors.success : AppColors.gray,
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') {
                              _showWorkerForm(existing: w);
                            } else if (v == 'face') {
                              widget.onNavigateTab?.call(3);
                            } else if (v == 'delete') {
                              _confirmDelete(w);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                            const PopupMenuItem(value: 'face', child: Text('Visage')),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      ],
                    ),
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
