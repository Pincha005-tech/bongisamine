import 'package:flutter/material.dart';

import '../../coree/colors/app_colors.dart';
import '../../coree/theme/app_page_style.dart';

/// Aligné sur `expo/app/settings/analytics.tsx`
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _shareAnalytics = true;
  bool _crashReports = true;
  bool _performance = false;

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
              padding: EdgeInsets.fromLTRB(16, topPad + 24, 16, 16),
              child: Row(
                children: [
                  Material(
                    color: context.appCardColor,
                    elevation: 2,
                    shadowColor: AppColors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.maybePop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Analytiques',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
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
                    _ToggleRow(
                      label: 'Partager les analytiques',
                      description: "Aidez-nous à améliorer l'application",
                      value: _shareAnalytics,
                      onChanged: (v) => setState(() => _shareAnalytics = v),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.grayLight,
                    ),
                    _ToggleRow(
                      label: 'Rapports de crash',
                      description: 'Envoyer automatiquement les erreurs',
                      value: _crashReports,
                      onChanged: (v) => setState(() => _crashReports = v),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.grayLight,
                    ),
                    _ToggleRow(
                      label: 'Mesures de performance',
                      description: 'Collecter les métriques de vitesse',
                      value: _performance,
                      onChanged: (v) => setState(() => _performance = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.appCardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: const Border(
                    left: BorderSide(color: AppColors.skyBlue, width: 4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.insert_chart_outlined,
                      size: 18,
                      color: AppColors.skyBlueDark,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Les données sont anonymisées et utilisées uniquement à des fins "
                        "d'amélioration du produit.",
                        style: TextStyle(
                          fontSize: 13,
                          height: 20 / 13,
                          color: AppColors.grayDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
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
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return AppColors.grayLight;
            }),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.cream;
              }
              return AppColors.white;
            }),
          ),
        ],
      ),
    );
  }
}
