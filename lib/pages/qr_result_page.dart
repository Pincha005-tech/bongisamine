import 'package:flutter/material.dart';

import '../coree/theme/theme_notifier.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.brightness_6),
      label: const Text("Changer thème"),
      onPressed: () => AppThemeController.toggleTheme(),
    );
  }
}

class QRResultPage extends StatefulWidget {
  final String sacId;

  const QRResultPage({super.key, required this.sacId});

  @override
  State<QRResultPage> createState() => _QRResultPageState();
}

class _QRResultPageState extends State<QRResultPage> {
  final TextEditingController mineraiController = TextEditingController();
  final TextEditingController poidsController = TextEditingController();

  bool alreadyExists = false;

  // 🔥 SIMULATION BASE DE DONNÉES
  static List<Map<String, dynamic>> database = [];

  Map<String, dynamic>? existingData;

  @override
  void initState() {
    super.initState();

    // 🔍 vérifier si existe déjà
    for (var item in database) {
      if (item["id"] == widget.sacId) {
        alreadyExists = true;
        existingData = item;
        break;
      }
    }
  }

  void saveData() {
    final minerai = mineraiController.text;
    final poids = double.tryParse(poidsController.text) ?? 0;

    database.add({
      "id": widget.sacId,
      "minerai": minerai,
      "poids": poids,
      "date": DateTime.now(),
    });

    // 🔥 ICI TU METTRAS TON DASHBOARD UPDATE
    globalProduction += poids;

    Navigator.pop(context);
  }

  double globalProduction = 0; // tu vas connecter ça au dashboard après

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du sac"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: alreadyExists
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ID: ${widget.sacId}"),
                  const SizedBox(height: 10),
                  Text("Minerai: ${existingData!["minerai"]}"),
                  Text("Poids: ${existingData!["poids"]} kg"),
                ],
              )
            : Column(
                children: [
                  TextFormField(
                    initialValue: widget.sacId,
                    enabled: false,
                    decoration: const InputDecoration(labelText: "ID"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: mineraiController,
                    decoration: const InputDecoration(labelText: "Minerai"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: poidsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Poids (kg)"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveData,
                    child: const Text("Valider"),
                  )
                ],
              ),
      ),
    );
  }
}