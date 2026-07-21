import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/app/main_navigation.dart';
import 'package:controle_horas/src/ui/features/home/controllers/home_controller.dart';
import '../widgets/home_header.dart';
import '../widgets/total_card.dart';
import '../widgets/category_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double _horizontalPadding = 16;

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeController>();
    final resumo = home.resumo;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores por natureza: mesma cor nos dois temas.
    const corEnsino = Color(0xFFF8D16A);
    const corPesquisa = Color(0xFFA976FF);
    const corExtensao = Color(0xFF4C9BFF);

    return Scaffold(
      appBar: AppBar(
        // Light: preto (padrão de fundo escuro). Dark: branco (inverso).
        backgroundColor: isDark ? AppColors.white : AppColors.darkScaffold,
        toolbarHeight: 72,
        titleSpacing: 0,
        // Ícone do Drawer sempre com contraste sobre o fundo do AppBar
        iconTheme: IconThemeData(color: isDark ? Colors.black : Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: openAppDrawer,
        ),
        title: const Padding(
          padding: EdgeInsets.only(right: _horizontalPadding),
          child: HomeHeader(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // Light: preto (padrão de fundo escuro). Dark: branco (inverso).
                color: isDark ? AppColors.white : AppColors.darkScaffold,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                14,
                _horizontalPadding,
                20,
              ),
              child: const TotalCard(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: Column(
                children: [
                  CategoryCard(
                    title: 'Ensino',
                    subtitle: '${resumo.ensino.toInt()}h / 360h',
                    progress: resumo.progressEnsino,
                    icon: Iconsax.teacher,
                    progressColor: corEnsino,
                    onTap: () => context.push('/listagem/ensino'),
                  ),
                  const SizedBox(height: 12),
                  CategoryCard(
                    title: 'Pesquisa',
                    subtitle: '${resumo.pesquisa.toInt()}h / 360h',
                    progress: resumo.progressPesquisa,
                    icon: Iconsax.microscope,
                    progressColor: corPesquisa,
                    onTap: () => context.push('/listagem/pesquisa'),
                  ),
                  const SizedBox(height: 12),
                  CategoryCard(
                    title: 'Extensão',
                    subtitle: '${resumo.extensao.toInt()}h / 360h',
                    progress: resumo.progressExtensao,
                    icon: Iconsax.global,
                    progressColor: corExtensao,
                    onTap: () => context.push('/listagem/extensao'),
                  ),
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}