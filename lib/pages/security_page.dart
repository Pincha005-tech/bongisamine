import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Screens/login_screen.dart';
import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';
import '../coree/theme/theme_notifier.dart';
import '../coree/api/api_config.dart';
import '../services/api_service.dart';
import 'changepass_page.dart';
import 'privacy/privacy_page.dart';

/// Équivalent Expo `app/(tabs)/settings.tsx` (onglet Paramètres).
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  final _apiUrlController = TextEditingController();

  String _name = 'Utilisateur';
  String _email = '';
  String _role = 'WORKER';

  bool get _darkMode => AppThemeController.isDarkModeEnabled;

  @override
  void initState() {
    super.initState();
    _apiUrlController.text = ApiConfig.baseUrl;
    appThemeModeNotifier.addListener(_onThemeChanged);
    unawaited(_loadProfile());
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    appThemeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _saveApiUrl() async {
    await ApiConfig.setBaseUrl(_apiUrlController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('API : ${ApiConfig.baseUrl}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthController>();
    if (auth.user != null) {
      setState(() {
        _name = auth.name;
        _email = auth.email;
        _role = auth.apiRole.isNotEmpty ? auth.apiRole : auth.role.toUpperCase();
      });
      return;
    }
    final profile = await ApiService.getUserProfile();
    if (!mounted) return;
    setState(() {
      _name = (profile['name'] as String?)?.trim().isNotEmpty == true
          ? profile['name'] as String
          : 'Utilisateur';
      _email = (profile['email'] as String?) ?? '';
      final r = profile['role'] as String?;
      _role = (r != null && r.isNotEmpty) ? r.toUpperCase() : 'WORKER';
    });
  }

  Future<void> _confirmLogout() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
    if (go != true) return;
    if (!mounted) return;
    final auth = context.read<AuthController>();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
              child: Text(
                'Paramètres',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.appTitleAccent,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildProfileCard()),
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'Compte',
              child: _buildCard(
                children: [
                  _SettingItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profil',
                    onTap: () {},
                  ),
                  _SettingItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Changer le mot de passe',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage(),
                      ),
                    ),
                  ),
                  _SettingItem(
                    icon: Icons.shield_outlined,
                    label: 'Confidentialité',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'Système',
              child: _buildCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'URL de l\'API',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _apiUrlController,
                          decoration: const InputDecoration(
                            hintText: 'https://bongisa-mine-api.onrender.com',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.url,
                          autocorrect: false,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _saveApiUrl,
                              child: const Text('Enregistrer'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await ApiConfig.resetBaseUrlToProduction();
                                _apiUrlController.text = ApiConfig.baseUrl;
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('URL Render par défaut'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Render'),
                            ),
                          ],
                        ),
                        Text(
                          'Doit être la même API que le centre de contrôle web.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SettingItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Mode sombre',
                    hasSwitch: true,
                    switchValue: _darkMode,
                    onSwitch: (v) {
                      unawaited(AppThemeController.setDarkMode(v));
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'Interface',
              child: _buildCard(
                children: [
                  _SettingItem(
                    icon: Icons.shield_outlined,
                    label: 'Notifications',
                    hasSwitch: true,
                    switchValue: _notifications,
                    onSwitch: (v) => setState(() => _notifications = v),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildLogoutButton()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final cardColor = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Material(
        color: cardColor,
        elevation: 3,
        shadowColor: AppColors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.engineering_rounded,
                  size: 32,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _email.isEmpty ? '—' : _email,
                      style: TextStyle(
                        fontSize: 13,
                        color: onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _role,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1,
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
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.gray,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Theme.of(context).cardColor,
        elevation: 2,
        shadowColor: AppColors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, thickness: 1, color: AppColors.grayLight),
              children[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: Theme.of(context).cardColor,
        elevation: 2,
        shadowColor: AppColors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _confirmLogout,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                SizedBox(width: 10),
                Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.hasSwitch = false,
    this.switchValue = false,
    this.onSwitch,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool hasSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitch;

  @override
  Widget build(BuildContext context) {
    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasSwitch ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasSwitch)
                Switch(
                  value: switchValue,
                  onChanged: onSwitch,
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
                )
              else
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

    return row;
  }
}
