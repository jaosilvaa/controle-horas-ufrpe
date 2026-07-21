import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/core/config/supabase_config.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/shared/utils/context_extensions.dart';
import 'package:controle_horas/src/ui/features/auth/controllers/auth_controller.dart';
import 'package:controle_horas/src/ui/features/auth/widgets/auth_header.dart';
import 'package:controle_horas/src/ui/features/auth/widgets/auth_text_field.dart';
import 'package:controle_horas/src/ui/features/auth/widgets/google_sign_in_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthController>();
    final res = await auth.cadastrar(_emailCtrl.text, _senhaCtrl.text);

    if (!mounted) return;
    if (res.sucesso) {
      context.showFeedback(res.mensagem);
      // Volta pro login (se já tiver sessão, o redirect leva pra home sozinho).
      context.pop();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    logoSize: 88,
                    subtitle: 'Crie sua conta para começar',
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final email = v?.trim() ?? '';
                      final regex = RegExp(
                        r'^[\w\.\-+]+@[\w\-]+\.[a-zA-Z]{2,}$',
                      );
                      return regex.hasMatch(email) ? null : 'Email inválido';
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _senhaCtrl,
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) => (v == null || v.length < 6)
                        ? 'A senha precisa ter ao menos 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _confirmaCtrl,
                    label: 'Confirmar senha',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) => (v != _senhaCtrl.text)
                        ? 'As senhas não conferem'
                        : null,
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: carregando ? null : _cadastrar,
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
                        : const Text('Criar conta'),
                  ),
                  if (SupabaseConfig.googleEnabled) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ou',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.neutralDarkGrey,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const GoogleSignInButton(),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já tem conta?',
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: carregando ? null : () => context.pop(),
                        style: TextButton.styleFrom(foregroundColor: accent),
                        child: const Text('Entrar'),
                      ),
                    ],
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
