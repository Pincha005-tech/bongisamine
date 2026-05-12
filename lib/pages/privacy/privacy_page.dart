import 'package:flutter/material.dart';

import 'personal_info_page.dart';
import 'storage_page.dart';
import 'analytics_page.dart';
import 'securiti_page.dart';
import 'data_access_page.dart';
import 'delete_account_page.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Confidentialité",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.privacy_tip, color: primary),
                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Vos données sont sécurisées et utilisées uniquement pour le fonctionnement du système minier.",
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle(context, "Données personnelles"),

          _tile(
            context,
            Icons.person,
            "Gestion des informations personnelles",
            "Nom, email, rôle utilisateur",
            const DataAccessPage(),
          ),

          _tile(
            context,
            Icons.storage,
            "Stockage des données",
            "Données sauvegardées sur serveur sécurisé",
            const StoragePage(),
          ),

          const SizedBox(height: 20),

          _sectionTitle(context, "Utilisation des données"),

          _tile(
            context,
            Icons.analytics,
            "Analyse interne",
            "Utilisation pour rapports et statistiques",
            const AnalyticsPage(),
          ),

          _tile(
            context,
            Icons.security,
            "Sécurité",
            "Protection contre accès non autorisé",
            const SecurityPage(),
          ),

          const SizedBox(height: 20),

          _sectionTitle(context, "Vos droits"),

          _tile(
            context,
            Icons.visibility,
            "Accès à vos données",
            "Vous pouvez consulter vos informations",
            const DataAccessPage(),
          ),

          _tile(
            context,
            Icons.delete,
            "Suppression de compte",
            "Demande de suppression possible via admin",
            const DeleteAccountPage(),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Paramètres de confidentialité sauvegardés",
                    ),
                  ),
                );
              },
              child: const Text(
                "Enregistrer",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// TILE
  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
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

            Icon(icon, color: primary),

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

                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }
}