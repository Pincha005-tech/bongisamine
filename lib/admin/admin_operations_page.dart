import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';

/// Actions métier — raccourcis (écran dédié admin).
class AdminOperationsPage extends StatelessWidget {
  const AdminOperationsPage({super.key, required this.onNavigateTab});

  final void Function(int tabIndex) onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final items = <({String title, String subtitle, IconData icon, VoidCallback onTap})>[
      (
        title: 'Scanner QR sécurisé',
        subtitle: 'Pointage, lots, barrières',
        icon: Icons.document_scanner_outlined,
        onTap: () => onNavigateTab(2),
      ),
      (
        title: 'Tracer un mouvement de lot',
        subtitle: 'Changement de statut, lieu',
        icon: Icons.swap_horiz_rounded,
        onTap: () => _soon(context),
      ),
      (
        title: 'Check-in / Check-out',
        subtitle: 'Flux travailleurs',
        icon: Icons.fact_check_outlined,
        onTap: () => _soon(context),
      ),
      (
        title: 'Créer entrée d’historique',
        subtitle: 'Mineral history',
        icon: Icons.history_edu_outlined,
        onTap: () => _soon(context),
      ),
      (
        title: 'Ajouter worker',
        subtitle: 'RH & accès',
        icon: Icons.person_add_alt_1_outlined,
        onTap: () => _soon(context),
      ),
      (
        title: 'Ajouter minerai / lot',
        subtitle: 'Référentiel extraction',
        icon: Icons.landscape_outlined,
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
                'Opérations',
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
              child: Text(
                'Actions métier sans quitter le flux terrain. '
                'Les formulaires seront branchés sur l’API.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: context.appOnSurfaceMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final it = items[i];
                return Material(
                  color: context.appCardColor,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: it.onTap,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(it.icon, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: context.appOnSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  it.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.appOnSurfaceMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.gray),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulaire à venir — branchement API')),
    );
  }
}
