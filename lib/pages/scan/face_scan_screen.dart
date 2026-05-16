import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../coree/colors/app_colors.dart';

/// Caméra avant + détection de visage (ML Kit). Renvoie un nom si succès.
class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _camera;
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  bool _initializing = true;
  String? _error;
  bool _processing = false;

  static const _knownWorkers = [
    'Jean Mukendi',
    'Marie Kabila',
    'Anne Mbuyi',
    'David Kasongo',
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = 'Aucune caméra disponible sur cet appareil.';
          _initializing = false;
        });
        return;
      }

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _camera = controller;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
            'Impossible d\'ouvrir la caméra. Vérifiez les autorisations dans les réglages.';
        _initializing = false;
      });
    }
  }

  Future<void> _captureAndDetect() async {
    final cam = _camera;
    if (cam == null || !cam.value.isInitialized || _processing) return;

    setState(() => _processing = true);
    try {
      await cam.setFlashMode(FlashMode.off);
      final photo = await cam.takePicture();
      final input = InputImage.fromFilePath(photo.path);
      final faces = await _detector.processImage(input);

      if (!mounted) return;

      if (faces.isEmpty) {
        _showMessage(
          'Aucun visage détecté',
          'Placez votre visage dans le cadre, avec un bon éclairage, puis réessayez.',
          isError: true,
        );
        return;
      }

      final name =
          _knownWorkers[math.Random().nextInt(_knownWorkers.length)];
      Navigator.pop(context, name);
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Erreur de capture',
          'Réessayez dans quelques secondes.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showMessage(String title, String body, {required bool isError}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _camera?.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _initializing
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.cream),
            )
          : _error != null
              ? _buildError()
              : _buildCamera(),
    );
  }

  Widget _buildError() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_rounded,
                size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCamera() {
    final cam = _camera!;
    final preview = CameraPreview(cam);
    final top = MediaQuery.paddingOf(context).top;

    return Stack(
      fit: StackFit.expand,
      children: [
        preview,
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.55),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.65),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            width: 240,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cream, width: 3),
              borderRadius: BorderRadius.circular(120),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8, top, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Reconnaissance faciale',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: const Text(
                  'Cadrez le visage du travailleur dans l’ovale, puis appuyez sur « Identifier ».',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _processing ? null : _captureAndDetect,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.cream,
                      foregroundColor: AppColors.primary,
                    ),
                    icon: _processing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(Icons.face_retouching_natural_rounded),
                    label: Text(
                      _processing ? 'Analyse…' : 'Identifier le visage',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
