import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clé alignée sur la persistance locale (`AsyncStorage` côté Expo).
const String kThemeModePrefsKey = 'bongisa_theme_mode';

/// Notifier global du thème (une seule source pour [MaterialApp.themeMode]).
final ValueNotifier<ThemeMode> appThemeModeNotifier =
    ValueNotifier(ThemeMode.light);

/// Contrôle du thème + persistance [SharedPreferences].
abstract final class AppThemeController {
  AppThemeController._();

  static SharedPreferences? _prefs;

  /// À appeler dans `main()` avant `runApp`.
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final stored = _prefs!.getString(kThemeModePrefsKey);
    appThemeModeNotifier.value = _parse(stored) ?? ThemeMode.light;
  }

  static ThemeMode? _parse(String? raw) {
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Valeur du switch « Mode sombre » (y compris si le mode système est sombre).
  static bool get isDarkModeEnabled {
    switch (appThemeModeNotifier.value) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    appThemeModeNotifier.value = mode;
    await _prefs?.setString(kThemeModePrefsKey, _encode(mode));
  }

  /// Interrupteur Paramètres : force clair ou sombre (pas « système »).
  static Future<void> setDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  static Future<void> toggleTheme() async {
    await setDarkMode(!isDarkModeEnabled);
  }
}

/// Rôle utilisateur global (anonymisation superviseur, etc.).
class UserRoleController {
  static String role = 'worker';
}
