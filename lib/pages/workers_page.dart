import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/theme/theme_notifier.dart';
import '../models/worker_item.dart';

const List<WorkerItem> _mockWorkers = [
  WorkerItem(
    id: '1',
    name: 'Jean Mukendi',
    status: WorkerStatus.active,
    department: 'Extraction',
    lastScan: '07:42',
  ),
  WorkerItem(
    id: '2',
    name: 'Marie Kabila',
    status: WorkerStatus.active,
    department: 'Sécurité',
    lastScan: '07:38',
  ),
  WorkerItem(
    id: '3',
    name: 'Pierre Tshibangu',
    status: WorkerStatus.onLeave,
    department: 'Maintenance',
    lastScan: '—',
  ),
  WorkerItem(
    id: '4',
    name: 'Anne Mbuyi',
    status: WorkerStatus.active,
    department: 'Extraction',
    lastScan: '08:01',
  ),
  WorkerItem(
    id: '5',
    name: 'Charles Ilunga',
    status: WorkerStatus.inactive,
    department: 'Logistique',
    lastScan: 'Hier',
  ),
  WorkerItem(
    id: '6',
    name: 'Grace Lumba',
    status: WorkerStatus.active,
    department: 'Sécurité',
    lastScan: '07:55',
  ),
  WorkerItem(
    id: '7',
    name: 'David Kasongo',
    status: WorkerStatus.active,
    department: 'Extraction',
    lastScan: '08:10',
  ),
  WorkerItem(
    id: '8',
    name: 'Sophie Ngalula',
    status: WorkerStatus.onLeave,
    department: 'Maintenance',
    lastScan: '—',
  ),
];

String _anonymize(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '***';
  if (parts.length < 2) {
    final first = parts[0];
    return first.isEmpty ? '***' : '${first[0]}***';
  }
  final first = parts[0];
  final second = parts[1];
  if (second.isEmpty) return '$first ***';
  return '$first ${second[0]}.';
}

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersFilters {
  const _WorkersFilters({
    this.status,
    this.department,
    this.nameSort,
  });

  final WorkerStatus? status;
  final String? department;
  final WorkerNameSort? nameSort;

  WorkerNameSort get resolvedNameSort =>
      nameSort ?? WorkerNameSort.ascending;

  bool get isEmpty =>
      status == null &&
      department == null &&
      resolvedNameSort == WorkerNameSort.ascending;
}

class _WorkersPageState extends State<WorkersPage> {
  final TextEditingController _queryController = TextEditingController();

  _WorkersFilters _filters = const _WorkersFilters();
  List<WorkerItem> _allWorkers = List<WorkerItem>.from(_mockWorkers);
  List<WorkerItem> _filtered = List<WorkerItem>.from(_mockWorkers);
  List<String> _departments = _mockWorkers
      .map((w) => w.department)
      .toSet()
      .toList()
    ..sort();
  bool get _isSupervisor => UserRoleController.role == 'supervisor';

