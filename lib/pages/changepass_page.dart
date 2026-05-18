import 'dart:async';

import 'package:flutter/material.dart';

import '../coree/colors/app_colors.dart';
import '../coree/theme/app_page_style.dart';

/// Aligné sur `expo/app/settings/change-password.tsx`
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  String _error = '';
  bool _success = false;

  @override
  void dispose() {
    _current.dispose();
    _newPass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _handleSave() {
    setState(() {
      _error = '';
      _success = false;
    });

    final current = _current.text.trim();
    final newP = _newPass.text;
    final confirm = _confirm.text;

    if (current.isEmpty || newP.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Tous les champs sont obligatoires');
      return;
    }
    if (newP.length < 4) {
      setState(
        () => _error =
            'Le nouveau mot de passe doit contenir au moins 4 caractères',
      );
      return;
    }
    if (newP != confirm) {
      setState(() => _error = 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _success = true);
    unawaited(Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).maybePop();
    }));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final scroll = SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(24, topPad + 24, 24, 40 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Material(
                color: context.appCardColor,
                elevation: 2,
                shadowColor: AppColors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.maybePop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 24,
                      color: context.appTitleAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Changer le mot de passe',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: context.appTitleAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_success)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Mot de passe modifié avec succès!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          _PasswordField(
            controller: _current,
            hint: 'Mot de passe actuel',
            obscure: !_showCurrent,
            onToggleVisibility: () =>
                setState(() => _showCurrent = !_showCurrent),
          ),
          const SizedBox(height: 14),
          _PasswordField(
            controller: _newPass,
            hint: 'Nouveau mot de passe',
            obscure: !_showNew,
            onToggleVisibility: () => setState(() => _showNew = !_showNew),
          ),
          const SizedBox(height: 14),
          _PasswordField(
            controller: _confirm,
            hint: 'Confirmer le mot de passe',
            obscure: !_showConfirm,
            onToggleVisibility: () =>
                setState(() => _showConfirm = !_showConfirm),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 54,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: _handleSave,
                borderRadius: BorderRadius.circular(14),
                child: const Center(
                  child: Text(
                    'Enregistrer',
                    style: TextStyle(
                      color: AppColors.cream,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: context.appPageDecoration,
        child: scroll,
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(14),
      color: context.appCardColor,
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.gray),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscure,
                style: TextStyle(
                  fontSize: 16,
                  color: context.appOnSurface,
                ),
                cursorColor: context.appTitleAccent,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    color: AppColors.gray,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.gray,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
