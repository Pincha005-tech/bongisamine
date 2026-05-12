// core/routes/app_routes.dart
import 'package:flutter/material.dart';

import '../../screens/home_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/signup_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case login:
        return MaterialPageRoute(builder: (_) =>  LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      default:
        return MaterialPageRoute(builder: (_) =>  LoginScreen());
    }
  }
}