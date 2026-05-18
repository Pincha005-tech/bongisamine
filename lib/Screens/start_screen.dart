import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/routes/app_routes.dart';

/// Équivalent Expo `app/index.tsx` (splash / entrée app).
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _slideCtrl;
  late final AnimationController _scaleCtrl;
  late final AnimationController _rotateCtrl;

  late final Animation<double> _fade;
  late final Animation<double> _slideY;
  late final Animation<double> _scale;
  late final Animation<double> _rotate;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _slideY = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic),
    );
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutCubic),
    );
    _rotate = CurvedAnimation(parent: _rotateCtrl, curve: Curves.linear);

    _fadeCtrl.forward();
    _slideCtrl.forward();
    _scaleCtrl.forward();
    _rotateCtrl.forward();

    _navTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _scaleCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _fadeCtrl,
                    _scaleCtrl,
                    _rotateCtrl,
                  ]),
                  builder: (context, _) {
                    return Opacity(
                      opacity: _fade.value,
                      child: Transform.scale(
                        scale: _scale.value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: _rotate.value * 2 * math.pi,
                              child: const Icon(
                                Icons.construction_rounded,
                                size: 48,
                                color: AppColors.cream,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.engineering_rounded,
                              size: 48,
                              color: AppColors.cream,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: Listenable.merge([_fadeCtrl, _slideCtrl]),
                  builder: (context, _) {
                    return Opacity(
                      opacity: _fade.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideY.value),
                        child: Column(
                          children: [
                            Text(
                              'BONGISA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: AppColors.cream,
                                letterSpacing: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MINE RDC',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.creamDark,
                                letterSpacing: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _fadeCtrl,
                  builder: (context, _) {
                    final t = _fade.value;
                    final dotOpacity = (t < 0.5)
                        ? 0.3 + (t / 0.5) * 0.7
                        : 1.0 - ((t - 0.5) / 0.5) * 0.7;
                    final dotScale = (t < 0.5)
                        ? 0.8 + (t / 0.5) * 0.4
                        : 1.2 - ((t - 0.5) / 0.5) * 0.4;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Opacity(
                            opacity: dotOpacity.clamp(0.3, 1.0),
                            child: Transform.scale(
                              scale: dotScale.clamp(0.8, 1.2),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.cream,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
