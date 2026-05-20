import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import 'transport_alerts_page.dart';
import 'transport_home_page.dart';
import 'transport_lots_page.dart';
import 'transport_profile_page.dart';
import 'transport_scan_page.dart';

/// Navigation superviseur transport — 5 onglets (scan-first).
class TransportShellScreen extends StatefulWidget {
  const TransportShellScreen({super.key});

  @override
  State<TransportShellScreen> createState() => _TransportShellScreenState();
}

class _TransportShellScreenState extends State<TransportShellScreen> {
  int _index = 0;

  void _goTab(int i) {
    if (i < 0 || i > 4) return;
    setState(() => _index = i);
  }

  late final List<Widget> _pages = [
    TransportHomePage(onNavigateTab: _goTab),
    TransportScanPage(onNavigateTab: _goTab),
    const TransportLotsPage(),
    const TransportAlertsPage(),
    const TransportProfilePage(),
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
                        icon: Icon(Icons.home_outlined, size: _iconSize),
                        label: 'Accueil',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.qr_code_scanner_rounded, size: _iconSize),
                        label: 'Scan',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.inventory_2_outlined, size: _iconSize),
                        label: 'Lots',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.warning_amber_rounded, size: _iconSize),
                        label: 'Alertes',
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
