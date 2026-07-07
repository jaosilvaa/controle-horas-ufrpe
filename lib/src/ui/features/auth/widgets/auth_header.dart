import 'package:flutter/material.dart';

/// Cabeçalho das telas de autenticação: a logo do app + o nome "AcadBSI".
///
/// Fica no topo do login, cadastro e demais telas de auth, mantendo a
/// identidade visual consistente.
class AuthHeader extends StatelessWidget {
  /// Tamanho (largura/altura) da logo em pixels.
  final double logoSize;

  /// Texto opcional mostrado abaixo do nome (ex.: "Entre para continuar").
  final String? subtitle;

  const AuthHeader({super.key, this.logoSize = 96, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // assets/logo.png é 3072x3072 — decodificar nesse tamanho cheio só pra
    // mostrar em poucos pixels na tela trava o primeiro frame. Pedindo pro
    // decoder já gerar no tamanho exibido (considerando a densidade da
    // tela) evita esse atraso.
    final decodeSize =
        (logoSize * MediaQuery.devicePixelRatioOf(context)).round();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
            cacheWidth: decodeSize,
            cacheHeight: decodeSize,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'AcadBSI',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}
