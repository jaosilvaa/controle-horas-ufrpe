import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/data/services/barema_service.dart';
import 'package:controle_horas/src/ui/features/home/controllers/home_controller.dart';
import 'package:controle_horas/src/ui/features/home/widgets/circular_progress_painter.dart';
import 'package:controle_horas/src/ui/widgets/custom_app_bar.dart';

/// Tela de Estatísticas: visão geral do progresso nas atividades
/// complementares, reaproveitando os cálculos do [BaremaService].
class EstatisticasPage extends StatelessWidget {
  const EstatisticasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resumo = context.watch<HomeController>().resumo;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Estatísticas',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TotalGeralCard(resumo: resumo),
            const SizedBox(height: 24),
            Text(
              'Por natureza',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _NaturezaRow(
              icon: Iconsax.teacher,
              label: 'Ensino',
              horas: resumo.ensino,
              progress: resumo.progressEnsino,
            ),
            const SizedBox(height: 14),
            _NaturezaRow(
              icon: Iconsax.microscope,
              label: 'Pesquisa',
              horas: resumo.pesquisa,
              progress: resumo.progressPesquisa,
            ),
            const SizedBox(height: 14),
            _NaturezaRow(
              icon: Iconsax.global,
              label: 'Extensão',
              horas: resumo.extensao,
              progress: resumo.progressExtensao,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalGeralCard extends StatelessWidget {
  final ResumoBarema resumo;

  const _TotalGeralCard({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trackColor = isDark
        ? AppColors.darkCircularTrack.withValues(alpha: 0.6)
        : AppColors.neutralMidLightGrey;
    final progressColor = isDark ? AppColors.white : AppColors.neutralGrey900;
    final subtitleColor =
        isDark ? AppColors.darkSecondaryText : AppColors.neutralDarkGrey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : AppColors.cardLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: resumo.progressTotal),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => SizedBox(
              width: 96,
              height: 96,
              child: CustomPaint(
                painter: CircularProgressPainter(
                  progress: value,
                  trackColor: trackColor,
                  progressColor: progressColor,
                ),
                child: Center(
                  child: Text(
                    '${(value * 100).toInt()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progresso Total',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: resumo.total),
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Text(
                    '${value.toInt()}h de ${ResumoBarema.maxTotal.toInt()}h',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: subtitleColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NaturezaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double horas;
  final double progress;

  const _NaturezaRow({
    required this.icon,
    required this.label,
    required this.horas,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final iconContainerColor =
        isDark ? AppColors.darkIconContainer : AppColors.neutralMidLightGrey;
    final iconColor = isDark ? AppColors.white : AppColors.neutralGrey900;
    final subtitleColor =
        isDark ? AppColors.darkSubtitle : AppColors.neutralDarkGrey;
    final progressBgColor =
        isDark ? AppColors.darkProgressBg : AppColors.neutralMidLightGrey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconContainerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${horas.toInt()}h / ${BaremaService.maxPorNatureza.toInt()}h',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: subtitleColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: progressBgColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.white : AppColors.neutralGrey900,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
