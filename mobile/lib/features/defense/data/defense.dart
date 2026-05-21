import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/features/standings/data/standing.dart';
import 'package:torneo_leon_de_juda/shared/models/player.dart';

const _emptyGoalkeeper = Player(
  id: 0,
  firstName: '',
  lastName: '',
  team: TeamSummary(
    id: 0,
    name: '',
    shortName: '',
    primaryColor: Color(0xFF6D6D6D),
  ),
);

/// Entrada de la tabla "Valla Menos Vencida". El backend ya devuelve el rank
/// y los stats acumulados (goles en contra, partidos, vallas invictas).
class Defense {
  const Defense({
    required this.rank,
    required this.goalkeeper,
    required this.goalsAgainst,
    required this.matchesPlayed,
    required this.cleanSheets,
    this.yellowCards = 0,
    this.blueCards = 0,
    this.redCards = 0,
  });

  factory Defense.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] as Map<String, dynamic>?) ?? const {};
    final rawGk = json['goalkeeper'] as Map<String, dynamic>?;
    return Defense(
      rank: (json['rank'] as int?) ?? 0,
      goalkeeper:
          rawGk != null ? Player.fromJson(rawGk) : _emptyGoalkeeper,
      goalsAgainst: (stats['goals_against'] as int?) ?? 0,
      matchesPlayed: (stats['matches_played'] as int?) ?? 0,
      cleanSheets: (stats['clean_sheets'] as int?) ?? 0,
      yellowCards: (stats['yellow_cards'] as int?) ?? 0,
      blueCards: (stats['blue_cards'] as int?) ?? 0,
      redCards: (stats['red_cards'] as int?) ?? 0,
    );
  }

  final int rank;
  final Player goalkeeper;
  final int goalsAgainst;
  final int matchesPlayed;
  final int cleanSheets;
  final int yellowCards;
  final int blueCards;
  final int redCards;

  double get goalsAgainstPerMatch =>
      matchesPlayed == 0 ? 0 : goalsAgainst / matchesPlayed;

  double get cleanSheetRatio =>
      matchesPlayed == 0 ? 0 : cleanSheets / matchesPlayed;
}
