import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/utils/keyboard_utils.dart';
import 'extraction_alerts_page.dart';
import 'extraction_home_page.dart';
import 'extraction_minerals_page.dart';
import 'extraction_profile_page.dart';
import 'extraction_scan_page.dart';

/// Navigation superviseur extraction — 5 onglets.
class ExtractionShellScreen extends StatefulWidget {
  const ExtractionShellScreen({super.key});

  @override
  State<ExtractionShellScreen> createState() => _ExtractionShellScreenState();
}

class _ExtractionShellScreenState extends State<ExtractionShellScreen>
    with WidgetsBindingObserver {
  int _index = 0;
  final _scanKey = GlobalKey<ExtractionScanPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ExtractionHomePage(
        key: const PageStorageKey<String>('extraction_home'),
        onNavigateTab: _goTab,
      ),
      ExtractionScanPage(
        key: _scanKey,
        onNavigateTab: _goTab,
      ),
      ExtractionMineralsPage(
        key: const PageStorageKey<String>('extraction_minerals'),
        onNavigateTab: _goTab,
        onOpenScanWithBatch: _openScanWithBatch,
      ),
      const ExtractionAlertsPage(
        key: PageStorageKey<String>('extraction_alerts'),
      ),
      const ExtractionProfilePage(
        key: PageStorageKey<String>('extraction_profile'),
      ),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    KeyboardUtils.dismiss();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      KeyboardUtils.dismiss();
    }
  }

  void _selectTab(int i) {
    if (i < 0 || i > 4) return;
    if (_index == i) return;
    KeyboardUtils.dismiss();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _index = i);
    });
  }

  void _goTab(int i) => _selectTab(i);

  void _openScanWithBatch(String batch) {
    final code = batch.trim();
    KeyboardUtils.dismiss();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _index = 1);
      if (code.isNotEmpty) {
        _scanKey.currentState?.applyBatchPrefill(code);
      }
    });
  }

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
                    onTap: _selectTab,
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
                        icon: Icon(Icons.diamond_outlined, size: _iconSize),
                        label: 'Minerais',
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
