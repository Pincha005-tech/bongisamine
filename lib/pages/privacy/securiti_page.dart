import 'package:flutter/material.dart';
import '../../coree/theme/app_themes.dart';
import '../../coree/colors/app_colors.dart';


class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: AppColors.skyBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Sécurité", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.lock, color: AppColors.skyBlue),
              title: Text(
                "Connexion sécurisée",
                style: TextStyle(color: AppColors.text),
              ),
              subtitle: Text(
                "Communication chiffrée avec le backend FastAPI.",
                style: TextStyle(color: AppColors.grey),
              ),
            ),

            ListTile(
              leading: Icon(Icons.verified_user, color: AppColors.skyBlue),
              title: Text(
                "Authentification",
                style: TextStyle(color: AppColors.text),
              ),
              subtitle: Text(
                "Protection des accès administrateurs.",
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
