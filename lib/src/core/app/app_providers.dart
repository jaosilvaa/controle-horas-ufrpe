import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/core/di/injection_container.dart';
import 'package:controle_horas/src/ui/features/home/controllers/home_controller.dart';
import 'package:controle_horas/src/ui/features/settings/controllers/theme_controller.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<ThemeController>()..init()),
        ChangeNotifierProvider(
          create: (_) => sl<HomeController>()..carregar(),
        ),
      ],
      child: child,
    );
  }
}
