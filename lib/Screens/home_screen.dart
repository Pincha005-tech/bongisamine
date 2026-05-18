import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../coree/auth/app_roles.dart';
import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../pages/activities_page.dart';
import '../pages/attendance_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/scan_page.dart';
import '../pages/security_page.dart';
import '../pages/workers_page.dart';

/// Shell principal : navigation adaptée au persona (agent / superviseur).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  static const double _tabBarHeight = 72;
  static const double _iconSize = 24;

  static const TextStyle _tabLabelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.1,
  );

  List<Widget> _pagesFor(String persona) {
    if (persona == AppRoles.agent) {
      return const [
        DashboardPage(),
        WorkersPage(),
        ScanPage(),
        AttendancePage(),
        SettingsPage(),
      ];
    }
    return const [
      DashboardPage(),
      WorkersPage(),
      ScanPage(),
      ActivitiesPage(),
      SettingsPage(),
    ];
  }

  List<BottomNavigationBarItem> _itemsFor(String persona) {
    if (persona == AppRoles.agent) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded, size: _iconSize),
          label: 'Tableau',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_rounded, size: _iconSize),
          label: 'Ouvriers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.face_retouching_natural_rounded, size: _iconSize),
          label: 'Visage',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check_rounded, size: _iconSize),
          label: 'Présences',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded, size: _iconSize),
          label: 'Paramètres',
        ),
      ];
    }
    return const [
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final persona = auth.role;
    final pages = _pagesFor(persona);
    final items = _itemsFor(persona);

    if (currentIndex >= pages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => currentIndex = 0);
      });
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barSurface = isDark ? AppColors.darkCard : AppColors.white;
    final barBorder = isDark ? AppColors.grayDark : AppColors.creamDark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: pages[currentIndex.clamp(0, pages.length - 1)],
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
                    currentIndex: currentIndex.clamp(0, items.length - 1),
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
                    onTap: (index) => setState(() => currentIndex = index),
                    items: items,
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
