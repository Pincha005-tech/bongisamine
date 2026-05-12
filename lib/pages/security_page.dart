import 'package:flutter/material.dart';
import '../Screens/login_screen.dart';
import 'changepass_page.dart';
import 'privacy/privacy_page.dart';
import '../coree/theme/theme_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool syncData = true;
  bool autoBackup = false;

  bool get darkMode =>
      appThemeModeNotifier.value == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        title: const Text(
          "Sécurité",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// =====================
          /// COMPTE
          /// =====================
          _sectionTitle(context, "Compte"),

          _tile(
            context,
            icon: Icons.lock,
            title: "Changer mot de passe",
            page: const ChangePasswordPage(),
          ),

          _tile(
            context,
            icon: Icons.privacy_tip,
            title: "Confidentialité",
            page: const PrivacyPage(),
          ),

          const SizedBox(height: 20),

          /// =====================
          /// SYSTÈME
          /// =====================
          _sectionTitle(context, "Système"),

          _switchTile(
            context,
            icon: Icons.notifications,
            title: "Notifications",
            subtitle: "Recevoir les alertes du système",
            value: notifications,
            onChanged: (val) => setState(() => notifications = val),
          ),

          _switchTile(
            context,
            icon: Icons.sync,
            title: "Synchronisation des données",
            subtitle: "Sync en temps réel avec le serveur",
            value: syncData,
            onChanged: (val) => setState(() => syncData = val),
          ),

          _switchTile(
            context,
            icon: Icons.cloud_upload,
            title: "Backup automatique",
            subtitle: "Sauvegarde automatique des données",
            value: autoBackup,
            onChanged: (val) => setState(() => autoBackup = val),
          ),

          const SizedBox(height: 20),

          /// =====================
          /// INTERFACE
          /// =====================
          _sectionTitle(context, "Interface"),

          _switchTile(
            context,
            icon: Icons.dark_mode,
            title: "Mode sombre",
            subtitle: "Activer le thème sombre",
            value: darkMode,
            onChanged: (val) {
              appThemeModeNotifier.value =
                  val ? ThemeMode.dark : ThemeMode.light;

              setState(() {});
            },
          ),

          const SizedBox(height: 30),

          /// =====================
          /// LOGOUT
          /// =====================
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Déconnexion",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// =====================
  /// SECTION TITLE
  /// =====================
  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  /// =====================
  /// NAV TILE
  /// =====================
  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  /// =====================
  /// SWITCH TILE
  /// =====================
  Widget _switchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),

          Switch(
            value: value,
            activeColor: theme.colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
   }
}