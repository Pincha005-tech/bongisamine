import 'package:flutter/material.dart';

/// Palette alignée sur `expo/constants/colors.ts` (export `Colors`).
abstract final class AppColors {
  AppColors._();

  static const primary = Color(0xFF8F4F07);
  static const primaryLight = Color(0xFFB87A3A);
  static const primaryDark = Color(0xFF5C3504);
  static const cream = Color(0xFFF3E4C7);
  static const creamDark = Color(0xFFE8D4A8);
  static const lightBlue = Color(0xFFE6EFF4);
  static const skyBlue = Color(0xFF73BFF3);
  static const skyBlueDark = Color(0xFF4A9FD8);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF1A1A1A);
  static const gray = Color(0xFF9CA3AF);
  static const grayLight = Color(0xFFF3F4F6);
  static const grayDark = Color(0xFF4B5563);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  /// Carte mode sombre (export default dark.card).
  static const darkCard = Color(0xFF2A2A2A);

  // --- Raccourcis legacy (anciennes pages privacy / listes) ---
  static const text = black;
  static const grey = gray;
}

/// Thème sémantique aligné sur l’export default de `colors.ts` (light / dark).
@immutable
class AppSemanticColors {
  const AppSemanticColors({
    required this.text,
    required this.background,
    required this.tint,
    required this.tabIconDefault,
    required this.tabIconSelected,
    required this.card,
    required this.border,
    required this.notification,
  });

  final Color text;
  final Color background;
  final Color tint;
  final Color tabIconDefault;
  final Color tabIconSelected;
  final Color card;
  final Color border;
  final Color notification;

  static const light = AppSemanticColors(
    text: AppColors.black,
    background: AppColors.cream,
    tint: AppColors.primary,
    tabIconDefault: AppColors.gray,
    tabIconSelected: AppColors.primary,
    card: AppColors.white,
    border: AppColors.creamDark,
    notification: AppColors.primary,
  );

  static const dark = AppSemanticColors(
    text: AppColors.cream,
    background: AppColors.black,
    tint: AppColors.primaryLight,
    tabIconDefault: AppColors.gray,
    tabIconSelected: AppColors.primaryLight,
    card: AppColors.darkCard,
    border: AppColors.grayDark,
    notification: AppColors.primaryLight,
  );
}
