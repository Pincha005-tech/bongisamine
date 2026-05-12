import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF4DA6FF).withOpacity(0.1),
      ),
      child: Image.asset(
        'assets/images/logo.jpeg',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}