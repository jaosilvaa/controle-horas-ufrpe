import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:controle_horas/src/ui/widgets/custom_app_bar.dart';

/// Tela "Sobre o App": resume o que é o AcadBSI.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Sobre o App',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabeçalho: logo + nome ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      // logo.png é 3072x3072 — decodifica só no tamanho exibido
                      // pra não travar o frame.
                      cacheWidth:
                          (88 * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                      cacheHeight:
                          (88 * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'AcadBSI',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Acompanhamento de Atividades Complementares',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const _Secao(
              titulo: 'O que é',
              texto:
                  'O AcadBSI é um aplicativo mobile para estudantes do curso de '
                  'Bacharelado em Sistemas de Informação da UAST/UFRPE. Ele ajuda '
                  'a registrar, acompanhar e organizar as atividades '
                  'complementares exigidas ao longo da graduação.',
            ),
            _Secao(
              titulo: 'Para que serve',
              texto:
                  'Oferece uma visão clara do seu progresso em relação à carga '
                  'horária necessária, com uma interface simples e intuitiva — '
                  'pensada nos princípios de Interação Humano-Computador.',
            ),
            _SecaoLista(
              titulo: 'O que dá pra fazer',
              itens: const [
                'Cadastrar atividades complementares',
                'Classificar por categoria do barema (Ensino, Pesquisa, Extensão…)',
                'Calcular automaticamente o total de horas',
                'Ver quanto já fez e quanto ainda falta',
                'Acompanhar o progresso de forma visual',
              ],
            ),
            _Secao(
              titulo: 'Para quem é',
              texto:
                  'Estudantes de BSI da UAST/UFRPE que precisam acompanhar suas '
                  'atividades complementares ao longo do curso.',
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'Versão 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloco de seção: título + parágrafo.
class _Secao extends StatelessWidget {
  final String titulo;
  final String texto;

  const _Secao({required this.titulo, required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloco de seção com lista de itens (bullets).
class _SecaoLista extends StatelessWidget {
  final String titulo;
  final List<String> itens;

  const _SecaoLista({required this.titulo, required this.itens});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corTexto = theme.colorScheme.onSurface.withValues(alpha: 0.75);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...itens.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Iconsax.tick_circle,
                      size: 18, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                        color: corTexto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
