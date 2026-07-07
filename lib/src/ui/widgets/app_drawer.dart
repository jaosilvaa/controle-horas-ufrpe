import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/core/config/supabase_config.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/ui/features/auth/controllers/auth_controller.dart';
import 'package:controle_horas/src/ui/features/settings/widgets/settings_widgets.dart';
import 'user_avatar.dart';

/// Drawer compartilhado pelas telas principais (Home, Criar, Configurações).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final configurado = SupabaseConfig.isConfigured;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (configurado) ...[
                Row(
                  children: [
                    const UserAvatar(size: 48),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.nomeUsuario ?? 'Não identificado',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            auth.emailUsuario ?? 'Conta conectada',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkSubtitle
                                  : AppColors.neutralDarkGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 1, color: divisorDiscreto(context)),
                const SizedBox(height: 4),
              ],
              ...comDivisoresDiscretos(context, [
                SettingsTile(
                  icon: Iconsax.moon,
                  label: 'Tema',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/configuracoes/tema');
                  },
                ),
                SettingsTile(
                  icon: Iconsax.info_circle,
                  label: 'Sobre o App',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/configuracoes/sobre');
                  },
                ),
                if (configurado)
                  SettingsTile(
                    icon: Iconsax.logout,
                    label: 'Sair',
                    destrutivo: true,
                    comSeta: false,
                    onTap: () {
                      Navigator.pop(context);
                      auth.sair();
                    },
                  ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
