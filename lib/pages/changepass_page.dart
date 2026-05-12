import 'package:flutter/material.dart';
import '../coree/theme/theme_notifier.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.brightness_6),
      label: const Text("Changer thème"),
      onPressed: () {
        AppThemeController.toggleTheme();
      },
    );
  }
}

class AppColors {
  static const skyBlue = Color(0xFF4DA6FF);
  static const bg = Colors.white;
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;
  bool obscure3 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// 🔹 APPBAR
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: const Text(
          "Changer mot de passe",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      /// 🔹 BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              const SizedBox(height: 20),

              /// 🔐 INFO BOX
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.skyBlue),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: AppColors.skyBlue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Choisissez un mot de passe fort pour sécuriser votre compte.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// 🔑 OLD PASSWORD
              _field(
                controller: oldPassword,
                label: "Ancien mot de passe",
                obscure: obscure1,
                toggle: () => setState(() => obscure1 = !obscure1),
              ),

              const SizedBox(height: 15),

              /// 🔑 NEW PASSWORD
              _field(
                controller: newPassword,
                label: "Nouveau mot de passe",
                obscure: obscure2,
                toggle: () => setState(() => obscure2 = !obscure2),
              ),

              const SizedBox(height: 15),

              /// 🔑 CONFIRM PASSWORD
              _field(
                controller: confirmPassword,
                label: "Confirmer mot de passe",
                obscure: obscure3,
                toggle: () => setState(() => obscure3 = !obscure3),
              ),

              const SizedBox(height: 30),

              /// 🔥 BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.skyBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (newPassword.text != confirmPassword.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Les mots de passe ne correspondent pas"),
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mot de passe modifié avec succès"),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Modifier le mot de passe",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 INPUT FIELD PRO
  Widget _field({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Champ requis";
        }
        if (value.length < 6) {
          return "Minimum 6 caractères";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: AppColors.skyBlue),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}