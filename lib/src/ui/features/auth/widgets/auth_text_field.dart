import 'package:flutter/material.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';

/// Campo de texto padrão das telas de autenticação.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Preto no modo claro, branco no escuro — substitui o azul do tema.
    final accent = AppColors.authAccent(theme.brightness);

    return Theme(
      // Sobrescreve as cores de cursor/seleção (que vinham azuis do tema global)
      // só dentro deste campo.
      data: theme.copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: accent,
          selectionColor: accent.withValues(alpha: 0.30),
          selectionHandleColor: accent,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscure,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        textInputAction: widget.textInputAction,
        cursorColor: accent,
        decoration: InputDecoration(
          labelText: widget.label,
          // Cor do rótulo quando o campo está focado (era azul).
          floatingLabelStyle: TextStyle(color: accent),
          // Ícone fica cinza normal e muda pro preto/branco ao focar.
          prefixIconColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.focused)
                ? accent
                : theme.colorScheme.outline,
          ),
          prefixIcon: Icon(widget.icon),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
