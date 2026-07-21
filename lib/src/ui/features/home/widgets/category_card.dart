import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;
  final VoidCallback? onTap;

  /// Cor da barra de progresso. Se nula, usa a cor padrão (preto/branco).
  final Color? progressColor;

  const CategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
    this.onTap,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final iconContainerColor =
        isDark ? AppColors.darkIconContainer : AppColors.neutralMidLightGrey;
    final iconColor = isDark ? AppColors.white : AppColors.neutralGrey900;
    final titleColor = isDark ? AppColors.white : AppColors.neutralGrey900;
    final subtitleColor =
        isDark ? AppColors.darkSubtitle : AppColors.neutralDarkGrey;
    final progressTextColor =
        isDark ? AppColors.darkPrimaryText : AppColors.neutralGrey900;
    final progressBgColor =
        isDark ? AppColors.darkProgressBg : AppColors.neutralMidLightGrey;

    return Material(
      color: isDark ? theme.colorScheme.surface : AppColors.cardLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(20),
        splashFactory: InkRipple.splashFactory,
        splashColor:
            (isDark ? AppColors.white : AppColors.black).withValues(alpha: 0.06),
        highlightColor:
            (isDark ? AppColors.white : AppColors.black).withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconContainerColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Percentual e barra animados
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: progressTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: progressBgColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor ??
                              (isDark ? Colors.white : AppColors.neutralGrey900),
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
