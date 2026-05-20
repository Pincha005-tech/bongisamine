import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../coree/auth/auth_controller.dart';
import '../coree/colors/app_colors.dart';
import '../coree/routes/app_routes.dart';
import '../coree/utils/keyboard_utils.dart';

/// Équivalent Expo `app/signup.tsx` : dégradé, formulaire, validation, `useAuth().signup`.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _showPassword = false;
  String _error = '';
  bool _loading = false;

  Future<void> _handleSignup() async {
    setState(() => _error = '');
    final name = _name.text.trim();
    final email = _email.text.trim();
    final company = _company.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(
        () => _error = 'Veuillez remplir les champs obligatoires',
      );
      return;
    }
    if (password.length < 4) {
      setState(
        () => _error =
            'Le mot de passe doit contenir au moins 4 caractères',
      );
      return;
    }
    if (password != confirm) {
      setState(
        () => _error = 'Les mots de passe ne correspondent pas',
      );
      return;
    }

    setState(() => _loading = true);
    final auth = context.read<AuthController>();
    final ok = await auth.signup(name, email, company, password);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      setState(() => _error = "Échec de l'inscription");
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _company.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scroll = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Column(
                    children: [
                      Text(
                        'Créer un compte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cream,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rejoignez BONGISA MINE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.creamDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (_error.isNotEmpty) ...[
                    Text(
                      _error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _field(
                    icon: Icons.person_outline_rounded,
                    controller: _name,
                    hint: 'Nom complet',
                  ),
                  const SizedBox(height: 14),
                  _field(
                    icon: Icons.mail_outline_rounded,
                    controller: _email,
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    icon: Icons.business_rounded,
                    controller: _company,
                    hint: 'Entreprise (optionnel)',
                  ),
                  const SizedBox(height: 14),
                  _field(
                    icon: Icons.lock_outline_rounded,
                    controller: _password,
                    hint: 'Mot de passe',
                    obscure: true,
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.gray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _field(
                    icon: Icons.lock_outline_rounded,
                    controller: _confirm,
                    hint: 'Confirmer le mot de passe',
                    obscure: true,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 54,
                    child: Material(
                      color: _loading
                          ? AppColors.cream.withValues(alpha: 0.6)
                          : AppColors.cream,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _loading ? null : _handleSignup,
                        child: Center(
                          child: Text(
                            _loading ? 'Inscription...' : "S'inscrire",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: AppColors.creamDark,
                          fontSize: 14,
                        ),
                        children: const [
                          TextSpan(text: 'Déjà un compte? '),
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.cream,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final body = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: scroll,
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: body,
      ),
    );
  }

  Widget _field({
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    bool autocorrect = true,
    Widget? suffix,
  }) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gray),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure && !_showPassword,
              keyboardType: keyboardType,
              autocorrect: autocorrect,
              textCapitalization: keyboardType == TextInputType.emailAddress
                  ? TextCapitalization.none
                  : TextCapitalization.sentences,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.black,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.gray),
              ),
            ),
          ),
          if (suffix != null) suffix,
        ],
      ),
    );
  }
}
