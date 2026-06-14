import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'src/app/main_navigation.dart';
import 'src/ui/features/home/pages/home_page.dart';
import 'src/ui/features/categories/pages/categories_page.dart';
import 'src/ui/features/create/pages/create_page.dart';
import 'src/ui/features/settings/pages/settings_page.dart';
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

final routes = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  redirect: (context, state) {
    if (state.uri.path == '/') return '/home';
    return null;
  },
  routes: [
    // ── Shell (com bottom nav) ──────────────────────────────────────────
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

    // ── Sub-telas (sem bottom nav) ──────────────────────────────────────
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
