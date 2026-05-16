import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors/app_colors.dart';

class AppTheme {
  static final ColorScheme _lightScheme = ColorScheme.light(
    primary: AppSemanticColors.light.tint,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.white,
    secondary: AppColors.skyBlue,
    onSecondary: AppColors.white,
    surface: AppSemanticColors.light.card,
    onSurface: AppSemanticColors.light.text,
    onSurfaceVariant: AppColors.grayDark,
    error: AppColors.error,
    onError: AppColors.white,
    outline: AppSemanticColors.light.border,
  );

  static final ColorScheme _darkScheme = ColorScheme.dark(
    primary: AppSemanticColors.dark.tint,
    onPrimary: AppColors.black,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.cream,
    secondary: AppColors.skyBlue,
    onSecondary: AppColors.white,
    surface: AppSemanticColors.dark.card,
    onSurface: AppSemanticColors.dark.text,
    onSurfaceVariant: AppColors.gray,
    error: AppColors.error,
    onError: AppColors.white,
    outline: AppSemanticColors.dark.border,
  );

  /// Thème clair (export default.light).
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppSemanticColors.light.background,
    cardColor: AppSemanticColors.light.card,
    dividerColor: AppSemanticColors.light.border,
    colorScheme: _lightScheme,
    primaryColor: _lightScheme.primary,

    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppSemanticColors.light.text,
      displayColor: AppSemanticColors.light.text,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppSemanticColors.light.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppSemanticColors.light.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppSemanticColors.light.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: _lightScheme.secondary,
          width: 1.5,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightScheme.primary,
        foregroundColor: _lightScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: _lightScheme.primary,
      foregroundColor: _lightScheme.onPrimary,
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: _lightScheme.onPrimary),
      titleTextStyle: TextStyle(
        color: _lightScheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppSemanticColors.light.background,
      selectedItemColor: AppSemanticColors.light.tabIconSelected,
      unselectedItemColor: AppSemanticColors.light.tabIconDefault,
    ),

    cardTheme: CardThemeData(
      color: AppSemanticColors.light.card,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  /// Thème sombre (export default.dark).
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppSemanticColors.dark.background,
    cardColor: AppSemanticColors.dark.card,
    dividerColor: AppSemanticColors.dark.border,
    colorScheme: _darkScheme,
    primaryColor: _darkScheme.primary,

    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).apply(
      bodyColor: AppSemanticColors.dark.text,
      displayColor: AppSemanticColors.dark.text,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppSemanticColors.dark.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppSemanticColors.dark.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppSemanticColors.dark.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: _darkScheme.secondary,
          width: 1.5,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkScheme.primary,
        foregroundColor: _darkScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: _darkScheme.primary,
      foregroundColor: _darkScheme.onPrimary,
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: _darkScheme.onPrimary),
      titleTextStyle: TextStyle(
        color: _darkScheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppSemanticColors.dark.background,
      selectedItemColor: AppSemanticColors.dark.tabIconSelected,
      unselectedItemColor: AppSemanticColors.dark.tabIconDefault,
    ),

    cardTheme: CardThemeData(
      color: AppSemanticColors.dark.card,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
