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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthController>();
    final res = await auth.entrar(_emailCtrl.text, _senhaCtrl.text);

    if (!mounted) return;
    if (res.sucesso) {
      // O redirect do go_router leva pra home automaticamente após o login.
      context.showFeedback(res.mensagem);
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    logoSize: 104,
                    subtitle: 'Entre para acessar suas atividades',
                  ),
                  const SizedBox(height: 36),
                  AuthTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Email inválido' : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _senhaCtrl,
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Informe sua senha'
                        : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: carregando
                          ? null
                          : () => context.push('/recuperar-senha'),
                      style: TextButton.styleFrom(foregroundColor: accent),
                      child: const Text('Esqueci minha senha'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: carregando ? null : _entrar,
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
                        : const Text('Entrar'),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem conta?',
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: carregando
                            ? null
                            : () => context.push('/cadastro'),
                        style: TextButton.styleFrom(foregroundColor: accent),
                        child: const Text('Criar conta'),
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
