import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/ui/features/auth/controllers/auth_controller.dart';

/// Avatar do usuário logado.
///
/// Mostra a foto do Google quando existe; senão, mostra a inicial do nome
/// (ou um ícone genérico) sobre um círculo de fundo.
class UserAvatar extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  const UserAvatar({
    super.key,
    this.size = 43,
    this.backgroundColor = const Color(0xFF171717),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final fotoUrl = auth.fotoUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: (fotoUrl != null)
          ? Image.network(
              fotoUrl,
              fit: BoxFit.cover,
              // Enquanto carrega ou se der erro, mostra o fallback.
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _fallback(auth),
              errorBuilder: (context, _, _) => _fallback(auth),
            )
          : _fallback(auth),
    );
  }

  Widget _fallback(AuthController auth) {
    final nome = auth.nomeUsuario;
    final inicial = (nome != null && nome.isNotEmpty)
        ? nome[0].toUpperCase()
        : null;

    return Center(
      child: inicial != null
          ? Text(
              inicial,
              style: TextStyle(
                color: foregroundColor,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w600,
              ),
            )
          : Icon(
              Icons.person_outline_rounded,
              color: foregroundColor,
              size: size * 0.5,
            ),
    );
  }
}
