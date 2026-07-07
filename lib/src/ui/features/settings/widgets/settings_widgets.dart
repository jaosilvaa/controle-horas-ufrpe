import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';

/// Cor de divisória bem discreta, que se adapta ao tema.
Color divisorDiscreto(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.black.withValues(alpha: 0.06);
}

/// Intercala uma divisória discreta entre cada item da lista.
List<Widget> comDivisoresDiscretos(BuildContext context, List<Widget> itens) {
  final divisor = Divider(
    height: 1,
    thickness: 1,
    color: divisorDiscreto(context),
  );
  final resultado = <Widget>[];
  for (var i = 0; i < itens.length; i++) {
    resultado.add(itens[i]);
    if (i != itens.length - 1) resultado.add(divisor);
  }
  return resultado;
}

/// Item de lista das configurações: ícone + texto + seta (sem círculo).
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Mostra a seta de "ir para a tela" no fim do item.
  final bool comSeta;

  /// Estilo de ação destrutiva (vermelho), usado no "Sair".
  final bool destrutivo;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.comSeta = true,
    this.destrutivo = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cor = destrutivo ? AppColors.error : theme.colorScheme.onSurface;
    final corSeta = isDark ? AppColors.darkSubtitle : AppColors.neutralDarkGrey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: cor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(color: cor),
              ),
            ),
            if (comSeta)
              Icon(Iconsax.arrow_right_3, size: 20, color: corSeta),
          ],
        ),
      ),
    );
  }
}
