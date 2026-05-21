import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/features/standings/data/standing.dart';
import 'package:torneo_leon_de_juda/shared/models/player.dart';

const _emptyPlayer = Player(
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

/// Entrada del ranking de Goleadores. El rank viene del backend (ya
/// asignado en orden descendente por goles).
class Scorer {
  const Scorer({
    required this.rank,
    required this.player,
    required this.goals,
    required this.matchesPlayed,
    this.yellowCards = 0,
    this.blueCards = 0,
    this.redCards = 0,
  });

  factory Scorer.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] as Map<String, dynamic>?) ?? const {};
    final rawPlayer = json['player'] as Map<String, dynamic>?;
    return Scorer(
      rank: (json['rank'] as int?) ?? 0,
      player: rawPlayer != null ? Player.fromJson(rawPlayer) : _emptyPlayer,
      goals: (stats['goals'] as int?) ?? 0,
      matchesPlayed: (stats['matches_played'] as int?) ?? 0,
      yellowCards: (stats['yellow_cards'] as int?) ?? 0,
      blueCards: (stats['blue_cards'] as int?) ?? 0,
      redCards: (stats['red_cards'] as int?) ?? 0,
    );
  }

  final int rank;
  final Player player;
  final int goals;
  final int matchesPlayed;
  final int yellowCards;
  final int blueCards;
  final int redCards;

  /// Promedio de goles por partido.
  double get goalsPerMatch => matchesPlayed == 0 ? 0 : goals / matchesPlayed;
}
