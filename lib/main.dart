import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:controle_horas/src/core/theme/app_theme.dart';
import 'package:controle_horas/src/core/config/supabase_config.dart';
import 'package:controle_horas/src/core/di/injection_container.dart';
import 'package:controle_horas/src/core/utils/system_config.dart';
import 'package:controle_horas/src/core/app/app_providers.dart';
import 'package:controle_horas/src/ui/features/settings/controllers/theme_controller.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prepareSystemUI();

  // Conecta ao Supabase antes de iniciar o app. Só inicializa se as chaves
  // já tiverem sido preenchidas em supabase_config.dart.
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  setupInjection();

  // Carrega o tema salvo ANTES do primeiro frame, senão o app nasce sempre
  // no tema padrão (dark) por uma fração de segundo, mesmo que o usuário
  // tenha escolhido o claro.
  await sl<ThemeController>().init();

  runApp(const AppProviders(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeController>().themeMode;
    return MaterialApp.router(
      title: 'Controle de Horas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      routerConfig: routes,
    );
  }
}
