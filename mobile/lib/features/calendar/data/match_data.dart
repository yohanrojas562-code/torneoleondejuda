import 'package:intl/intl.dart';
import 'package:torneo_leon_de_juda/features/standings/data/standing.dart';

typedef MatchTeam = TeamSummary;

/// Estado de un partido aplazado/cancelado/suspendido. Mapea al `status`
/// que llega del backend (postponed | suspended | cancelled).
enum PostponedStatus {
  postponed,
  suspended,
  cancelled;

  String get label => switch (this) {
        PostponedStatus.postponed => 'Aplazado',
        PostponedStatus.suspended => 'Suspendido',
        PostponedStatus.cancelled => 'Cancelado',
      };

  static PostponedStatus fromApi(String? status) {
    return switch (status) {
      'suspended' => PostponedStatus.suspended,
      'cancelled' => PostponedStatus.cancelled,
      _ => PostponedStatus.postponed,
    };
  }
}

/// Status del MatchEvent que viene en el resource embebido.
enum MatchEventType {
  goal,
  ownGoal,
  penaltyGoal,
  yellowCard,
  blueCard,
  redCard,
  secondYellow,
  other;

  static MatchEventType fromApi(String? type) {
    return switch (type) {
      'goal' => MatchEventType.goal,
      'own_goal' => MatchEventType.ownGoal,
      'penalty_goal' => MatchEventType.penaltyGoal,
      'yellow_card' => MatchEventType.yellowCard,
      'blue_card' => MatchEventType.blueCard,
      'red_card' => MatchEventType.redCard,
      'second_yellow' => MatchEventType.secondYellow,
      _ => MatchEventType.other,
    };
  }

  bool get isGoal => this == MatchEventType.goal ||
      this == MatchEventType.penaltyGoal ||
      this == MatchEventType.ownGoal;
}

