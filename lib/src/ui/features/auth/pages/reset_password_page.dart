import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/shared/utils/context_extensions.dart';
import 'package:controle_horas/src/ui/features/auth/controllers/auth_controller.dart';
import 'package:controle_horas/src/ui/features/auth/widgets/auth_text_field.dart';

/// Tela aberta quando o link de recuperação de senha abre o app.
/// O usuário define a nova senha e entra no app.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _senhaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();

  @override
  void dispose() {
    _senhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthController>();
    final res = await auth.atualizarSenha(_senhaCtrl.text);

    if (!mounted) return;
    if (res.sucesso) {
      context.showFeedback(res.mensagem);
      await auth.sair();
    } else {
      context.showFeedback(res.mensagem, type: FeedbackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carregando = context.watch<AuthController>().carregando;
    final accent = AppColors.authAccent(theme.brightness);
    final onAccent = AppColors.authOnAccent(theme.brightness);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_open, size: 56, color: accent),
                  const SizedBox(height: 20),
                  Text(
                    'Criar nova senha',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha uma nova senha para sua conta.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutralDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    controller: _senhaCtrl,
                    label: 'Nova senha',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) => (v == null || v.length < 6)
                        ? 'A senha precisa ter ao menos 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _confirmaCtrl,
                    label: 'Confirmar nova senha',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) =>
                        (v != _senhaCtrl.text) ? 'As senhas não conferem' : null,
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: carregando ? null : _salvar,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: carregando
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: onAccent,
                            ),
                          )
                        : const Text('Salvar nova senha'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
