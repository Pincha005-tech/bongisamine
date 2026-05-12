import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final String baseUrl = "http://10.0.2.2:8000";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final company = companyController.text.trim();
    final password = passwordController.text.trim();

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    if (name.isEmpty || email.isEmpty || company.isEmpty || password.isEmpty) {
      _showMsg("Veuillez remplir tous les champs");
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      _showMsg("Adresse email invalide");
      return;
    }

    if (password.length < 6) {
      _showMsg("Mot de passe minimum 6 caractères");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "company": company,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        _showMsg(data["message"] ?? "Compte créé avec succès");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _showMsg(data["detail"] ?? "Erreur lors de l'inscription");
      }
    } catch (e) {
      _showMsg("Impossible de contacter le serveur");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    companyController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          "Créer un compte",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _input("Nom complet", Icons.person, nameController, primary),
            const SizedBox(height: 15),

            _input("Email", Icons.email, emailController, primary),
            const SizedBox(height: 15),

            _input(
              "Entreprise / Site minier",
              Icons.location_city,
              companyController,
              primary,
            ),
            const SizedBox(height: 15),

            _input(
              "Mot de passe",
              Icons.lock,
              passwordController,
              primary,
              isPassword: true,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : signUp,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        "Créer un compte",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String hint,
    IconData icon,
    TextEditingController controller,
    Color primary, {
    bool isPassword = false,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),

      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primary),
        hintText: hint,
        hintStyle: TextStyle(color: theme.hintColor),

        filled: true,
        fillColor: theme.cardColor,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
