import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/ui/features/settings/controllers/theme_controller.dart';
import 'package:controle_horas/src/ui/widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeCtrl = context.watch<ThemeController>();

    return Scaffold(
      drawer: const Drawer(),
      appBar: const CustomAppBar(
        title: 'Configurações',
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aparência',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Modo escuro',
                  style: theme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Alterna entre tema claro e escuro',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkSubtitle
                        : AppColors.neutralDarkGrey,
                  ),
                ),
                value: themeCtrl.isDarkMode,
                onChanged: themeCtrl.toggleTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
