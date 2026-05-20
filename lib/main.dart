import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'coree/api/api_config.dart';
import 'coree/auth/auth_controller.dart';
import 'coree/routing/native_intent_redirect.dart';
import 'coree/routes/app_routes.dart';
import 'coree/theme/app_themes.dart';
import 'coree/theme/theme_notifier.dart';
import 'coree/utils/keyboard_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppThemeController.initialize();
  await ApiConfig.loadBaseUrl();
  await ApiConfig.loadToken();

  // Instance unique : ne pas utiliser ChangeNotifierProvider, qui réabonne
  // l'InheritedProvider à notifyListeners() et peut déclencher l'assertion
  // « ancestor is not true » quand l'arbre change (clavier, navigation).
  // L'écoute se fait via ListenableBuilder / addListener, pas via Provider.watch.
  final authController = AuthController();

  /// Équivalent `SplashScreen.preventAutoHideAsync` : le splash natif
  /// (`flutter_native_splash`) reste jusqu’au premier frame ; il disparaît
  /// ensuite automatiquement. Pour un `remove()` explicite, ajoutez
  /// `flutter_native_splash` en dépendance runtime et appelez-le ici.
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthController>.value(value: authController),
        Provider<AppQueryClient>(create: (_) => const AppQueryClient()),
      ],
      child: const BongisaMineApp(),
    ),
  );
}

class BongisaMineApp extends StatefulWidget {
  const BongisaMineApp({super.key});

  @override
  State<BongisaMineApp> createState() => _BongisaMineAppState();
}

class _BongisaMineAppState extends State<BongisaMineApp> {
  @override
  void initState() {
    super.initState();
    /// Équivalent `useEffect(() => { SplashScreen.hideAsync(); }, [])`
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_hideSplashIfNeeded());
    });
  }

  Future<void> _hideSplashIfNeeded() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    // Ici: FlutterNativeSplash.remove() si le package est en dependency.
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (_, themeMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return GestureDetector(
              onTap: () => KeyboardUtils.dismiss(),
              behavior: HitTestBehavior.translucent,
              child: child ?? const SizedBox.shrink(),
            );
          },
          initialRoute: '/',
          onGenerateInitialRoutes: (String initialRouteName) {
            return NativeIntentRedirect.redirectSystemPath(
              path: initialRouteName,
              initial: true,
            );
          },
          onGenerateRoute: AppRoutes.generateRoute,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
        );
      },
    );
  }
}
