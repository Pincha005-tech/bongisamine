import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../pages/scan_page.dart';
import '../pages/security_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_data_hub_page.dart';
import 'admin_operations_page.dart';
import 'admin_security_hub_page.dart';

/// Navigation principale — rôle administrateur (6 onglets).
class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _index = 0;

  void _goTab(int i) {
    if (i < 0 || i > 5) return;
    setState(() => _index = i);
  }

  late final List<Widget> _pages = [
    AdminDashboardPage(onNavigateTab: _goTab),
    AdminOperationsPage(onNavigateTab: _goTab),
    const ScanPage(),
    AdminDataHubPage(onNavigateTab: _goTab),
    AdminSecurityHubPage(onNavigateTab: _goTab),
    const SettingsPage(),
  ];

  static const double _tabBarHeight = 72;
  static const double _iconSize = 22;

  static const TextStyle _tabLabelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.05,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barSurface = isDark ? AppColors.darkCard : AppColors.white;
    final barBorder = isDark ? AppColors.grayDark : AppColors.creamDark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _index,
        children: _pages,
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
                padding: const EdgeInsets.only(top: 6, bottom: 6),
                child: Theme(
                  data: theme.copyWith(
                    splashColor: AppColors.primary.withValues(alpha: 0.08),
                    highlightColor: AppColors.primary.withValues(alpha: 0.05),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _index,
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: AppColors.gray,
                    selectedFontSize: 10,
                    unselectedFontSize: 10,
                    selectedLabelStyle: _tabLabelStyle,
                    unselectedLabelStyle: _tabLabelStyle,
                    iconSize: _iconSize,
                    onTap: (i) => setState(() => _index = i),
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_customize_outlined, size: _iconSize),
                        label: 'Dashboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.precision_manufacturing_outlined, size: _iconSize),
                        label: 'Opérations',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.qr_code_scanner_rounded, size: _iconSize),
                        label: 'Scan',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.table_chart_outlined, size: _iconSize),
                        label: 'Données',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.security_rounded, size: _iconSize),
                        label: 'Sécurité',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline_rounded, size: _iconSize),
                        label: 'Profil',
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
