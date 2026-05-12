import 'package:flutter/material.dart';

import 'screens/start_screen.dart';
import 'coree/theme/app_themes.dart';
import 'coree/theme/theme_notifier.dart';
import 'coree/routes/app_routes.dart';

void main() {
  runApp(const BongisaMineApp());
}

class BongisaMineApp extends StatelessWidget {
  const BongisaMineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (_, themeMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          onGenerateRoute: AppRoutes.generateRoute,

          home: const StartScreen(),

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
        );
      },
    );
  }
}