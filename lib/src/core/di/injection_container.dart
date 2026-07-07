import 'package:get_it/get_it.dart';
import 'package:controle_horas/src/core/config/supabase_config.dart';
import 'package:controle_horas/src/data/database/database_service.dart';
import 'package:controle_horas/src/data/repositories/atividade_repository.dart';
import 'package:controle_horas/src/data/services/settings_service.dart';
import 'package:controle_horas/src/data/services/auth_service.dart';
import 'package:controle_horas/src/ui/features/auth/controllers/auth_controller.dart';
import 'package:controle_horas/src/ui/features/home/controllers/home_controller.dart';
import 'package:controle_horas/src/ui/features/settings/controllers/theme_controller.dart';

final sl = GetIt.instance;

void setupInjection() {
  sl.registerLazySingleton<SettingsService>(() => SettingsService());
  sl.registerLazySingleton<ThemeController>(() => ThemeController(sl()));
  sl.registerLazySingleton<DatabaseService>(() => DatabaseService());
  sl.registerLazySingleton<AtividadeRepository>(
    () => AtividadeRepository(sl()),
  );
  sl.registerLazySingleton<HomeController>(
    () => HomeController(sl()),
  );

  // Auth só é registrado quando o Supabase estiver configurado.
  if (SupabaseConfig.isConfigured) {
    sl.registerLazySingleton<AuthService>(() => AuthService());
    sl.registerLazySingleton<AuthController>(() => AuthController(sl()));
  }
}
