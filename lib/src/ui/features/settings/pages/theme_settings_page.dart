import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/ui/features/settings/controllers/theme_controller.dart';
import 'package:controle_horas/src/ui/features/settings/widgets/settings_widgets.dart';
import 'package:controle_horas/src/ui/widgets/custom_app_bar.dart';

/// Tela de escolha de tema (Claro / Escuro) com radio buttons.
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeCtrl = context.watch<ThemeController>();
    final isDark = themeCtrl.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Tema',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: RadioGroup<bool>(
          groupValue: isDark,
          onChanged: (v) {
            if (v != null) themeCtrl.toggleTheme(v);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: comDivisoresDiscretos(context, [
              _ThemeOption(
                icon: Iconsax.sun_1,
                label: 'Modo Claro',
                value: false,
                onTap: () => themeCtrl.toggleTheme(false),
              ),
              _ThemeOption(
                icon: Iconsax.moon,
                label: 'Modo Escuro',
                value: true,
                onTap: () => themeCtrl.toggleTheme(true),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;

  /// Qual tema esta opção representa (false = claro, true = escuro).
  final bool value;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.onSurface),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge),
            ),
            Radio<bool>(value: value),
          ],
        ),
      ),
    );
  }
}
