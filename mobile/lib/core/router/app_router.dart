import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_leon_de_juda/core/router/app_route.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:torneo_leon_de_juda/features/defense/presentation/screens/defense_screen.dart';
import 'package:torneo_leon_de_juda/features/home/presentation/screens/home_screen.dart';
import 'package:torneo_leon_de_juda/features/organigram/presentation/screens/organigram_screen.dart';
import 'package:torneo_leon_de_juda/features/pqrs/presentation/screens/pqrs_screen.dart';
import 'package:torneo_leon_de_juda/features/pqrs/presentation/screens/pqrs_success_screen.dart';
import 'package:torneo_leon_de_juda/features/scorers/presentation/screens/scorers_screen.dart';
import 'package:torneo_leon_de_juda/features/sponsors/presentation/screens/sponsors_screen.dart';
import 'package:torneo_leon_de_juda/features/standings/presentation/screens/standings_screen.dart';
import 'package:torneo_leon_de_juda/features/verify/presentation/screens/verify_scanner_screen.dart';
import 'package:torneo_leon_de_juda/shared/widgets/main_shell.dart';
import 'package:torneo_leon_de_juda/shared/widgets/placeholder_screen.dart';

/// Configuracion de go_router. Centraliza todas las rutas, deep links y
/// transiciones de la app.
///
/// Para navegar desde codigo: `context.goNamed(AppRoute.home.name)` o
/// `context.go(AppRoute.calendar.path)`.
abstract final class AppRouter {
  AppRouter._();

  static GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();

  static GoRouter buildRouter() {
    return GoRouter(
      navigatorKey: rootKey,
      initialLocation: AppRoute.home.path,
      routes: [
        // ─── Shell con bottom nav (4 tabs principales) ─────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoute.home.path,
                  name: AppRoute.home.name,
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoute.calendar.path,
                  name: AppRoute.calendar.name,
                  builder: (context, state) => const CalendarScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoute.standings.path,
                  name: AppRoute.standings.name,
                  builder: (context, state) => const StandingsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoute.scorers.path,
                  name: AppRoute.scorers.name,
                  builder: (context, state) => const ScorersScreen(),
                ),
              ],
            ),
          ],
        ),

        // ─── Rutas secundarias (top-level, sin bottom nav) ─────────
        GoRoute(
          path: AppRoute.defense.path,
          name: AppRoute.defense.name,
          builder: (context, state) => const DefenseScreen(),
        ),
        GoRoute(
          path: AppRoute.team.path,
          name: AppRoute.team.name,
          builder: (context, state) => const OrganigramScreen(),
        ),
        GoRoute(
          path: AppRoute.sponsors.path,
          name: AppRoute.sponsors.name,
          builder: (context, state) => const SponsorsScreen(),
        ),
        GoRoute(
          path: AppRoute.about.path,
          name: AppRoute.about.name,
          builder: (context, state) => const PlaceholderScreen(
            title: 'Sobre el Torneo',
            icon: Icons.info_rounded,
            subtitle: 'Informacion del campeonato',
            stepRef: 'Step 14/15',
          ),
        ),

        // ─── Validador (con deep link por codigo) ──────────────────
        GoRoute(
          path: AppRoute.verify.path,
          name: AppRoute.verify.name,
          builder: (context, state) => const VerifyScannerScreen(),
        ),
        GoRoute(
          path: AppRoute.verifyByCode.path,
          name: AppRoute.verifyByCode.name,
          builder: (context, state) {
            final code = state.pathParameters['code'] ?? '';
            return VerifyScannerScreen(initialCode: code);
          },
        ),

        // ─── PQRS ──────────────────────────────────────────────────
        GoRoute(
          path: AppRoute.pqrs.path,
          name: AppRoute.pqrs.name,
          builder: (context, state) => const PqrsScreen(),
        ),
        GoRoute(
          path: AppRoute.pqrsSuccess.path,
          name: AppRoute.pqrsSuccess.name,
          builder: (context, state) {
            final code = state.pathParameters['code'] ?? '';
            return PqrsSuccessScreen(code: code);
          },
        ),

        // ─── Auth ──────────────────────────────────────────────────
        GoRoute(
          path: AppRoute.login.path,
          name: AppRoute.login.name,
          builder: (context, state) => const PlaceholderScreen(
            title: 'Ingresar',
            icon: Icons.login_rounded,
            subtitle: 'Acceso para lideres de equipo',
            stepRef: 'Post-MVP',
            showDrawer: false,
          ),
        ),
      ],

      // Pantalla cuando una ruta no existe (404)
      errorBuilder: (context, state) => const PlaceholderScreen(
        title: 'No encontrado',
        icon: Icons.error_outline_rounded,
        subtitle: 'La pagina solicitada no existe.',
      ),
    );
  }
}
