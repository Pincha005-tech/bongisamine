import 'package:flutter/material.dart';

import '../pages/dashboard_page.dart';
import '../pages/workers_page.dart';
import '../pages/scan_page.dart';
import '../pages/activities_page.dart';
import '../pages/security_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    WorkersPage(),
    ScanPage(),
    ActivitiesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      /// 📌 PAGE ACTIVE
      body: pages[currentIndex],

      /// 📌 NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        /// 🔥 IMPORTANT : adapte automatiquement au thème
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.unselectedWidgetColor,

        backgroundColor: theme.scaffoldBackgroundColor,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Workers",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Activities",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: "Security",
          ),
        ],
      ),
    );
  }
}