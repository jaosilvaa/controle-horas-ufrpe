import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/core/config/supabase_config.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/ui/features/auth/controllers/auth_controller.dart';
import 'package:controle_horas/src/app/main_navigation.dart';
import 'package:controle_horas/src/ui/features/settings/widgets/settings_widgets.dart';
import 'package:controle_horas/src/ui/widgets/custom_app_bar.dart';
import 'package:controle_horas/src/ui/widgets/user_avatar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();
    final configurado = SupabaseConfig.isConfigured;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Configurações',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: openAppDrawer,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (configurado) ...[
              _ProfileCard(
                nome: auth.nomeUsuario ?? 'Não identificado',
                email: auth.emailUsuario ?? 'Conta conectada',
              ),
              const SizedBox(height: 24),
            ],

            ...comDivisoresDiscretos(context, [
              SettingsTile(
                icon: Iconsax.moon,
                label: 'Tema',
                onTap: () => context.push('/configuracoes/tema'),
              ),
              SettingsTile(
                icon: Iconsax.info_circle,
                label: 'Sobre o App',
                onTap: () => context.push('/configuracoes/sobre'),
              ),
              if (configurado)
                SettingsTile(
                  icon: Iconsax.logout,
                  label: 'Sair',
                  destrutivo: true,
                  comSeta: false,
                  onTap: () => auth.sair(),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String nome;
  final String email;

  const _ProfileCard({required this.nome, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          const UserAvatar(size: 54),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
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
    );
  }
}
