import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../services/api_service.dart';

/// Affiche le QR PNG depuis `GET /qrcodes/{id}/image`.
Future<void> showQrCodeImageDialog(
  BuildContext context, {
  required int qrId,
  required String batchCode,
  String? subtitle,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => QrCodeImageDialog(
      qrId: qrId,
      batchCode: batchCode,
      subtitle: subtitle,
    ),
  );
}

class QrCodeImageDialog extends StatefulWidget {
  const QrCodeImageDialog({
    super.key,
    required this.qrId,
    required this.batchCode,
    this.subtitle,
  });

  final int qrId;
  final String batchCode;
  final String? subtitle;

  @override
  State<QrCodeImageDialog> createState() => _QrCodeImageDialogState();
}

class _QrCodeImageDialogState extends State<QrCodeImageDialog> {
  List<int>? _bytes;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await ApiService.fetchQrImageBytes(widget.qrId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (bytes != null) {
        _bytes = bytes;
        _error = null;
      } else {
        _bytes = null;
        _error =
            'Image QR indisponible (fichier absent sur le serveur ou accès refusé).';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final batch = widget.batchCode.trim();

    return AlertDialog(
      title: const Text('QR code du lot'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (batch.isNotEmpty)
              Text(
                batch,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_bytes != null)
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.memory(
                    Uint8List.fromList(_bytes!),
                    width: 260,
                    height: 260,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'Impossible d\'afficher l\'image',
                    ),
                  ),
                ),
              )
            else
              Text(
                _error ?? 'Erreur',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
          ],
        ),
      ),
      actions: [
        if (!_loading && _bytes == null)
          TextButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _load();
            },
            child: const Text('Réessayer'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
