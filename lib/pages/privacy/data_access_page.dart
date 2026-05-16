import 'dart:async';

import 'package:flutter/material.dart';

import '../../coree/colors/app_colors.dart';
import '../../coree/theme/app_page_style.dart';
import '../../services/api_service.Dart';

/// Aligné sur `expo/app/settings/...` (écran données personnelles type `DataAccessPage` Expo).
class DataAccessPage extends StatefulWidget {
  const DataAccessPage({super.key});

  @override
  State<DataAccessPage> createState() => _DataAccessPageState();
}

class _DataAccessPageState extends State<DataAccessPage> {
  String _name = '—';
  String _email = '—';
  String _company = 'Non renseigné';
  String _role = '—';

  @override
  void initState() {
    super.initState();
    unawaited(_loadUser());
  }

  Future<void> _loadUser() async {
    final profile = await ApiService.getUserProfile();
    if (!mounted) return;
    setState(() {
      final n = profile['name'] as String?;
      _name = (n != null && n.trim().isNotEmpty) ? n : '—';

      final e = profile['email'] as String?;
      _email = (e != null && e.trim().isNotEmpty) ? e : '—';

      final c = profile['company'] as String?;
      _company = (c != null && c.trim().isNotEmpty) ? c : 'Non renseigné';

      final r = profile['role'] as String?;
      _role = (r != null && r.trim().isNotEmpty) ? r.toUpperCase() : '—';
    });
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
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 24,
                          color: context.appTitleAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Données personnelles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.appTitleAccent,
                      ),
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
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Nom',
                      value: _name,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: context.appDividerOnPage,
                    ),
                    _InfoRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: _email,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: context.appDividerOnPage,
                    ),
                    _InfoRow(
                      icon: Icons.description_outlined,
                      label: 'Entreprise',
                      value: _company,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: context.appDividerOnPage,
                    ),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Rôle',
                      value: _role,
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
                child: const Text(
                  'Vos données sont stockées de manière sécurisée. Vous pouvez demander '
                  'leur suppression à tout moment.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 20 / 13,
                    color: AppColors.grayDark,
                    fontWeight: FontWeight.w500,
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appOnSurfaceMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.appOnSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