class MatchGoal {
  const MatchGoal({
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

/// Partido completo. Una sola clase para upcoming/finished/postponed —
/// los flags `isLive`, `isFinished`, `isPostponed` te dicen qué mostrar.
class MatchData {
  const MatchData({
    required this.id,
    required this.status,
    required this.home,
    required this.away,
    required this.scheduledAt,
    required this.isLive,
    this.venue,
    this.matchDay,
    this.homeScore,
    this.awayScore,
    this.homeGoals = const [],
    this.awayGoals = const [],
    this.homeYellows = 0,
    this.homeBlues = 0,
    this.homeReds = 0,
    this.awayYellows = 0,
    this.awayBlues = 0,
    this.awayReds = 0,
  });

  factory MatchData.fromJson(Map<String, dynamic> json) {
    final home = TeamSummary.fromJson(
      (json['home_team'] as Map<String, dynamic>?) ?? const {},
    );
    final away = TeamSummary.fromJson(
      (json['away_team'] as Map<String, dynamic>?) ?? const {},
    );

    String? venue;
    final rawVenue = json['venue'];
    if (rawVenue is Map && rawVenue['name'] is String) {
      venue = rawVenue['name'] as String;
    }

    String? matchDay;
    final rawDay = json['match_day'];
    if (rawDay is Map && rawDay['name'] is String) {
      matchDay = rawDay['name'] as String;
    }

    final scheduledStr = json['scheduled_at'] as String?;
    final scheduledAt = scheduledStr != null
        ? DateTime.tryParse(scheduledStr)?.toLocal() ?? DateTime.now()
        : DateTime.now();

    // Parse events for goals + card counts. Backend filtra a los tipos
    // relevantes antes de enviarlos, pero los contamos defensivamente.
    final homeGoals = <MatchGoal>[];
    final awayGoals = <MatchGoal>[];
    var hY = 0;
    var hB = 0;
    var hR = 0;
    var aY = 0;
    var aB = 0;
    var aR = 0;

    final rawEvents = json['events'];
    if (rawEvents is List) {
      for (final e in rawEvents) {
        if (e is! Map<String, dynamic>) continue;
        final type = MatchEventType.fromApi(e['type'] as String?);
        final teamId = e['team_id'] as int?;
        final minute = (e['minute'] as int?) ?? 0;
        final playerJson = e['player'] as Map<String, dynamic>?;
        final playerName = playerJson != null
            ? '${playerJson['first_name'] ?? ''} ${playerJson['last_name'] ?? ''}'
                .trim()
            : '';

        final isHome = teamId == home.id;
        if (type.isGoal) {
          final goal = MatchGoal(
            playerName: playerName,
            minute: minute,
            isPenalty: type == MatchEventType.penaltyGoal,
            isOwnGoal: type == MatchEventType.ownGoal,
          );
          // Autogol: se cuenta para el equipo contrario
          final goalForHome = type == MatchEventType.ownGoal ? !isHome : isHome;
          if (goalForHome) {
            homeGoals.add(goal);
          } else {
            awayGoals.add(goal);
          }
        } else if (type == MatchEventType.yellowCard) {
          if (isHome) {
            hY++;
          } else {
            aY++;
          }
        } else if (type == MatchEventType.blueCard) {
          if (isHome) {
            hB++;
          } else {
            aB++;
          }
        } else if (type == MatchEventType.redCard ||
            type == MatchEventType.secondYellow) {
          if (isHome) {
            hR++;
          } else {
            aR++;
          }
        }
      }
    }

    // Tarjetas también vienen agregadas como campos de top-level del Match.
    // Si están presentes y son > 0, prefieren a los conteos por evento.
    int prefer(int fromTop, int fromEvents) =>
        fromTop > 0 ? fromTop : fromEvents;

    return MatchData(
      id: (json['id'] as int?) ?? 0,
      status: (json['status'] as String?) ?? 'scheduled',
      isLive: (json['is_live'] as bool?) ?? false,
      home: home,
      away: away,
      scheduledAt: scheduledAt,
      venue: venue,
      matchDay: matchDay,
      homeScore: json['home_score'] as int?,
      awayScore: json['away_score'] as int?,
      homeGoals: List.unmodifiable(homeGoals),
      awayGoals: List.unmodifiable(awayGoals),
      homeYellows: prefer((json['home_yellow_cards'] as int?) ?? 0, hY),
      homeBlues: prefer((json['home_blue_cards'] as int?) ?? 0, hB),
      homeReds: prefer((json['home_red_cards'] as int?) ?? 0, hR),
      awayYellows: prefer((json['away_yellow_cards'] as int?) ?? 0, aY),
      awayBlues: prefer((json['away_blue_cards'] as int?) ?? 0, aB),
      awayReds: prefer((json['away_red_cards'] as int?) ?? 0, aR),
    );
  }

  final int id;
  final String status;
  final bool isLive;
  final TeamSummary home;
  final TeamSummary away;
  final DateTime scheduledAt;
  final String? venue;
  final String? matchDay;
  final int? homeScore;
  final int? awayScore;
  final List<MatchGoal> homeGoals;
  final List<MatchGoal> awayGoals;
  final int homeYellows;
  final int homeBlues;
  final int homeReds;
  final int awayYellows;
  final int awayBlues;
  final int awayReds;

  bool get isFinished => status == 'finished';
  bool get isPostponed =>
      status == 'postponed' ||
      status == 'suspended' ||
      status == 'cancelled';

  PostponedStatus get postponedStatus => PostponedStatus.fromApi(status);

  /// Texto del estado en vivo. Usado en upcoming_match_card cuando isLive.
  String? get liveStatusLabel {
    return switch (status) {
      'first_half' => '1er Tiempo',
      'halftime' => 'Descanso',
      'second_half' => '2do Tiempo',
      'extra_time' => 'Alargue',
      'penalties' => 'Penales',
      'warmup' => 'Calentamiento',
      _ => null,
    };
  }

  bool get hasGoals => homeGoals.isNotEmpty || awayGoals.isNotEmpty;
  int get totalYellows => homeYellows + awayYellows;
  int get totalBlues => homeBlues + awayBlues;
  int get totalReds => homeReds + awayReds;
  bool get hasCards => totalYellows + totalBlues + totalReds > 0;
}

/// Snapshot del Calendario con las 3 listas.
class CalendarData {
  const CalendarData({
    required this.upcoming,
    required this.finished,
    required this.postponed,
  });

  final List<MatchData> upcoming;
  final List<MatchData> finished;
  final List<MatchData> postponed;
}

/// Convierte una fecha en label legible: HOY / MAÑANA / AYER /
/// "LUNES 12 DE MAYO".
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
