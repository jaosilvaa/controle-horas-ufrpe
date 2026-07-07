import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/ui/features/home/controllers/home_controller.dart';
import 'circular_progress_painter.dart';

class TotalCard extends StatelessWidget {
  const TotalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeController>();
    final resumo = home.resumo;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trackColor = isDark
        ? AppColors.darkCircularTrack.withValues(alpha: 0.6)
        : AppColors.neutralMidLightGrey;
    final progressColor = isDark ? AppColors.white : AppColors.neutralGrey900;
    final titleColor =
        isDark ? AppColors.darkPrimaryText : AppColors.neutralGrey900;
    final subtitleColor =
        isDark ? AppColors.darkSecondaryText : AppColors.neutralDarkGrey;
    final percentColor =
        isDark ? AppColors.white : AppColors.neutralGrey900;

    return Container(
      width: double.infinity,
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? AppColors.black : AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 2,
            bottom: 0,
            child: Opacity(
              opacity: 0.10,
              child: SvgPicture.asset(
                'assets/Vector_colegio_fica_no_fundo_cardhome.svg',
                width: 178,
                fit: BoxFit.contain,
                alignment: Alignment.bottomLeft,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Progresso Total',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Anima o texto de horas junto com o progresso
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: resumo.total),
                        duration: const Duration(milliseconds: 1400),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Text(
                          '${value.toInt()}h completadas',
                          style: TextStyle(fontSize: 13, color: subtitleColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Circular animado: vai de 0 até o progresso atual
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: resumo.progressTotal),
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => SizedBox(
                    width: 92,
                    height: 92,
                    child: CustomPaint(
                      painter: CircularProgressPainter(
                        progress: value,
                        trackColor: trackColor,
                        progressColor: progressColor,
                      ),
                      child: Center(
                        child: Text(
                          '${(value * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: percentColor,
                          ),
                        ),
                      ),
                    ),
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
