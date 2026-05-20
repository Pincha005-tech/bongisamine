import 'package:flutter/material.dart';

/// Ferme le clavier sans [BuildContext] (sûr avant navigation / dispose).
abstract final class KeyboardUtils {
  KeyboardUtils._();

  static void dismiss() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus != null && focus.hasFocus) {
      focus.unfocus();
    }
  }
}

/// Alias — préférer [KeyboardUtils.dismiss] (plus fiable au hot reload).
void dismissKeyboard() => KeyboardUtils.dismiss();
