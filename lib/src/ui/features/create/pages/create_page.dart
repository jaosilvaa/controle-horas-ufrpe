import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const Drawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Cadastrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cadastrar nova Atividade',
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.neutralGrey900,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.52,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _NaturezaCard(
                      icon: Iconsax.teacher,
                      text: 'Cadastrar\nEnsino',
                      onTap: () => context.push('/ensino/novo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _NaturezaCard(
                            icon: Iconsax.search_normal,
                            text: 'Cadastrar\nPesquisa',
                            onTap: () => context.push('/pesquisa/novo'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _NaturezaCard(
                            icon: Iconsax.global,
                            text: 'Cadastrar\nExtensão',
                            onTap: () => context.push('/extensao/novo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NaturezaCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _NaturezaCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final iconContainerColor =
        isDark ? AppColors.darkIconContainer : AppColors.neutralMidLightGrey;
    final iconColor = isDark ? AppColors.white : AppColors.neutralGrey900;
    final textColor = isDark ? AppColors.white : AppColors.neutralGrey900;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.lightImpact();
          Future.delayed(const Duration(milliseconds: 120), onTap);
        },
        splashFactory: InkRipple.splashFactory,
        splashColor:
            (isDark ? AppColors.white : AppColors.black).withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: iconContainerColor,
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const SizedBox(height: 20),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
