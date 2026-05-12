import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:crypto/crypto.dart';
import 'qr_result_page.dart';

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

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  bool isScanned = false;

  String generateSignature(String id) {
    const secret = "BONGISA_SECRET_KEY";
    return sha256.convert(utf8.encode(id + secret)).toString();
  }

  void handleScan(String raw) {
    if (isScanned) return;

    try {
      final data = jsonDecode(raw);

      String id = data["id"];
      String sig = data["sig"];

      // 🔐 Vérification sécurité
      if (sig != generateSignature(id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR Code invalide ❌")),
        );
        return;
      }

      isScanned = true;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QRResultPage(sacId: id),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lecture QR ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner QR"),
        backgroundColor: Colors.lightBlue,
      ),
     body: MobileScanner(
      onDetect: (capture) {
        final barcode = capture.barcodes.first;
        final String? raw = barcode.rawValue;

        if (raw != null) {
          handleScan(raw);
       }
      },
    ),
    );
  }
}