import 'package:flutter/material.dart';
import '../../coree/theme/app_themes.dart';
import '../../coree/colors/app_colors.dart';

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Stockage des données"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ListTile(
              leading: Icon(Icons.storage),
              title: Text("Serveur sécurisé"),
              subtitle: Text(
                "Les données sont sauvegardées via FastAPI + PostgreSQL.",
              ),
            ),
            ListTile(
              leading: Icon(Icons.cloud_done),
              title: Text("Synchronisation cloud"),
              subtitle: Text(
                "Les informations sont synchronisées automatiquement.",
              ),
            ),
          ],
        ),
      ),
    );
  }
}