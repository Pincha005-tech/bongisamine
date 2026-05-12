import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import '../coree/theme/theme_notifier.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.brightness_6),
      label: const Text("Changer thème"),
      onPressed: () {
        AppThemeController.toggleTheme();
      },
    );
  }
}

class AppColors {
  static const skyBlue = Color(0xFF4DA6FF);
  static const bg = Colors.white;
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isQRMode = true;

  String result = "";
  bool showResult = false;
  bool isProcessing = false;

  void _setResult(String value) {
    setState(() {
      result = value;
      showResult = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showResult = false;
        });
      }
    });
  }

  /// 🔥 API CALL
  Future<void> sendToBackend(String mineralId) async {
    final url = Uri.parse(
        "http://192.168.X.X:8000/transactions/scan/$mineralId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _setResult(
            "💎 ${data['mineral']}\n✔ Transaction ID: ${data['transaction_id']}");
      } else {
        _setResult("❌ Mineral invalide");
      }
    } catch (e) {
      _setResult("❌ Erreur connexion");
    } finally {
      isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Scan Sécurité",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          /// MODE SWITCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _modeButton("QR Code", isQRMode, () {
                  setState(() => isQRMode = true);
                }),
                const SizedBox(width: 10),
                _modeButton("Visage", !isQRMode, () {
                  setState(() => isQRMode = false);
                }),
              ],
            ),
          ),

          /// SCANNER
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              child: isQRMode ? _qrScanner() : _faceScanner(),
            ),
          ),

          /// RESULT
          if (showResult)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _modeButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.skyBlue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 🔥 QR SCANNER CONNECTÉ
  Widget _qrScanner() {
    return MobileScanner(
      onDetect: (capture) {
        final barcode = capture.barcodes.first.rawValue;

        if (barcode != null && !isProcessing) {
          isProcessing = true;
          sendToBackend(barcode);
        }
      },
    );
  }

  Widget _faceScanner() {
    return const Center(child: Text("Face scan bientôt dispo"));
  }
}