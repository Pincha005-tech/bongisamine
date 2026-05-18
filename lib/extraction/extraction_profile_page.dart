import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Screens/login_screen.dart';
import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/theme/theme_notifier.dart';
import 'extraction_mock_data.dart';
import 'extraction_role.dart';

class ExtractionProfilePage extends StatefulWidget {
  const ExtractionProfilePage({super.key});

  @override
  State<ExtractionProfilePage> createState() => _ExtractionProfilePageState();
}

class _ExtractionProfilePageState extends State<ExtractionProfilePage> {
  bool _dark = AppThemeController.isDarkModeEnabled;

  @override
  void initState() {
    super.initState();
    appThemeModeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    appThemeModeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() {
    if (mounted) setState(() => _dark = AppThemeController.isDarkModeEnabled);
  }

  Future<void> _logout() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Quitter la session extraction ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Déconnecter')),
        ],
      ),
    );
    if (go != true || !mounted) return;
    await context.read<AuthController>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final auth = context.watch<AuthController>();

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, top + 24, 20, 16),
              child: Text(
                'Profil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.appTitleAccent,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: context.appCardColor,
                elevation: 3,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.construction_outlined, color: AppColors.cream, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: context.appOnSurface,
                              ),
                            ),
                            Text(
                              auth.email,
                              style: TextStyle(fontSize: 13, color: context.appOnSurfaceMuted),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                extractionRoleBadge(auth.user?.role ?? kRoleSupervisorExtraction),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Material(
                color: context.appCardColor,
                borderRadius: BorderRadius.circular(16),
                child: SwitchListTile(
                  title: const Text('Mode sombre'),
                  value: _dark,
                  onChanged: (v) => unawaited(AppThemeController.setDarkMode(v)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Material(
                color: context.appCardColor,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workflow (GET /traceability/workflow)',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: context.appOnSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _workflowStep(
                        '1',
                        'Extraction (vous)',
                        ExtractionMockData.transitionExtraction,
                        highlight: true,
                      ),
                      _workflowStep('2', 'Transport', 'STORED → IN_TRANSPORT'),
                      _workflowStep('3', 'Réception', 'IN_TRANSPORT → DEPOT_RECEIVED'),
                      const SizedBox(height: 12),
                      Text(
                        'Responsabilités : minerais, QR, scan stockage.',
                        style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Compte démo : extraction@mine.com / 1234',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appOnSurfaceMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workflowStep(String n, String title, String transition, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: highlight ? AppColors.primary : AppColors.cream,
            child: Text(
              n,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: highlight ? AppColors.cream : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(transition, style: const TextStyle(fontSize: 12, color: AppColors.grayDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
