import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/core/config/supabase_config.dart';
import 'package:controle_horas/src/core/di/injection_container.dart';
import 'package:controle_horas/src/ui/features/auth/controllers/auth_controller.dart';
import 'package:controle_horas/src/ui/features/home/controllers/home_controller.dart';
import 'package:controle_horas/src/ui/features/settings/controllers/theme_controller.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<ThemeController>()),
        ChangeNotifierProvider(
          create: (_) => sl<HomeController>()..carregar(),
        ),
        // Só registra o AuthController quando o Supabase estiver configurado.
        if (SupabaseConfig.isConfigured)
          ChangeNotifierProvider(create: (_) => sl<AuthController>()),
      ],
      child: child,
    );
  }
}
