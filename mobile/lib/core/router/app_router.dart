import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_leon_de_juda/core/router/app_route.dart';
import 'package:torneo_leon_de_juda/features/about/presentation/screens/about_screen.dart';
import 'package:torneo_leon_de_juda/features/auth/data/auth_repository.dart';
import 'package:torneo_leon_de_juda/features/auth/presentation/screens/login_screen.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:torneo_leon_de_juda/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:torneo_leon_de_juda/features/dashboard/presentation/screens/my_matches_screen.dart';
import 'package:torneo_leon_de_juda/features/dashboard/presentation/screens/my_player_detail_screen.dart';
import 'package:torneo_leon_de_juda/features/dashboard/presentation/screens/my_player_files_screen.dart';
import 'package:torneo_leon_de_juda/features/dashboard/presentation/screens/my_player_form_screen.dart';
import 'package:torneo_leon_de_juda/features/dashboard/presentation/screens/my_players_screen.dart';
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

/// Listenable que sincroniza el GoRouter con cambios del AuthState. Cuando
/// hay login o logout, dispara `refreshListenable` y el redirect re-evalúa
/// si la ruta actual sigue siendo accesible.
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen<AuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
}

/// Configuracion de go_router. Centraliza todas las rutas, deep links y
/// transiciones de la app.
///
/// Para navegar desde codigo: `context.goNamed(AppRoute.home.name)` o
/// `context.go(AppRoute.calendar.path)`.
abstract final class AppRouter {
  AppRouter._();

  static GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();

  static GoRouter buildRouter(Ref ref) {
    final refresh = _AuthRouterRefresh(ref);

    return GoRouter(
      navigatorKey: rootKey,
      initialLocation: AppRoute.home.path,
      refreshListenable: refresh,

      // Rutas /dashboard/* requieren sesión activa. Si el usuario no está
      // autenticado, lo mando a /login. Si está logueado e intenta ir a
      // /login, lo mando directo al dashboard.
      redirect: (context, state) {
        final auth = ref.read(authControllerProvider);
        if (auth.isInitializing) return null;

        final loc = state.matchedLocation;
        final isDashboardRoute = loc.startsWith('/dashboard');
        final isLoginRoute = loc == AppRoute.login.path;

        if (isDashboardRoute && !auth.isAuthenticated) {
          return AppRoute.login.path;
        }
        if (isLoginRoute && auth.isAuthenticated) {
          return AppRoute.dashboard.path;
        }
        return null;
      },

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
          builder: (context, state) => const AboutScreen(),
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

        // ─── Auth + Dashboard (rutas protegidas) ───────────────────
        GoRoute(
          path: AppRoute.login.path,
          name: AppRoute.login.name,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoute.dashboard.path,
          name: AppRoute.dashboard.name,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoute.myMatches.path,
          name: AppRoute.myMatches.name,
          builder: (context, state) => const MyMatchesScreen(),
        ),
        GoRoute(
          path: AppRoute.myPlayers.path,
          name: AppRoute.myPlayers.name,
          builder: (context, state) => const MyPlayersScreen(),
        ),
        GoRoute(
          path: AppRoute.myPlayerNew.path,
          name: AppRoute.myPlayerNew.name,
          builder: (context, state) => const MyPlayerFormScreen(),
        ),
        GoRoute(
          path: AppRoute.myPlayerDetail.path,
          name: AppRoute.myPlayerDetail.name,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const PlaceholderScreen(
                title: 'Jugador no encontrado',
                icon: Icons.error_outline_rounded,
                subtitle: 'ID de jugador inválido.',
              );
            }
            return MyPlayerDetailScreen(playerId: id);
          },
        ),
        GoRoute(
          path: AppRoute.myPlayerEdit.path,
          name: AppRoute.myPlayerEdit.name,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const PlaceholderScreen(
                title: 'Jugador no encontrado',
                icon: Icons.error_outline_rounded,
                subtitle: 'ID de jugador inválido.',
              );
            }
            return MyPlayerFormScreen(playerId: id);
          },
        ),
        GoRoute(
          path: AppRoute.myPlayerFiles.path,
          name: AppRoute.myPlayerFiles.name,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const PlaceholderScreen(
                title: 'Jugador no encontrado',
                icon: Icons.error_outline_rounded,
                subtitle: 'ID de jugador inválido.',
              );
            }
            return MyPlayerFilesScreen(playerId: id);
          },
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
