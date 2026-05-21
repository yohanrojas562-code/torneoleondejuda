import 'package:torneo_leon_de_juda/features/calendar/data/match_data.dart';
import 'package:torneo_leon_de_juda/features/standings/data/standing.dart';

/// Snapshot del endpoint `/api/v1/my/dashboard`. El campo `view` decide
/// qué widgets renderiza la app: admin | lider | capitan | arbitro | generic.
class DashboardData {
  const DashboardData({
    required this.view,
    this.activeSeasonName,
    this.tournamentName,
    this.counts,
    this.teams = const [],
    this.upcomingMatches = const [],
    this.playerCounts,
    this.webAdminUrl,
    this.message,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final season = json['active_season'];
    String? seasonName;
    String? tournamentName;
    if (season is Map<String, dynamic>) {
      seasonName = season['name'] as String?;
      final t = season['tournament'];
      if (t is Map<String, dynamic>) {
        tournamentName = t['name'] as String?;
      }
    }

    Map<String, int>? counts;
    final rawCounts = json['counts'];
    if (rawCounts is Map) {
      counts = {};
      for (final entry in rawCounts.entries) {
        if (entry.key is String && entry.value is int) {
          counts[entry.key as String] = entry.value as int;
        } else if (entry.key is String && entry.value is num) {
          counts[entry.key as String] = (entry.value as num).toInt();
        }
      }
    }

    final teams = <TeamSummary>[];
    final rawTeams = json['teams'];
    if (rawTeams is List) {
      for (final t in rawTeams) {
        if (t is Map<String, dynamic>) {
          teams.add(TeamSummary.fromJson(t));
        }
      }
    }

    final matches = <MatchData>[];
    final rawMatches = json['upcoming_matches'];
    if (rawMatches is List) {
      for (final m in rawMatches) {
        if (m is Map<String, dynamic>) {
          matches.add(MatchData.fromJson(m));
        }
      }
    }

    Map<String, int>? playerCounts;
    final rawPc = json['player_counts'];
    if (rawPc is Map) {
      playerCounts = {};
      for (final entry in rawPc.entries) {
        if (entry.key is String && entry.value is num) {
          playerCounts[entry.key as String] = (entry.value as num).toInt();
        }
      }
    }

    return DashboardData(
      view: (json['view'] as String?) ?? 'generic',
      activeSeasonName: seasonName,
      tournamentName: tournamentName,
      counts: counts,
      teams: teams,
      upcomingMatches: matches,
      playerCounts: playerCounts,
      webAdminUrl: json['web_admin_url'] as String?,
      message: json['message'] as String?,
    );
  }

  final String view;
  final String? activeSeasonName;
  final String? tournamentName;
  final Map<String, int>? counts;
  final List<TeamSummary> teams;
  final List<MatchData> upcomingMatches;
  final Map<String, int>? playerCounts;
  final String? webAdminUrl;
  final String? message;
}

/// Resultado de `/api/v1/my/matches`.
class MyMatchesData {
  const MyMatchesData({
    required this.upcoming,
    required this.finished,
    required this.postponed,
  });

  factory MyMatchesData.fromJson(Map<String, dynamic> json) {
    List<MatchData> parse(Object? raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(MatchData.fromJson)
          .toList(growable: false);
    }

    return MyMatchesData(
      upcoming: parse(json['upcoming']),
      finished: parse(json['finished']),
      postponed: parse(json['postponed']),
    );
  }

  final List<MatchData> upcoming;
  final List<MatchData> finished;
  final List<MatchData> postponed;
}
