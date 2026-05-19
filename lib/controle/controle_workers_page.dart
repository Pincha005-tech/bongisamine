import 'package:flutter/material.dart';



import '../coree/colors/app_colors.dart';

import '../coree/theme/app_page_style.dart';

import '../services/api_service.dart';

import 'controle_models.dart';



class ControleWorkersPage extends StatefulWidget {

  const ControleWorkersPage({super.key, this.onNavigateTab});



  final void Function(int tabIndex)? onNavigateTab;



  @override

  State<ControleWorkersPage> createState() => _ControleWorkersPageState();

}



class _ControleWorkersPageState extends State<ControleWorkersPage> {

  String _query = '';

  List<ControleWorker> _workers = [];

  bool _loading = false;



  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWorkers());

  }



  ControleWorker _fromApi(Map<String, dynamic> m) {

    return ControleWorker(

      id: m['id'] as int? ?? 0,

      firstName: m['first_name'] as String? ?? '',

      lastName: m['last_name'] as String? ?? '',

      role: m['role'] as String? ?? '',

      badgeId: m['badge_id'] as String? ?? '',

      departmentRole: m['department_role'] as String?,

      faceRegistered: m['face_registered'] == true,

    );

  }



  Future<void> _loadWorkers() async {

    setState(() => _loading = true);

    final rows = await ApiService.fetchWorkersPaginated(limit: 100);

    if (mounted) {

      setState(() {

        _workers = rows.map(_fromApi).toList();

        _loading = false;

      });

    }

  }



  Future<void> _showWorkerForm({ControleWorker? existing}) async {
    final form = await showDialog<_WorkerFormValues>(
      context: context,
      builder: (ctx) => _WorkerFormDialog(existing: existing),
    );

    if (form == null || !mounted) return;

    final firstName = form.firstName;
    final lastName = form.lastName;
    final roleVal = form.role;
    final badgeId = form.badgeId;
    final department = form.department;

    if (existing == null) {

      final created = await ApiService.createWorker(

        firstName: firstName,

        lastName: lastName,

        role: roleVal,

        badgeId: badgeId,

        departmentRole: department,

      );

      if (created != null) {

        _snack('POST /workers/ — ouvrier créé');

        await _loadWorkers();

      } else {

        _snack('Échec création API');

      }

    } else {

      final updated = await ApiService.updateWorker(

        existing.id,

        firstName: firstName,

        lastName: lastName,

        role: roleVal,

        badgeId: badgeId,

        departmentRole: department,

      );

      if (updated != null) {

        _snack('PUT /workers/${existing.id} — mis à jour');

        await _loadWorkers();

      } else {

        _snack('Échec mise à jour API');

      }

    }

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



    final deleted = await ApiService.deleteWorker(w.id);

    if (deleted) {

      _snack('DELETE /workers/${w.id}');

      await _loadWorkers();

    } else {

      _snack('Échec suppression API');

    }

  }



  void _snack(String msg) {

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  }



  @override

  Widget build(BuildContext context) {

    final top = MediaQuery.paddingOf(context).top;

    final list = _workers.where((w) {

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

                  if (_loading)

                    const Padding(

                      padding: EdgeInsets.only(right: 8),

                      child: SizedBox(

                        width: 22,

                        height: 22,

                        child: CircularProgressIndicator(strokeWidth: 2),

                      ),

                    ),

                  FilledButton.tonalIcon(

                    onPressed: _showWorkerForm,

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

                        w.firstName.isNotEmpty ? w.firstName[0] : '?',

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

class _WorkerFormValues {
  const _WorkerFormValues({
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.badgeId,
    this.department,
  });

  final String firstName;
  final String lastName;
  final String role;
  final String badgeId;
  final String? department;
}

class _WorkerFormDialog extends StatefulWidget {
  const _WorkerFormDialog({this.existing});

  final ControleWorker? existing;

  @override
  State<_WorkerFormDialog> createState() => _WorkerFormDialogState();
}

class _WorkerFormDialogState extends State<_WorkerFormDialog> {
  late final TextEditingController _fn;
  late final TextEditingController _ln;
  late final TextEditingController _role;
  late final TextEditingController _badge;
  late final TextEditingController _dept;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _fn = TextEditingController(text: e?.firstName ?? '');
    _ln = TextEditingController(text: e?.lastName ?? '');
    _role = TextEditingController(text: e?.role ?? 'mineur');
    _badge = TextEditingController(text: e?.badgeId ?? '');
    _dept = TextEditingController(text: e?.departmentRole ?? '');
  }

  @override
  void dispose() {
    _fn.dispose();
    _ln.dispose();
    _role.dispose();
    _badge.dispose();
    _dept.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    Navigator.pop(
      context,
      _WorkerFormValues(
        firstName: _fn.text.trim(),
        lastName: _ln.text.trim(),
        role: _role.text.trim(),
        badgeId: _badge.text.trim(),
        department: _dept.text.trim().isEmpty ? null : _dept.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;
    return AlertDialog(
      title: Text(isNew ? 'Nouvel ouvrier' : 'Modifier ouvrier'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _fn,
              decoration: const InputDecoration(labelText: 'Prénom'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _ln,
              decoration: const InputDecoration(labelText: 'Nom'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _role,
              decoration: const InputDecoration(labelText: 'Rôle'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _badge,
              decoration: const InputDecoration(labelText: 'badge_id'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _dept,
              decoration: const InputDecoration(labelText: 'Département'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}


