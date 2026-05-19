import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Screens/login_screen.dart';
import '../coree/auth/auth_builder.dart';
import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/theme/theme_notifier.dart';
import 'transport_models.dart';
import '../extraction/extraction_models.dart';
import '../reception/reception_models.dart';
import 'transport_role.dart';

/// Profil superviseur transport + workflow métier.
class TransportProfilePage extends StatefulWidget {
  const TransportProfilePage({super.key});

  @override
  State<TransportProfilePage> createState() => _TransportProfilePageState();
}

class _TransportProfilePageState extends State<TransportProfilePage> {
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
        content: const Text('Quitter la session transport ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Déconnecter'),
          ),
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
    return AuthBuilder(
      builder: (context, auth) {
        final top = MediaQuery.paddingOf(context).top;
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
                        child: Icon(Icons.local_shipping_outlined, color: AppColors.cream, size: 28),
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
                              style: TextStyle(
                                fontSize: 13,
                                color: context.appOnSurfaceMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                transportRoleBadge(auth.user?.role ?? kRoleSupervisorTransport),
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
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Mode sombre'),
                      value: _dark,
                      onChanged: (v) => unawaited(AppThemeController.setDarkMode(v)),
                    ),
                  ],
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
                      _workflowStep('1', 'Extraction', ExtractionWorkflow.transitionLabel),
                      _workflowStep(
                        '2',
                        'Transport (vous)',
                        TransportWorkflow.transitionLabel,
                        highlight: true,
                      ),
                      _workflowStep('3', 'Réception', ReceptionWorkflow.transitionLabel),
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
      },
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
