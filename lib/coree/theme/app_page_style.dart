import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// Couleurs / dégradés des écrans selon le thème actif ([ThemeMode]).
extension AppPageStyle on BuildContext {
  bool get isAppDark => Theme.of(this).brightness == Brightness.dark;

  AppSemanticColors get semantic =>
      isAppDark ? AppSemanticColors.dark : AppSemanticColors.light;

  BoxDecoration get appPageDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isAppDark
              ? [AppColors.black, const Color(0xFF1F2937)]
              : [AppColors.cream, AppColors.lightBlue],
        ),
      );

  Color get appCardColor => Theme.of(this).cardColor;

  Color get appOnSurface => Theme.of(this).colorScheme.onSurface;

  Color get appOnSurfaceMuted => appOnSurface.withValues(alpha: 0.7);

  Color get appTitleAccent =>
      isAppDark ? AppColors.primaryLight : AppColors.primary;

  Color get appIconTileBg => isAppDark
      ? AppColors.primary.withValues(alpha: 0.22)
      : AppColors.cream;

  Color get appDividerOnPage =>
      isAppDark ? AppColors.grayDark : AppColors.grayLight;
}
