import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mock data del Calendario. Reemplazado por MatchesRepository en Step 19.

class MatchTeamMock {
  const MatchTeamMock({
    required this.id,
    required this.name,
    required this.shortName,
    required this.primaryColor,
    this.logoUrl,
  });

  final int id;
  final String name;
  final String shortName;
  final Color primaryColor;
  final String? logoUrl;
}

/// Estado de un partido programado/aplazado/cancelado.
enum PostponedStatus { postponed, suspended, cancelled }

extension PostponedStatusX on PostponedStatus {
  String get label => switch (this) {
        PostponedStatus.postponed => 'Aplazado',
        PostponedStatus.suspended => 'Suspendido',
        PostponedStatus.cancelled => 'Cancelado',
      };
}

class MatchGoalMock {
  const MatchGoalMock({
    required this.playerName,
    required this.minute,
    this.isPenalty = false,
    this.isOwnGoal = false,
  });

  final String playerName;
  final int minute;
  final bool isPenalty;
  final bool isOwnGoal;
}

class UpcomingMatchMock {
  const UpcomingMatchMock({
    required this.id,
    required this.home,
    required this.away,
    required this.scheduledAt,
    required this.venue,
    required this.matchDay,
    this.isLive = false,
    this.liveHomeScore,
    this.liveAwayScore,
    this.liveStatus,
  });

  final int id;
  final MatchTeamMock home;
  final MatchTeamMock away;
  final DateTime scheduledAt;
  final String venue;
  final String matchDay;
  final bool isLive;
  final int? liveHomeScore;
  final int? liveAwayScore;

  /// Texto del estado live, ej. '1er Tiempo', 'Descanso', '2do Tiempo'.
  final String? liveStatus;
}

class FinishedMatchMock {
  const FinishedMatchMock({
    required this.id,
    required this.home,
    required this.away,
    required this.homeScore,
    required this.awayScore,
    required this.playedAt,
    required this.venue,
    required this.matchDay,
    this.homeGoals = const [],
    this.awayGoals = const [],
    this.homeYellows = 0,
    this.homeBlues = 0,
    this.homeReds = 0,
    this.awayYellows = 0,
    this.awayBlues = 0,
    this.awayReds = 0,
  });

  final int id;
  final MatchTeamMock home;
  final MatchTeamMock away;
  final int homeScore;
  final int awayScore;
  final DateTime playedAt;
  final String venue;
  final String matchDay;
  final List<MatchGoalMock> homeGoals;
  final List<MatchGoalMock> awayGoals;
  final int homeYellows;
  final int homeBlues;
  final int homeReds;
  final int awayYellows;
  final int awayBlues;
  final int awayReds;

  bool get hasGoals => homeGoals.isNotEmpty || awayGoals.isNotEmpty;
  int get totalYellows => homeYellows + awayYellows;
  int get totalBlues => homeBlues + awayBlues;
  int get totalReds => homeReds + awayReds;
  bool get hasCards => totalYellows + totalBlues + totalReds > 0;
}

class PostponedMatchMock {
  const PostponedMatchMock({
    required this.id,
    required this.home,
    required this.away,
    required this.originalDate,
    required this.venue,
    required this.matchDay,
    required this.status,
  });

  final int id;
  final MatchTeamMock home;
  final MatchTeamMock away;
  final DateTime originalDate;
  final String venue;
  final String matchDay;
  final PostponedStatus status;
}

/// Convierte una fecha en label legible: HOY, MAÑANA, AYER o
/// 'LUNES 12 DE MAYO'.
String matchDateLabel(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dt.year, dt.month, dt.day);
  final diff = target.difference(today).inDays;

  if (diff == 0) return 'HOY';
  if (diff == 1) return 'MAÑANA';
  if (diff == -1) return 'AYER';

  return DateFormat("EEEE d 'de' MMMM", 'es_CO').format(dt).toUpperCase();
}

abstract final class MockCalendarData {
  MockCalendarData._();

  // ─── Equipos reutilizados ──────────────────────────────────────────
  static const _laSalle = MatchTeamMock(
    id: 1,
    name: 'Cfe La Salle',
    shortName: 'LSL',
    primaryColor: Color(0xFFD68F03),
  );
  static const _robledo = MatchTeamMock(
    id: 2,
    name: 'Cfe Robledo',
    shortName: 'RBL',
    primaryColor: Color(0xFFE53935),
  );
  static const _centro = MatchTeamMock(
    id: 3,
    name: 'Cfe Centro',
    shortName: 'CTR',
    primaryColor: Color(0xFF1E88E5),
  );
  static const _norte = MatchTeamMock(
    id: 4,
    name: 'Cfe Norte',
    shortName: 'NTE',
    primaryColor: Color(0xFF43A047),
  );
  static const _sur = MatchTeamMock(
    id: 5,
    name: 'Cfe Sur',
    shortName: 'SUR',
    primaryColor: Color(0xFF8E24AA),
  );
  static const _oriente = MatchTeamMock(
    id: 6,
    name: 'Cfe Oriente',
    shortName: 'ORT',
    primaryColor: Color(0xFFFB8C00),
  );
  static const _occidente = MatchTeamMock(
    id: 7,
    name: 'Cfe Occidente',
    shortName: 'OCC',
    primaryColor: Color(0xFF00897B),
  );
  static const _aranjuez = MatchTeamMock(
    id: 8,
    name: 'Cfe Aranjuez',
    shortName: 'ARJ',
    primaryColor: Color(0xFFD81B60),
  );

