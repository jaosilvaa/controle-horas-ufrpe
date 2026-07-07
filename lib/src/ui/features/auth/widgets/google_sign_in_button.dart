import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/shared/utils/context_extensions.dart';
import 'package:controle_horas/src/ui/features/auth/controllers/auth_controller.dart';

/// Botão "Continuar com Google". Cuida da chamada de login e do feedback.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  Future<void> _entrar(BuildContext context) async {
    final auth = context.read<AuthController>();
    final res = await auth.entrarComGoogle();

    if (!context.mounted) return;
    // Em caso de sucesso, o redirect do go_router leva pra home sozinho.
    // Só mostramos mensagem de erro (mensagem vazia = usuário cancelou).
    if (!res.sucesso && res.mensagem.isNotEmpty) {
      context.showFeedback(res.mensagem, type: FeedbackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carregando = context.watch<AuthController>().carregando;

    return OutlinedButton.icon(
      onPressed: carregando ? null : () => _entrar(context),
      // Ícone oficial do Google (SVG, cores originais).
      icon: SvgPicture.asset('assets/google.svg', width: 20, height: 20),
      label: const Text('Continuar com Google'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: theme.dividerColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        foregroundColor: theme.colorScheme.onSurface,
      ),
    );
  }
}
