/// Single source of truth para nombres y paths de rutas. Evita strings
/// magicos en el codigo — siempre usar `AppRoute.X.path` o `.name`.
///
/// Patron: si necesitas navegar, usar `context.goNamed(AppRoute.home.name)`
/// o `context.go(AppRoute.home.path)`.
enum AppRoute {
  // ─── Tabs principales (dentro del StatefulShell) ───────────────────
  home('/', 'home'),
  calendar('/calendario', 'calendar'),
  standings('/posiciones', 'standings'),
  scorers('/goleadores', 'scorers'),

  // ─── Rutas secundarias (top-level, con back button) ────────────────
  defense('/valla', 'defense'),
  team('/equipo', 'team'),
  sponsors('/patrocinadores', 'sponsors'),
  about('/acerca', 'about'),
  verify('/verificar', 'verify'),
  verifyByCode('/verificar/:code', 'verify-by-code'),
  pqrs('/pqrs', 'pqrs'),
  pqrsSuccess('/pqrs/exito/:code', 'pqrs-success'),

  // ─── Auth ──────────────────────────────────────────────────────────
  login('/login', 'login'),
  dashboard('/dashboard', 'dashboard'),
  myTeams('/dashboard/equipos', 'my-teams'),
  myMatches('/dashboard/partidos', 'my-matches'),
  myPlayers('/dashboard/jugadores', 'my-players');

  const AppRoute(this.path, this.name);

  final String path;
  final String name;
}
