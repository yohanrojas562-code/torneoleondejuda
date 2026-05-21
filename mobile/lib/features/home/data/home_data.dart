import 'package:torneo_leon_de_juda/features/calendar/data/match_data.dart';

/// Info de temporada activa para el hero del Home. Se compone de campos
/// del endpoint `/api/v1/home`.
class ActiveSeason {
  const ActiveSeason({
    required this.tournamentName,
    required this.seasonName,
    required this.statusLabel,
    required this.isLive,
    required this.liveMatchesToday,
    this.tournamentLogoUrl,
  });

  factory ActiveSeason.fromJson(
    Map<String, dynamic> season, {
    required int liveMatchesToday,
  }) {
    final tournament = season['tournament'];
    var tournamentName = 'Torneo León de Judá';
    String? logo;
    if (tournament is Map<String, dynamic>) {
      tournamentName = (tournament['name'] as String?) ?? tournamentName;
      logo = tournament['logo'] as String?;
    }

    final status = (season['status'] as String?) ?? '';
    return ActiveSeason(
      tournamentName: tournamentName,
      seasonName: (season['name'] as String?) ?? '',
      statusLabel: _humanStatus(status),
      isLive: liveMatchesToday > 0,
      liveMatchesToday: liveMatchesToday,
      tournamentLogoUrl: logo,
    );
  }

  final String tournamentName;
  final String seasonName;
  final String statusLabel;
  final bool isLive;
  final int liveMatchesToday;
  final String? tournamentLogoUrl;

  static String _humanStatus(String status) {
    return switch (status) {
      'registration' => 'Inscripciones',
      'group_stage' => 'Fase de grupos',
      'knockout' => 'Eliminatorias',
      'finished' => 'Finalizada',
      _ => 'En curso',
    };
  }
}

class HomeData {
  const HomeData({
    required this.upcomingMatches,
    this.activeSeason,
  });

  final ActiveSeason? activeSeason;
  final List<MatchData> upcomingMatches;
}
