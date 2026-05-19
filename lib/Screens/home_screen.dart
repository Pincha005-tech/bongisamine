import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../reception/reception_role.dart';
import '../reception/reception_shell_screen.dart';
import '../transport/transport_role.dart';
import '../transport/transport_shell_screen.dart';
import '../extraction/extraction_role.dart';
import '../extraction/extraction_shell_screen.dart';
import '../controle/controle_role.dart';
import '../controle/controle_shell_screen.dart';
import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../pages/activities_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/scan_page.dart';
import '../pages/security_page.dart';
import '../pages/workers_page.dart';

/// Équivalent Expo `app/(tabs)/_layout.tsx` (barre d’onglets ; pas l’écran `activities.tsx`).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthController? _auth;
  bool _loading = true;
  String? _role;
  int currentIndex = 0;

  void _goToTab(int index) {
    setState(() => currentIndex = index);
  }

  late final List<Widget> _workerPages = [
    DashboardPage(onNavigateTab: _goToTab),
    const WorkersPage(),
    const ScanPage(),
    const ActivitiesPage(),
    const SettingsPage(),
  ];

  static const double _tabBarHeight = 72;
  static const double _iconSize = 24;

  static const TextStyle _tabLabelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthController>();
    if (!identical(auth, _auth)) {
      _auth?.removeListener(_onAuthChanged);
      _auth = auth;
      _auth!.addListener(_onAuthChanged);
      _syncFromAuth();
    }
  }

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() => _syncFromAuth();

  void _syncFromAuth() {
    final auth = _auth;
    if (auth == null || !mounted) return;
    final loading = auth.isLoading;
    final role = auth.user?.role;
    if (loading == _loading && role == _role) return;
    setState(() {
      _loading = loading;
      _role = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (roleUsesReceptionShell(_role)) {
      return const ReceptionShellScreen(key: ValueKey('shell_reception'));
    }
    if (roleUsesTransportShell(_role)) {
      return const TransportShellScreen(key: ValueKey('shell_transport'));
    }
    if (roleUsesExtractionShell(_role)) {
      return const ExtractionShellScreen(key: ValueKey('shell_extraction'));
    }
    if (roleUsesControleShell(_role)) {
      return const ControleShellScreen(key: ValueKey('shell_controle'));
    }

    return _buildWorkerShell(context);
  }

  Widget _buildWorkerShell(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barSurface = isDark ? AppColors.darkCard : AppColors.white;
    final barBorder = isDark ? AppColors.grayDark : AppColors.creamDark;

    return Scaffold(
      key: const ValueKey('shell_worker'),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: currentIndex,
        children: _workerPages,
      ),
      bottomNavigationBar: Material(
        elevation: 4,
        shadowColor: AppColors.black.withValues(alpha: 0.05),
        color: barSurface,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: barBorder, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: _tabBarHeight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Theme(
                  data: theme.copyWith(
                    splashColor: AppColors.primary.withValues(alpha: 0.08),
                    highlightColor: AppColors.primary.withValues(alpha: 0.05),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: currentIndex,
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: AppColors.gray,
                    selectedFontSize: 11,
                    unselectedFontSize: 11,
                    selectedLabelStyle: _tabLabelStyle,
                    unselectedLabelStyle: _tabLabelStyle,
                    iconSize: _iconSize,
                    onTap: (index) {
                      setState(() => currentIndex = index);
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.bar_chart_rounded, size: _iconSize),
                        label: 'Tableau',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.groups_rounded, size: _iconSize),
                        label: 'Travailleurs',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.qr_code_2_rounded, size: _iconSize),
                        label: 'Scan',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.monitor_heart_outlined, size: _iconSize),
                        label: 'Activités',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings_rounded, size: _iconSize),
                        label: 'Paramètres',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
