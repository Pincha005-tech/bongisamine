import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Template équivalent Expo `app/modal.tsx` (modal fade + overlay).
class ModalScreen extends StatelessWidget {
  const ModalScreen({super.key});

  /// Route : fond semi-transparent + fermeture au tap hors carte (`barrierDismissible`),
  /// transition **fade** comme `animationType="fade"`.
  static Route<void> fadeRoute() {
    return PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: const ModalScreen(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final overlayStyle = defaultTargetPlatform == TargetPlatform.iOS
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {},
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 300),
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Modal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This is an example modal with proper fade animation. '
                      'You can edit it in app/modal.tsx.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF666666),
                        height: 20 / 14,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(100, 44),
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
