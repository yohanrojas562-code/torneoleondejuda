import 'package:flutter/material.dart';

/// Mock data de la tabla de posiciones. Se reemplaza por StandingsRepository
/// (API Laravel) en Step 19.

class TeamMock {
  const TeamMock({
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

class StandingMock {
  const StandingMock({
    required this.position,
    required this.team,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
    required this.form,
    this.fairPlayPoints = 0,
    this.group = 'A',
  });

  final int position;
  final TeamMock team;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final int fairPlayPoints;
  final String group;

  /// Ultimos 5 resultados, mas reciente al final.
  /// Valores: 'W' (win), 'D' (draw), 'L' (loss).
  final List<String> form;

  int get goalDifference => goalsFor - goalsAgainst;
}

abstract final class MockStandingsData {
  MockStandingsData._();

  static const tournamentName = 'Torneo León de Judá';
  static const seasonName = 'Temporada 2026';
  static const category = 'Categoría Libre';

  static const standings = <StandingMock>[
    StandingMock(
      position: 1,
      team: TeamMock(
        id: 1,
        name: 'Cfe La Salle',
        shortName: 'LSL',
        primaryColor: Color(0xFFD68F03),
      ),
      played: 8,
      won: 7,
      drawn: 1,
      lost: 0,
      goalsFor: 28,
      goalsAgainst: 6,
      points: 22,
      fairPlayPoints: -2,
      form: ['W', 'W', 'D', 'W', 'W'],
    ),
    StandingMock(
      position: 2,
      team: TeamMock(
        id: 2,
        name: 'Cfe Robledo',
        shortName: 'RBL',
        primaryColor: Color(0xFFE53935),
      ),
      played: 8,
      won: 6,
      drawn: 0,
      lost: 2,
      goalsFor: 22,
      goalsAgainst: 10,
      points: 18,
      fairPlayPoints: -5,
      form: ['W', 'L', 'W', 'W', 'W'],
    ),
    StandingMock(
      position: 3,
      team: TeamMock(
        id: 3,
        name: 'Cfe Centro',
        shortName: 'CTR',
        primaryColor: Color(0xFF1E88E5),
      ),
      played: 8,
      won: 5,
      drawn: 2,
      lost: 1,
      goalsFor: 19,
      goalsAgainst: 9,
      points: 17,
      fairPlayPoints: -3,
      form: ['D', 'W', 'W', 'D', 'W'],
    ),
    StandingMock(
      position: 4,
      team: TeamMock(
        id: 4,
        name: 'Cfe Norte',
        shortName: 'NTE',
        primaryColor: Color(0xFF43A047),
      ),
      played: 8,
      won: 4,
      drawn: 2,
      lost: 2,
      goalsFor: 15,
      goalsAgainst: 11,
      points: 14,
      fairPlayPoints: -4,
      form: ['W', 'W', 'L', 'D', 'D'],
    ),
    StandingMock(
      position: 5,
      team: TeamMock(
        id: 5,
        name: 'Cfe Sur',
        shortName: 'SUR',
        primaryColor: Color(0xFF8E24AA),
      ),
      played: 8,
      won: 4,
      drawn: 1,
      lost: 3,
      goalsFor: 14,
      goalsAgainst: 12,
      points: 13,
      fairPlayPoints: -6,
      form: ['L', 'W', 'W', 'L', 'W'],
    ),
    StandingMock(
      position: 6,
      team: TeamMock(
        id: 6,
        name: 'Cfe Oriente',
        shortName: 'ORT',
        primaryColor: Color(0xFFFB8C00),
      ),
      played: 8,
      won: 3,
      drawn: 3,
      lost: 2,
      goalsFor: 13,
      goalsAgainst: 12,
      points: 12,
      fairPlayPoints: -3,
      form: ['D', 'W', 'D', 'W', 'D'],
    ),
    StandingMock(
      position: 7,
      team: TeamMock(
        id: 7,
        name: 'Cfe Occidente',
        shortName: 'OCC',
        primaryColor: Color(0xFF00897B),
      ),
      played: 8,
      won: 3,
      drawn: 1,
      lost: 4,
      goalsFor: 11,
      goalsAgainst: 13,
      points: 10,
      fairPlayPoints: -7,
      form: ['L', 'L', 'W', 'D', 'W'],
    ),
    StandingMock(
      position: 8,
      team: TeamMock(
        id: 8,
        name: 'Cfe Aranjuez',
        shortName: 'ARJ',
        primaryColor: Color(0xFFD81B60),
      ),
      played: 8,
      won: 2,
      drawn: 3,
      lost: 3,
      goalsFor: 10,
      goalsAgainst: 14,
      points: 9,
      fairPlayPoints: -5,
      form: ['L', 'D', 'D', 'W', 'L'],
    ),
    StandingMock(
      position: 9,
      team: TeamMock(
        id: 9,
        name: 'Cfe Bocagrande',
        shortName: 'BCG',
        primaryColor: Color(0xFF6D4C41),
      ),
      played: 8,
      won: 2,
      drawn: 1,
      lost: 5,
      goalsFor: 9,
      goalsAgainst: 18,
      points: 7,
      fairPlayPoints: -8,
      form: ['L', 'L', 'L', 'W', 'L'],
    ),
    StandingMock(
      position: 10,
      team: TeamMock(
        id: 10,
        name: 'Cfe Manrique',
        shortName: 'MNR',
        primaryColor: Color(0xFF5E35B1),
      ),
      played: 8,
      won: 1,
      drawn: 1,
      lost: 6,
      goalsFor: 7,
      goalsAgainst: 23,
      points: 4,
      fairPlayPoints: -10,
      form: ['L', 'L', 'D', 'L', 'L'],
    ),
  ];
}
