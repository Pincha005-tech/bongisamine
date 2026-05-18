import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();

  @override
  void dispose() {
    oldCtrl.dispose();
    newCtrl.dispose();
    super.dispose();
  }

  void changePassword() async {
    await ApiService.changePassword(oldCtrl.text, newCtrl.text);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Mot de passe changé")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Sécurité")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Ancien mot de passe",
              ),
            ),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nouveau mot de passe",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: changePassword,
              child: const Text("Changer"),
            ),
          ],
        ),
      ),
    );
  }
}
