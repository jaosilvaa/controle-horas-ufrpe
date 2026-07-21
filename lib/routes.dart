import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'src/app/main_navigation.dart';
import 'src/core/config/supabase_config.dart';
import 'src/ui/features/auth/controllers/auth_controller.dart';
import 'src/ui/features/splash/pages/splash_page.dart';
import 'src/ui/features/auth/pages/login_page.dart';
import 'src/ui/features/auth/pages/signup_page.dart';
import 'src/ui/features/auth/pages/forgot_password_page.dart';
import 'src/ui/features/auth/pages/reset_password_page.dart';
import 'src/ui/features/home/pages/home_page.dart';
import 'src/ui/features/categories/pages/categories_page.dart';
import 'src/ui/features/create/pages/create_page.dart';
import 'src/ui/features/settings/pages/settings_page.dart';
import 'src/ui/features/settings/pages/theme_settings_page.dart';
import 'src/ui/features/settings/pages/about_page.dart';
import 'src/ui/features/settings/pages/estatisticas_page.dart';
import 'src/data/repositories/atividade_repository.dart';
import 'src/core/di/injection_container.dart';
import 'src/ui/features/pesquisa/controllers/pesquisa_controller.dart';
import 'src/ui/features/pesquisa/pages/pesquisa_page.dart';
import 'src/ui/features/ensino/controllers/ensino_controller.dart';
import 'src/ui/features/ensino/pages/ensino_page.dart';
import 'src/ui/features/extensao/controllers/extensao_controller.dart';
import 'src/ui/features/extensao/pages/extensao_page.dart';
import 'src/ui/features/listagem/controllers/natureza_list_controller.dart';
import 'src/ui/features/listagem/pages/natureza_list_page.dart';
import 'src/ui/features/editar/editar_atividade_page.dart';
import 'src/data/models/atividade_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Rotas que ficam acessíveis SEM estar logado.
const _rotasAuth = {'/login', '/cadastro', '/recuperar-senha'};

final routes = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  // Faz o router reavaliar as rotas sempre que o login muda (entrar/sair).
  refreshListenable:
      SupabaseConfig.isConfigured ? sl<AuthController>() : null,
  redirect: (context, state) {
    final path = state.uri.path;
    if (path == '/') return '/home';
    // A splash decide por conta própria quando navegar; não a redirecionamos.
    if (path == '/splash') return null;

    // Se o Supabase ainda não foi configurado, o app roda sem login (como antes).
    if (!SupabaseConfig.isConfigured) return null;

    final auth = sl<AuthController>();

    // Chegou pelo link de recuperação → tela de nova senha (tem prioridade).
    if (auth.recuperandoSenha) {
      return path == '/nova-senha' ? null : '/nova-senha';
    }

    final logado = auth.logado;
    final emRotaAuth = _rotasAuth.contains(path);

    // Não logado tentando ver tela interna → vai pro login.
    if (!logado && !emRotaAuth) return '/login';
    // Já logado tentando ver login/cadastro → vai pra home.
    if (logado && emRotaAuth) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/cadastro',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/recuperar-senha',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/nova-senha',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ResetPasswordPage(),
    ),

    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesPage(),
        ),
        GoRoute(
          path: '/create',
          builder: (context, state) => const CreatePage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),

    GoRoute(
      path: '/pesquisa/novo',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => PesquisaController(sl<AtividadeRepository>()),
        child: const PesquisaPage(),
      ),
    ),
    GoRoute(
      path: '/ensino/novo',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => EnsinoController(sl<AtividadeRepository>()),
        child: const EnsinoPage(),
      ),
    ),
    GoRoute(
      path: '/extensao/novo',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => ExtensaoController(sl<AtividadeRepository>()),
        child: const ExtensaoPage(),
      ),
    ),
    GoRoute(
      path: '/listagem/:natureza',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final natureza = state.pathParameters['natureza']!;
        return ChangeNotifierProvider(
          create: (_) => NaturezaListController(
            sl<AtividadeRepository>(),
            natureza: natureza,
          ),
          child: NaturezaListPage(natureza: natureza),
        );
      },
    ),
    GoRoute(
      path: '/estatisticas',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EstatisticasPage(),
    ),
    GoRoute(
      path: '/configuracoes/tema',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ThemeSettingsPage(),
    ),
    GoRoute(
      path: '/configuracoes/sobre',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/editar',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final atividade = state.extra as AtividadeModel;
        return EditarAtividadePage(
          atividade: atividade,
          repo: sl<AtividadeRepository>(),
        );
      },
    ),
  ],
);
