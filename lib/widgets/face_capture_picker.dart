import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/face/face_capture_result.dart';
import '../coree/theme/app_page_style.dart';
import '../pages/scan/face_scan_screen.dart';

/// Déclenche la caméra pour la reconnaissance faciale (remplace le switch mock).
class FaceCapturePicker extends StatefulWidget {
  const FaceCapturePicker({
    super.key,
    required this.matched,
    required this.onCapture,
    this.workerName,
    this.imagePath,
    this.sectionTitle = '2. Reconnaissance faciale',
    this.knownWorkerNames,
  });

  final bool matched;
  final String? workerName;
  final String? imagePath;
  final void Function(bool matched, {String? workerName, String? imagePath})
      onCapture;
  final String sectionTitle;
  final List<String>? knownWorkerNames;

  @override
  State<FaceCapturePicker> createState() => _FaceCapturePickerState();
}

class _FaceCapturePickerState extends State<FaceCapturePicker> {
  bool _opening = false;

  Future<void> _openCamera() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final result = await Navigator.push<FaceCaptureResult>(
        context,
        MaterialPageRoute(
          builder: (_) => FaceScanScreen(
            knownWorkerNames: widget.knownWorkerNames,
          ),
          fullscreenDialog: true,
        ),
      );
      if (!mounted || result == null) return;
      widget.onCapture(
        result.matched,
        workerName: result.workerName,
        imagePath: result.imagePath,
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.sectionTitle,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: context.appOnSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: _opening ? null : _openCamera,
            icon: _opening
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.face_retouching_natural_rounded),
            label: Text(
              _opening
                  ? 'Ouverture caméra…'
                  : widget.matched
                      ? 'Rescanner le visage'
                      : 'Capturer le visage',
            ),
          ),
        ),
        if (widget.matched) ...[
          const SizedBox(height: 10),
          Material(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Visage reconnu',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                        if (widget.workerName != null)
                          Text(
                            widget.workerName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.appOnSurfaceMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => widget.onCapture(false),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Effacer',
                  ),
                ],
              ),
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Sinon : 403 Visage non reconnu',
              style: TextStyle(fontSize: 12, color: context.appOnSurfaceMuted),
            ),
          ),
      ],
    );
  }
}
