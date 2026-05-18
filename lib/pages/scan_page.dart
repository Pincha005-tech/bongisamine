import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_controller.dart';
import '../coree/auth/app_roles.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../services/qr_service.dart';
import '../services/traceability_service.dart';
import 'scan/face_scan_screen.dart';
import 'scan/live_qr_scan_screen.dart';

/// Aligné sur `expo/app/(tabs)/scan.tsx`
enum ScanRecordType { qr, face }

class ScanRecord {
  const ScanRecord({
    required this.id,
    required this.type,
    required this.value,
    required this.time,
  });

  final String id;
  final ScanRecordType type;
  final String value;
  final String time;
}

const List<ScanRecord> _recentScans = [
  ScanRecord(id: '1', type: ScanRecordType.qr, value: 'EMP-4821', time: '08:14'),
  ScanRecord(
    id: '2',
    type: ScanRecordType.face,
    value: 'Jean Mukendi',
    time: '08:12',
  ),
  ScanRecord(id: '3', type: ScanRecordType.qr, value: 'EMP-2954', time: '08:09'),
  ScanRecord(id: '4', type: ScanRecordType.qr, value: 'EMP-7712', time: '07:58'),
  ScanRecord(
    id: '5',
    type: ScanRecordType.face,
    value: 'Marie Kabila',
    time: '07:55',
  ),
];

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  ScanRecordType _mode = ScanRecordType.qr;
  bool _openingCamera = false;
  String? _lastResult;
  final List<ScanRecord> _history = [];

  bool get _isSupervisor {
    final auth = context.read<AuthController>();
    return auth.isSupervisor ||
        AppRoles.isSupervisorApiRole(auth.apiRole);
  }

  Future<void> _openCameraScan() async {
    if (_openingCamera) return;
    setState(() => _openingCamera = true);
    try {
      final isAgent = context.read<AuthController>().isAgent;
      if (isAgent || _mode == ScanRecordType.face) {
        await _scanFaceFlow();
      } else {
        await _scanQrFlow();
      }
    } finally {
      if (mounted) setState(() => _openingCamera = false);
    }
  }

  Future<void> _scanFaceFlow() async {
    final name = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const FaceScanScreen(),
        fullscreenDialog: true,
      ),
    );
    if (name != null && mounted) {
      setState(() {
        _lastResult = name;
        _history.insert(
          0,
          ScanRecord(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ScanRecordType.face,
            value: name,
            time: _nowLabel(),
          ),
        );
      });
    }
  }

  Future<void> _scanQrFlow() async {
    final raw = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const LiveQrScanScreen(),
        fullscreenDialog: true,
      ),
    );
    if (raw == null || !mounted) return;

    final parsed = QrService.parseScannedPayload(raw);
    if (parsed.signature.isEmpty) {
      _showSnack('QR invalide (signature manquante)', isError: true);
      return;
    }

    if (!_isSupervisor) {
      try {
        final verify = await QrService.verify(parsed.data, parsed.signature);
        final valid = verify['valid'] as bool? ?? false;
        _showSnack(
          verify['message'] as String? ?? (valid ? 'QR valide' : 'QR invalide'),
          isError: !valid,
        );
        if (valid) {
          setState(() => _lastResult = raw);
        }
      } catch (e) {
        _showSnack(e.toString(), isError: true);
      }
      return;
    }

    final photoPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const FaceScanScreen(captureOnly: true),
        fullscreenDialog: true,
      ),
    );
    if (photoPath == null || !mounted) return;

    final auth = context.read<AuthController>();
    try {
      final movement = await TraceabilityService.scan(
        apiRole: auth.apiRole,
        imagePath: photoPath,
        qrData: parsed.data,
        qrSignature: parsed.signature,
      );
      if (!mounted) return;
      setState(() {
        _lastResult =
            '${movement.previousStatus ?? "?"} → ${movement.newStatus}';
        _history.insert(
          0,
          ScanRecord(
            id: movement.id.toString(),
            type: ScanRecordType.qr,
            value: _lastResult!,
            time: _nowLabel(),
          ),
        );
      });
      _showSnack('Lot mis à jour : ${movement.newStatus}');
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  String _nowLabel() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }

  void _showSnack(String msg, {bool isError = false}) {
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
    final isAgent = context.watch<AuthController>().isAgent;

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, topPad + 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: context.appTitleAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAgent
                        ? 'Reconnaissance faciale terrain'
                        : 'Scan QR lot + contrôle visage',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.appOnSurfaceMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isAgent) SliverToBoxAdapter(child: _buildModeToggle()),
          SliverToBoxAdapter(child: _buildScanArea()),
          SliverToBoxAdapter(child: _buildHistorySection()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: context.appCardColor,
        elevation: 2,
        shadowColor: AppColors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _ModeSegment(
                  active: _mode == ScanRecordType.qr,
                  icon: Icons.qr_code_2_rounded,
                  label: 'QR Code',
                  onTap: () => setState(() => _mode = ScanRecordType.qr),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _ModeSegment(
                  active: _mode == ScanRecordType.face,
                  icon: Icons.account_circle_outlined,
                  label: 'Visage',
                  onTap: () => setState(() => _mode = ScanRecordType.face),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openingCamera ? null : _openCameraScan,
                    customBorder: const CircleBorder(),
                    child: _scanCircle(
                      fill: AppColors.cream.withValues(
                        alpha: _openingCamera ? 0.35 : 0.2,
                      ),
                      child: _openingCamera
                          ? const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: AppColors.cream,
                              ),
                            )
                          : Icon(
                              _mode == ScanRecordType.qr
                                  ? Icons.qr_code_scanner_rounded
                                  : Icons.face_retouching_natural_rounded,
                              size: 48,
                              color: AppColors.cream,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _openingCamera
                      ? 'Ouverture de la caméra…'
                      : _mode == ScanRecordType.qr
                          ? 'Appuyez pour ouvrir la caméra QR'
                          : 'Appuyez pour ouvrir la caméra (visage)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.cream,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_lastResult != null && !_openingCamera) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _mode == ScanRecordType.qr
                              ? 'Dernier QR scanné'
                              : 'Dernière identification',
                          style: TextStyle(
                            color: AppColors.creamDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _lastResult!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scanCircle({
    required Color fill,
    required Widget child,
  }) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: AppColors.cream, width: 3),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildHistorySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Material(
        color: context.appCardColor,
        elevation: 2,
        shadowColor: AppColors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: context.appTitleAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Scans récents',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.appOnSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(
                _history.isNotEmpty ? _history.length : _recentScans.length,
                (i) {
                final scans =
                    _history.isNotEmpty ? _history : _recentScans;
                final scan = scans[i];
                final isLast = i == scans.length - 1;
                return Container(
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(
                              color: context.appDividerOnPage,
                              width: 1,
                            ),
                          ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: scan.type == ScanRecordType.qr
                                    ? (context.isAppDark
                                        ? AppColors.skyBlueDark
                                            .withValues(alpha: 0.35)
                                        : AppColors.lightBlue)
                                    : context.appIconTileBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                scan.type == ScanRecordType.qr
                                    ? Icons.qr_code_2_rounded
                                    : Icons.account_circle_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scan.value,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: context.appOnSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    scan.type == ScanRecordType.qr
                                        ? 'QR Code'
                                        : 'Reconnaissance',
                                    style: const TextStyle(
                                      fontSize: 11,
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
                      Text(
                        scan.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appOnSurfaceMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  const _ModeSegment({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: active
                    ? AppColors.cream
                    : context.appTitleAccent,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? AppColors.cream
                      : context.appTitleAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
