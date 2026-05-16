import 'package:flutter/material.dart';

import '../../Screens/start_screen.dart';

/// Équivalent Expo `app/+native-intent.tsx` — `redirectSystemPath`.
///
/// Tout chemin issu d’un **intent / lien profond système** est ramené vers
/// la racine `/` (écran de démarrage), comme `return '/'` côté Expo.
abstract final class NativeIntentRedirect {
  NativeIntentRedirect._();

  static List<Route<dynamic>> redirectSystemPath({
    required String path,
    required bool initial,
  }) {
    return <Route<dynamic>>[
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/'),
        builder: (_) => const StartScreen(),
      ),
    ];
  }
}
