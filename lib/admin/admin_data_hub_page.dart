import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../pages/workers_page.dart';

/// Hub données : workers, minerals, etc. (navigation vers écrans existants ou placeholders).
class AdminDataHubPage extends StatelessWidget {
  const AdminDataHubPage({super.key, required this.onNavigateTab});

  final void Function(int tabIndex) onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    final tiles = <({String title, String subtitle, IconData icon, VoidCallback onTap})>[
      (
        title: 'Travailleurs',
        subtitle: 'Liste, filtres, statuts',
        icon: Icons.groups_rounded,
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (_) => const WorkersPage()),
          );
        },
      ),
      (
        title: 'Minerais & lots',
        subtitle: 'Statuts, poids, blocages',
        icon: Icons.inventory_2_outlined,
        onTap: () => _soon(context),
      ),
      (
        title: 'Utilisateurs & rôles',
        subtitle: 'Admin, superviseur, agent…',
        icon: Icons.manage_accounts_outlined,
        onTap: () => _soon(context),
      ),
      (
        title: 'QR codes',
        subtitle: 'Génération, vérification',
        icon: Icons.qr_code_2_rounded,
        onTap: () => onNavigateTab(2),
      ),
      (
        title: 'Transactions',
        subtitle: 'Journal du jour',
        icon: Icons.receipt_long_outlined,
        onTap: () => _soon(context),
      ),
      (
        title: 'Historiques',
        subtitle: 'Mouvements, audits',
        icon: Icons.timeline_outlined,
        onTap: () => _soon(context),
      ),
      (
        title: 'Présences',
        subtitle: 'Attendances, retards',
        icon: Icons.event_available_outlined,
        onTap: () => _soon(context),
      ),
    ];

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, top + 24, 20, 8),
              child: Text(
                'Données',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.appTitleAccent,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final t = tiles[i];
                  return Material(
                    color: context.appCardColor,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: t.onTap,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(t.icon, size: 28, color: AppColors.primary),
                            const Spacer(),
                            Text(
                              t.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: context.appOnSurface,
                              ),
                            ),
                            Text(
                              t.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appOnSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: tiles.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Écran données — à brancher sur l’API')),
    );
  }
}
