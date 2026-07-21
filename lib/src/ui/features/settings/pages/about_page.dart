import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:controle_horas/src/ui/widgets/custom_app_bar.dart';

/// Link do documento oficial do barema de Atividades Complementares (BSI).
const _baremaPdfUrl =
    'https://drive.google.com/file/d/1Au0GF-FSdMT-1g6JsMPUZywWAoYiyA1p/view?usp=drive_link';

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
              titulo: 'Como funciona o barema',
              texto:
                  'As horas de cada atividade são somadas dentro da sua '
                  'classificação (ex: Monitoria, Estágio, Projeto de Extensão). '
                  'Cada classificação tem um teto de 120h — mesmo que a conta '
                  'dê um valor maior, só 120h entram no total. Uma mesma '
                  'natureza (Ensino, Pesquisa ou Extensão) pode reunir várias '
                  'classificações diferentes, então ela pode somar mais de '
                  '120h. O que nunca passa de 360h é a soma das três '
                  'naturezas juntas, que é a meta total do curso.',
            ),
            _SecaoLista(
              titulo: 'Resumindo os limites',
              itens: const [
                'Por classificação: no máximo 120h',
                'Por natureza (Ensino, Pesquisa ou Extensão): soma das classificações dessa natureza, sem teto próprio',
                'Total do curso: no máximo 360h, somando as três naturezas',
              ],
            ),
            _BaremaPdfButton(),
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

/// Botão que abre o PDF oficial do barema no navegador/app de PDF do usuário.
class _BaremaPdfButton extends StatelessWidget {
  const _BaremaPdfButton();

  Future<void> _abrirPdf(BuildContext context) async {
    final uri = Uri.parse(_baremaPdfUrl);
    final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: OutlinedButton.icon(
        onPressed: () => _abrirPdf(context),
        icon: const Icon(Iconsax.document_text, size: 18),
        label: const Text('Ver barema completo (PDF)'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
