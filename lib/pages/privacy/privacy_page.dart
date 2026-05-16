import 'dart:async';

import 'package:flutter/material.dart';

import '../../coree/colors/app_colors.dart';
import '../../coree/theme/app_page_style.dart';
import 'analytics_page.dart';
import 'data_access_page.dart';
import 'delete_account_page.dart';
import 'securiti_page.dart';
import 'storage_page.dart';

/// Aligné sur `expo/app/settings/privacy.tsx`
class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _saved = false;

  void _handleSave() {
    setState(() => _saved = true);
    unawaited(Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    }));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

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
                    'Confidentialité',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: context.appTitleAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gérez vos données et votre sécurité',
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: context.appCardColor,
                elevation: 2,
                shadowColor: AppColors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    _PrivacyTile(
                      icon: Icons.dataset_linked_outlined,
                      label: 'Données personnelles',
                      description: 'Consultez vos informations',
                      danger: false,
                      onTap: () => _open(context, const DataAccessPage()),
                    ),
                    const _TileDivider(),
                    _PrivacyTile(
                      icon: Icons.storage_rounded,
                      label: 'Stockage',
                      description: "Gérez l'espace utilisé",
                      danger: false,
                      onTap: () => _open(context, const StoragePage()),
                    ),
                    const _TileDivider(),
                    _PrivacyTile(
                      icon: Icons.insert_chart_outlined,
                      label: 'Analytiques',
                      description: "Statistiques d'utilisation",
                      danger: false,
                      onTap: () => _open(context, const AnalyticsPage()),
                    ),
                    const _TileDivider(),
                    _PrivacyTile(
                      icon: Icons.shield_outlined,
                      label: 'Sécurité',
                      description: 'Options de sécurité avancées',
                      danger: false,
                      onTap: () => _open(context, const SecurityPage()),
                    ),
                    const _TileDivider(),
                    _PrivacyTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Vos droits',
                      description: 'RGPD et accès aux données',
                      danger: false,
                      onTap: () => _open(context, const DataAccessPage()),
                    ),
                    const _TileDivider(),
                    _PrivacyTile(
                      icon: Icons.delete_outline_rounded,
                      label: 'Supprimer le compte',
                      description: 'Action irréversible',
                      danger: true,
                      onTap: () => _open(context, const DeleteAccountPage()),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: SizedBox(
                height: 54,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _handleSave,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Text(
                        _saved ? 'Enregistré!' : 'Enregistrer',
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: context.appDividerOnPage,
    );
  }
}

class _PrivacyTile extends StatelessWidget {
  const _PrivacyTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final iconBg = danger
        ? (context.isAppDark
            ? AppColors.error.withValues(alpha: 0.2)
            : const Color(0xFFFEE2E2))
        : context.appIconTileBg;
    final iconColor =
        danger ? AppColors.error : context.appTitleAccent;
    final labelColor =
        danger ? AppColors.error : context.appOnSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
