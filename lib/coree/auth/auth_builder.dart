import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';

/// Écoute [AuthController] via [ListenableBuilder], pas via `Provider.watch`.
///
/// Évite l'assertion Provider « ancestor is not true » quand l'arbre change
/// pendant la fermeture du clavier ou une navigation.
class AuthBuilder extends StatelessWidget {
  const AuthBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, AuthController auth) builder;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) => builder(context, auth),
    );
  }
}

/// Lecture seule — ne jamais utiliser `watch` / `select` sur [AuthController].
AuthController readAuth(BuildContext context) =>
    context.read<AuthController>();