  // ─── UPCOMING ──────────────────────────────────────────────────────
  static List<UpcomingMatchMock> get upcoming {
    final now = DateTime.now();
    return [
      UpcomingMatchMock(
        id: 101,
        home: _laSalle,
        away: _robledo,
        scheduledAt: now.add(const Duration(hours: 2)),
        venue: 'Cancha el Raizal #1',
        matchDay: 'Jornada 6',
        isLive: true,
        liveHomeScore: 1,
        liveAwayScore: 0,
        liveStatus: "1er Tiempo · 32'",
      ),
      UpcomingMatchMock(
        id: 102,
        home: _centro,
        away: _norte,
        scheduledAt: now.add(const Duration(hours: 5)),
        venue: 'Cancha el Raizal #2',
        matchDay: 'Jornada 6',
      ),
      UpcomingMatchMock(
        id: 103,
        home: _sur,
        away: _oriente,
        scheduledAt: now.add(const Duration(days: 1, hours: 2)),
        venue: 'Cancha el Raizal #1',
        matchDay: 'Jornada 6',
      ),
      UpcomingMatchMock(
        id: 104,
        home: _occidente,
        away: _aranjuez,
        scheduledAt: now.add(const Duration(days: 2, hours: 3)),
        venue: 'Cancha Bocagrande',
        matchDay: 'Jornada 6',
      ),
      UpcomingMatchMock(
        id: 105,
        home: _laSalle,
        away: _centro,
        scheduledAt: now.add(const Duration(days: 5)),
        venue: 'Cancha el Raizal #1',
        matchDay: 'Jornada 7',
      ),
    ];
  }

  // ─── FINISHED ──────────────────────────────────────────────────────
  static List<FinishedMatchMock> get finished {
    final now = DateTime.now();
    return [
      FinishedMatchMock(
        id: 201,
        home: _laSalle,
        away: _norte,
        homeScore: 3,
        awayScore: 1,
        playedAt: now.subtract(const Duration(days: 1, hours: 4)),
        venue: 'Cancha el Raizal #1',
        matchDay: 'Jornada 5',
        homeGoals: const [
          MatchGoalMock(playerName: 'L. Pérez', minute: 12),
          MatchGoalMock(playerName: 'M. López', minute: 35, isPenalty: true),
          MatchGoalMock(playerName: 'C. Díaz', minute: 67),
        ],
        awayGoals: const [
          MatchGoalMock(playerName: 'J. Gómez', minute: 78),
        ],
        homeYellows: 2,
        awayYellows: 3,
        awayReds: 1,
      ),
      FinishedMatchMock(
        id: 202,
        home: _robledo,
        away: _sur,
        homeScore: 2,
        awayScore: 2,
        playedAt: now.subtract(const Duration(days: 2, hours: 3)),
        venue: 'Cancha el Raizal #2',
        matchDay: 'Jornada 5',
        homeGoals: const [
          MatchGoalMock(playerName: 'A. Ruiz', minute: 22),
          MatchGoalMock(playerName: 'D. Cano', minute: 88),
        ],
        awayGoals: const [
          MatchGoalMock(playerName: 'P. Restrepo', minute: 14),
          MatchGoalMock(playerName: 'P. Restrepo', minute: 75),
        ],
        homeYellows: 1,
        awayYellows: 2,
      ),
      FinishedMatchMock(
        id: 203,
        home: _centro,
        away: _oriente,
        homeScore: 0,
        awayScore: 0,
        playedAt: now.subtract(const Duration(days: 3)),
        venue: 'Cancha Bocagrande',
        matchDay: 'Jornada 5',
        homeYellows: 4,
        awayYellows: 2,
        homeBlues: 1,
      ),
      FinishedMatchMock(
        id: 204,
        home: _occidente,
        away: _aranjuez,
        homeScore: 4,
        awayScore: 0,
        playedAt: now.subtract(const Duration(days: 4)),
        venue: 'Cancha el Raizal #1',
        matchDay: 'Jornada 4',
        homeGoals: const [
          MatchGoalMock(playerName: 'S. Mora', minute: 8),
          MatchGoalMock(playerName: 'S. Mora', minute: 31),
          MatchGoalMock(playerName: 'R. Vélez', minute: 44),
          MatchGoalMock(playerName: 'S. Mora', minute: 89),
        ],
        homeYellows: 1,
        awayYellows: 3,
      ),
    ];
  }

  // ─── POSTPONED / SUSPENDED ─────────────────────────────────────────
  static List<PostponedMatchMock> get postponed {
    final now = DateTime.now();
    return [
      PostponedMatchMock(
        id: 301,
        home: _laSalle,
        away: _occidente,
        originalDate: now.subtract(const Duration(days: 7)),
        venue: 'Cancha el Raizal #1',
        matchDay: 'Jornada 3',
        status: PostponedStatus.postponed,
      ),
      PostponedMatchMock(
        id: 302,
        home: _norte,
        away: _aranjuez,
        originalDate: now.subtract(const Duration(days: 12)),
        venue: 'Cancha Bocagrande',
        matchDay: 'Jornada 2',
        status: PostponedStatus.suspended,
      ),
    ];
  }
}
