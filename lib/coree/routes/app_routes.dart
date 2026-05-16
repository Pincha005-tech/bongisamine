// core/routes/app_routes.dart
import 'package:flutter/material.dart';

import '../../Screens/home_screen.dart';
import '../../Screens/login_screen.dart';
import '../../Screens/modal_screen.dart';
import '../../Screens/signup_screen.dart';
import '../../Screens/start_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const modal = '/modal';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case modal:
        return ModalScreen.fadeRoute();

      default:
        /// Inconnu → racine (cohérent avec `+native-intent` qui renvoie `/`).
        return MaterialPageRoute(builder: (_) => const StartScreen());
    }
  }
}