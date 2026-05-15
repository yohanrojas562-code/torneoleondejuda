// Mock data del Home. Se reemplaza por repositorios reales en Step 19
// cuando se conecten al API Laravel.

class ActiveSeasonMock {
  const ActiveSeasonMock({
    required this.tournamentName,
    required this.seasonName,
    required this.category,
    required this.statusLabel,
    required this.isLive,
    required this.liveMatchesToday,
  });

  final String tournamentName;
  final String seasonName;
  final String category;
  final String statusLabel;
  final bool isLive;
  final int liveMatchesToday;
}

class UpcomingMatchMock {
  const UpcomingMatchMock({
    required this.homeTeam,
    required this.awayTeam,
    required this.scheduledAt,
    required this.venue,
    required this.matchDay,
  });

  final String homeTeam;
  final String awayTeam;
  final DateTime scheduledAt;
  final String venue;
  final String matchDay;
}

abstract final class MockHomeData {
  MockHomeData._();

  static const activeSeason = ActiveSeasonMock(
    tournamentName: 'Torneo León de Judá',
    seasonName: 'Temporada 2026',
    category: 'Categoría Libre',
    statusLabel: 'Fase de grupos',
    isLive: true,
    liveMatchesToday: 3,
  );

  static List<UpcomingMatchMock> get upcomingMatches => [
        UpcomingMatchMock(
          homeTeam: 'Cfe La Salle',
          awayTeam: 'Cfe Robledo',
          scheduledAt: DateTime.now().add(const Duration(hours: 3)),
          venue: 'Cancha el Raizal #1',
          matchDay: 'Jornada 5',
        ),
        UpcomingMatchMock(
          homeTeam: 'Cfe Centro',
          awayTeam: 'Cfe Norte',
          scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 4)),
          venue: 'Cancha el Raizal #2',
          matchDay: 'Jornada 5',
        ),
        UpcomingMatchMock(
          homeTeam: 'Cfe Oriente',
          awayTeam: 'Cfe Sur',
          scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 2)),
          venue: 'Cancha Bocagrande',
          matchDay: 'Jornada 6',
        ),
      ];
}
