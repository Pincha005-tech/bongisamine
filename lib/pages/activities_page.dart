import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/theme/theme_notifier.dart';
import '../services/activity_service.dart';

class ActivityLog {
  const ActivityLog({
    required this.name,
    required this.action,
    required this.time,
  });

  final String name;
  final String action;
  final String time;

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      name: map['name'] as String? ?? '',
      action: map['action'] as String? ?? '',
      time: map['time'] as String? ?? '',
    );
  }
}

/// Données de démo (aligné scan / travailleurs quand le backend est indisponible).
const List<ActivityLog> _mockActivities = [
  ActivityLog(
    name: 'Jean Mukendi',
    action: 'Scan QR',
    time: '08:14',
  ),
  ActivityLog(
    name: 'Marie Kabila',
    action: 'Reconnaissance faciale',
    time: '08:12',
  ),
  ActivityLog(
    name: 'Pierre Tshibangu',
    action: 'Scan QR',
    time: '08:09',
  ),
  ActivityLog(
    name: 'Anne Mbuyi',
    action: 'Scan QR',
    time: '08:01',
  ),
  ActivityLog(
    name: 'David Kasongo',
    action: 'Reconnaissance faciale',
    time: '07:55',
  ),
  ActivityLog(
    name: 'Grace Lumba',
    action: 'Scan QR',
    time: '07:48',
  ),
  ActivityLog(
    name: 'Charles Ilunga',
    action: 'Départ site',
    time: 'Hier 17:30',
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

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  static const _pageSize = 5;

  final List<ActivityLog> _logs = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _usingMock = false;
  String? _error;
  int _page = 1;

  bool get _isSupervisor => UserRoleController.role == 'supervisor';

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<List<ActivityLog>?> _fetchFromApi(int page) async {
    try {
      final items = await ActivityService.fetchPage(page: page, limit: _pageSize);
      return items
          .map(
            (e) => ActivityLog(name: e.name, action: e.action, time: e.time),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  List<ActivityLog> _mockPage(int page) {
    final start = (page - 1) * _pageSize;
    if (start >= _mockActivities.length) return [];
    final end = (start + _pageSize).clamp(0, _mockActivities.length);
    return _mockActivities.sublist(start, end);
  }

  Future<void> _loadActivities({bool loadMore = false}) async {
    if (loadMore && (_isLoadingMore || !_hasMore)) return;

    if (!loadMore) {
      _page = 1;
      _hasMore = true;
      _usingMock = false;
      _error = null;
    }

    if (!mounted) return;
    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    List<ActivityLog> batch = [];
    var fromApi = false;

    final apiBatch = await _fetchFromApi(_page);
    if (apiBatch != null) {
      batch = apiBatch;
      fromApi = true;
    } else {
      batch = _mockPage(_page);
      if (!loadMore && _page == 1) {
        _usingMock = true;
        _error = 'Serveur indisponible — affichage des activités récentes (démo).';
      }
    }

    if (!mounted) return;
    setState(() {
      if (loadMore) {
        _logs.addAll(batch);
      } else {
        _logs
          ..clear()
          ..addAll(batch);
      }

      _hasMore = fromApi
          ? batch.length >= _pageSize
          : batch.isNotEmpty &&
              _page * _pageSize < _mockActivities.length;

      if (batch.isNotEmpty) _page++;
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  String _displayName(ActivityLog log) {
    if (_isSupervisor) return _anonymize(log.name);
    return log.name;
  }

  Future<void> _onRefresh() => _loadActivities();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPad + 24, 20, 8),
            child: Text(
              'Activités',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: context.appTitleAccent,
              ),
            ),
          ),
          if (_usingMock && _error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Material(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grayDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _logs.isEmpty
                    ? RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _onRefresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Text(
                                'Aucune activité pour le moment',
                                style: TextStyle(
                                  color: context.appOnSurfaceMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _onRefresh,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scroll) {
                            if (scroll.metrics.pixels >=
                                    scroll.metrics.maxScrollExtent - 80 &&
                                _hasMore &&
                                !_isLoadingMore) {
                              _loadActivities(loadMore: true);
                            }
                            return false;
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: _logs.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _logs.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final log = _logs[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  color: context.appCardColor,
                                  elevation: 2,
                                  shadowColor:
                                      AppColors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(14),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: context.appIconTileBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.history_rounded,
                                        color: context.appTitleAccent,
                                        size: 22,
                                      ),
                                    ),
                                    title: Text(
                                      _displayName(log),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: context.appOnSurface,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${log.action} • ${log.time}',
                                      style: TextStyle(
                                        color: context.appOnSurfaceMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
