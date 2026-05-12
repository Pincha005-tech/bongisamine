import 'package:flutter/material.dart';

/// 🌙 Notifier global du thème (UNE SEULE SOURCE)
final ValueNotifier<ThemeMode> appThemeModeNotifier =
    ValueNotifier(ThemeMode.light);

/// 🎯 Controller pour changer le thème
class AppThemeController {
  static void toggleTheme() {
    appThemeModeNotifier.value =
        appThemeModeNotifier.value == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light;
  }
}

/// 👤 ROLE UTILISATEUR GLOBAL
class UserRoleController {
  static String role = "supervisor"; 
  // valeurs possibles :
  // "admin"
  // "supervisor"
}