  bool get _hasActiveFilters => !_filters.isEmpty;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_applyFilter);
    _applyFilter();
  }

  @override
  void dispose() {
    _queryController.removeListener(_applyFilter);
    _queryController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _queryController.text.trim().toLowerCase();
    setState(() {
      _filtered = _allWorkers.where((w) {
        if (q.isNotEmpty &&
            !w.name.toLowerCase().contains(q) &&
            !w.department.toLowerCase().contains(q)) {
          return false;
        }
        if (_filters.status != null && w.status != _filters.status) {
          return false;
        }
        if (_filters.department != null &&
            w.department != _filters.department) {
          return false;
        }
        return true;
      }).toList()
        ..sort((a, b) {
          final cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          return _filters.resolvedNameSort == WorkerNameSort.ascending
              ? cmp
              : -cmp;
        });
    });
  }

  Future<void> _openFilterSheet() async {
    var draft = _filters;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.gray.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Filtrer et trier',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Filtres, tri par nom et recherche se combinent.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _FilterSectionTitle(title: 'Statut'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _FilterChip(
                              label: 'Tous',
                              selected: draft.status == null,
                              onTap: () => setModalState(
                                () => draft = _WorkersFilters(
                                  department: draft.department,
                                  nameSort: draft.nameSort,
                                ),
                              ),
                            ),
                            _FilterChip(
                              label: 'Actif',
                              selected: draft.status == WorkerStatus.active,
                              onTap: () => setModalState(
                                () => draft = _WorkersFilters(
                                  status: WorkerStatus.active,
                                  department: draft.department,
                                  nameSort: draft.nameSort,
                                ),
                              ),
                            ),
                            _FilterChip(
                              label: 'Inactif',
                              selected: draft.status == WorkerStatus.inactive,
                              onTap: () => setModalState(
                                () => draft = _WorkersFilters(
                                  status: WorkerStatus.inactive,
                                  department: draft.department,
                                  nameSort: draft.nameSort,
                                ),
                              ),
                            ),
                            _FilterChip(
                              label: 'Congé',
                              selected: draft.status == WorkerStatus.onLeave,
                              onTap: () => setModalState(
                                () => draft = _WorkersFilters(
                                  status: WorkerStatus.onLeave,
                                  department: draft.department,
                                  nameSort: draft.nameSort,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _FilterSectionTitle(title: 'Département'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _FilterChip(
                              label: 'Tous',
                              selected: draft.department == null,
                              onTap: () => setModalState(
                                () => draft = _WorkersFilters(
                                  status: draft.status,
                                  nameSort: draft.nameSort,
                                ),
                              ),
                            ),
                            for (final dept in _departments)
                              _FilterChip(
                                label: dept,
                                selected: draft.department == dept,
                                onTap: () => setModalState(
                                  () => draft = _WorkersFilters(
                                    status: draft.status,
                                    department: dept,
                                    nameSort: draft.nameSort,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _FilterSectionTitle(title: 'Tri par nom'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _FilterChip(
                              label: 'A → Z',
                              selected: draft.resolvedNameSort ==
                                  WorkerNameSort.ascending,
                              onTap: () => setModalState(
                                () => draft = _WorkersFilters(
                                  status: draft.status,
                                  department: draft.department,
                                  nameSort: WorkerNameSort.ascending,
                                ),
                              ),
                            ),
                            _FilterChip(
                              label: 'Z → A',
                              selected: draft.resolvedNameSort ==
                                  WorkerNameSort.descending,
                              onTap: () => setModalState(
                                () => draft = _WorkersFilters(
                                  status: draft.status,
                                  department: draft.department,
                                  nameSort: WorkerNameSort.descending,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setModalState(
                                    () => draft = const _WorkersFilters(),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.creamDark,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Réinitialiser'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.cream,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Appliquer'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (applied == true && mounted) {
      setState(() => _filters = draft);
      _applyFilter();
    }
  }

  int get _activeCount =>
      _allWorkers.where((w) => w.status == WorkerStatus.active).length;

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) _applyFilter();
  }

  String _displayName(WorkerItem w) {
    if (_isSupervisor) return _anonymize(w.name);
    return w.name;
  }

  String get _filterSummary {
    final parts = <String>[];
    if (_filters.status != null) {
      parts.add(switch (_filters.status!) {
        WorkerStatus.active => 'Actifs',
        WorkerStatus.inactive => 'Inactifs',
        WorkerStatus.onLeave => 'En congé',
      });
    }
    if (_filters.department != null) {
      parts.add(_filters.department!);
    }
    if (_filters.resolvedNameSort == WorkerNameSort.descending) {
      parts.add('Z → A');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPad + 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Travailleurs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.appTitleAccent,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$_activeCount',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      'actifs auj.',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appOnSurfaceMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _SearchField(controller: _queryController)),
                const SizedBox(width: 10),
                _FilterButton(
                  active: _hasActiveFilters,
                  onPressed: _openFilterSheet,
                ),
              ],
            ),
          ),
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: Text(_filterSummary),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() => _filters = const _WorkersFilters());
                    _applyFilter();
                  },
                  backgroundColor: context.appIconTileBg,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.appTitleAccent,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _onRefresh,
              child: _filtered.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 48,
                          color: context.appOnSurfaceMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun travailleur ne correspond aux critères.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.appOnSurfaceMuted,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _WorkerCard(
                            item: item,
                            displayName: _displayName(item),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(14),
      color: context.appCardColor,
      child: SizedBox(
        height: 46,
        child: TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 15,
            color: context.appOnSurface,
          ),
          cursorColor: AppColors.primary,
          decoration: const InputDecoration(
            hintText: 'Rechercher...',
            hintStyle: TextStyle(
              fontSize: 15,
              color: AppColors.gray,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.gray,
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 46, maxHeight: 46),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.onPressed,
    this.active = false,
  });

  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(14),
      color: active ? AppColors.primary : context.appCardColor,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 18,
                color: active ? AppColors.cream : context.appTitleAccent,
              ),
              if (active)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
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

class _FilterSectionTitle extends StatelessWidget {
  const _FilterSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: context.appOnSurfaceMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : context.appIconTileBg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.cream : context.appOnSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({
    required this.item,
    required this.displayName,
  });

  final WorkerItem item;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final initial = item.name.isNotEmpty ? item.name[0].toUpperCase() : '?';

    return Material(
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      color: context.appCardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.appOnSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.department,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appOnSurfaceMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: item.status),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: context.appDividerOnPage, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.gray,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Dernier scan: ${item.lastScan}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final WorkerStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color fg;
    late final Color bg;
    late final IconData icon;
    late final String label;

    switch (status) {
      case WorkerStatus.active:
        fg = AppColors.success;
        bg = const Color(0xFFDCFCE7);
        icon = Icons.how_to_reg_outlined;
        label = 'Actif';
        break;
      case WorkerStatus.inactive:
        fg = AppColors.error;
        bg = const Color(0xFFFEE2E2);
        icon = Icons.person_off_outlined;
        label = 'Inactif';
        break;
      case WorkerStatus.onLeave:
        fg = AppColors.warning;
        bg = const Color(0xFFFEF3C7);
        icon = Icons.schedule_rounded;
        label = 'Congé';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
