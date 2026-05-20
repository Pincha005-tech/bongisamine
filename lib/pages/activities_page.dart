import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/theme/theme_notifier.dart';
import '../models/activity_log.dart';
import '../services/api_service.dart';
import 'activities_tracker_map_page.dart';

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
  String? _error;
  int _page = 1;

  bool get _isSupervisor => UserRoleController.role == 'supervisor';

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities({bool loadMore = false}) async {
    if (loadMore && (_isLoadingMore || !_hasMore)) return;

    if (!loadMore) {
      _page = 1;
      _hasMore = true;
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

    final batch = await ApiService.fetchActivitiesPage(
      page: _page,
      pageSize: _pageSize,
    );

    if (!mounted) return;
    setState(() {
      if (batch == null) {
        _error = 'Impossible de charger les activités';
        if (!loadMore) _logs.clear();
        _hasMore = false;
      } else {
        if (loadMore) {
          _logs.addAll(batch);
        } else {
          _logs
            ..clear()
            ..addAll(batch);
        }
        _hasMore = batch.length >= _pageSize;
        if (batch.isNotEmpty) _page++;
      }
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Activités',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: context.appTitleAccent,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ActivitiesTrackerMapPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_rounded, size: 20),
                  label: const Text('Carte GPS'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
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
