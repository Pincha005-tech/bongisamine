import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../models/gps_tracker.dart';
import '../services/api_service.dart';

/// Carte des traceurs GPS (`ApiService.fetchGpsTrackers`).
class ActivitiesTrackerMapPage extends StatefulWidget {
  const ActivitiesTrackerMapPage({super.key});

  @override
  State<ActivitiesTrackerMapPage> createState() =>
      _ActivitiesTrackerMapPageState();
}

const LatLng _defaultCenter = LatLng(-11.6647, 27.4794);

class _ActivitiesTrackerMapPageState extends State<ActivitiesTrackerMapPage> {
  static const _refreshInterval = Duration(seconds: 30);

  final MapController _mapController = MapController();
  final List<GpsTracker> _trackers = [];

  Timer? _pollTimer;
  bool _isLoading = true;
  String? _bannerMessage;
  GpsTracker? _selected;

  @override
  void initState() {
    super.initState();
    _loadTrackers();
    _pollTimer = Timer.periodic(_refreshInterval, (_) => _loadTrackers());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadTrackers() async {
    if (!mounted) return;
    if (_trackers.isEmpty) {
      setState(() => _isLoading = true);
    }

    final list = await ApiService.fetchGpsTrackers();

    if (!mounted) return;
    setState(() {
      _trackers.clear();
      if (list != null && list.isNotEmpty) {
        _trackers.addAll(list);
        _bannerMessage = null;
      } else {
        _bannerMessage = 'Aucun traceur';
      }
      _isLoading = false;
      if (_selected != null &&
          !_trackers.any((t) => t.id == _selected!.id)) {
        _selected = null;
      }
    });

    if (_trackers.isNotEmpty) _fitMapToTrackers();
  }

  void _fitMapToTrackers() {
    if (_trackers.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _trackers.isEmpty) return;

      if (_trackers.length == 1) {
        final t = _trackers.first;
        _mapController.move(LatLng(t.latitude, t.longitude), 14);
        return;
      }

      var minLat = _trackers.first.latitude;
      var maxLat = minLat;
      var minLng = _trackers.first.longitude;
      var maxLng = minLng;

      for (final t in _trackers) {
        minLat = minLat < t.latitude ? minLat : t.latitude;
        maxLat = maxLat > t.latitude ? maxLat : t.latitude;
        minLng = minLng < t.longitude ? minLng : t.longitude;
        maxLng = maxLng > t.longitude ? maxLng : t.longitude;
      }

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(
            LatLng(minLat, minLng),
            LatLng(maxLat, maxLng),
          ),
          padding: const EdgeInsets.all(56),
        ),
      );
    });
  }

  Color _statusColor(TrackerStatus status) {
    switch (status) {
      case TrackerStatus.active:
        return AppColors.success;
      case TrackerStatus.idle:
        return AppColors.warning;
      case TrackerStatus.offline:
        return AppColors.gray;
    }
  }

  List<Marker> _buildMarkers() {
    return _trackers.map((tracker) {
      final point = LatLng(tracker.latitude, tracker.longitude);
      final selected = _selected?.id == tracker.id;
      final color = _statusColor(tracker.status);

      return Marker(
        point: point,
        width: selected ? 48 : 40,
        height: selected ? 48 : 40,
        child: GestureDetector(
          onTap: () => setState(() => _selected = tracker),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.white,
                    width: selected ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.gps_fixed_rounded,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: context.appPageDecoration,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: context.appTitleAccent,
              title: Text(
                'Traceurs GPS',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: context.appTitleAccent,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Actualiser',
                  onPressed: _isLoading ? null : _loadTrackers,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            if (_bannerMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Material(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
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
                            _bannerMessage!,
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
              child: _isLoading && _trackers.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: const MapOptions(
                            initialCenter: _defaultCenter,
                            initialZoom: 13,
                            interactionOptions: InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'app.rork.qcp2e8s0utf7rziuem7fi',
                            ),
                            MarkerLayer(markers: _buildMarkers()),
                          ],
                        ),
                        Positioned(
                          right: 12,
                          bottom: _selected != null ? 140 : 16,
                          child: FloatingActionButton.small(
                            heroTag: 'fit_bounds',
                            backgroundColor: context.appCardColor,
                            foregroundColor: context.appTitleAccent,
                            onPressed: _fitMapToTrackers,
                            child: const Icon(Icons.fit_screen_rounded),
                          ),
                        ),
                        if (_selected != null)
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: _TrackerDetailCard(
                              tracker: _selected!,
                              statusColor: _statusColor(_selected!.status),
                              onClose: () => setState(() => _selected = null),
                            ),
                          ),
                      ],
                    ),
            ),
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.sync_rounded,
                      size: 14,
                      color: context.appOnSurfaceMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _trackers.isEmpty
                          ? (_bannerMessage ?? 'Aucun traceur')
                          : '${_trackers.length} traceur(s) · live',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.appOnSurfaceMuted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'MAJ auto 30 s',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appOnSurfaceMuted,
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

class _TrackerDetailCard extends StatelessWidget {
  const _TrackerDetailCard({
    required this.tracker,
    required this.statusColor,
    required this.onClose,
  });

  final GpsTracker tracker;
  final Color statusColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: AppColors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      color: context.appCardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.sensors_rounded, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tracker.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: context.appOnSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tracker.id,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appOnSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tracker.status.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tracker.latitude.toStringAsFixed(5)}, '
                    '${tracker.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appOnSurfaceMuted,
                    ),
                  ),
                  if (tracker.updatedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Dernière position : ${tracker.updatedAt}',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appOnSurfaceMuted,
                      ),
                    ),
                  ],
                  if (tracker.batteryPercent != null)
                    Text(
                      'Batterie : ${tracker.batteryPercent} %',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appOnSurfaceMuted,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
