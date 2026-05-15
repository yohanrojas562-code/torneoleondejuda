import 'package:flutter/material.dart';

/// Mock data de Goleadores. Reemplazado por ScorersRepository en Step 19.

class ScorerTeamMock {
  const ScorerTeamMock({
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

class PlayerMock {
  const PlayerMock({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.team,
    this.photoUrl,
    this.jerseyNumber,
    this.position,
    this.church,
  });

  final int id;
  final String firstName;
  final String lastName;
  final ScorerTeamMock team;
  final String? photoUrl;
  final int? jerseyNumber;
  final String? position;
  final String? church;

  String get fullName => '$firstName $lastName';

  /// Nombre corto tipo "L. Pérez" para listas estrechas.
  String get shortName {
    final initial = firstName.isNotEmpty
        ? firstName.characters.first.toUpperCase()
        : '';
    return '$initial. $lastName';
  }
}

class ScorerMock {
  const ScorerMock({
    required this.rank,
    required this.player,
    required this.goals,
    required this.matchesPlayed,
    this.yellowCards = 0,
    this.blueCards = 0,
    this.redCards = 0,
  });

  final int rank;
  final PlayerMock player;
  final int goals;
  final int matchesPlayed;
  final int yellowCards;
  final int blueCards;
  final int redCards;

  /// Promedio de goles por partido.
  double get goalsPerMatch =>
      matchesPlayed == 0 ? 0 : goals / matchesPlayed;
}

abstract final class MockScorersData {
  MockScorersData._();

  // ─── Equipos ───────────────────────────────────────────────────────
  static const _laSalle = ScorerTeamMock(
    id: 1,
    name: 'Cfe La Salle',
    shortName: 'LSL',
    primaryColor: Color(0xFFD68F03),
  );
  static const _robledo = ScorerTeamMock(
    id: 2,
    name: 'Cfe Robledo',
    shortName: 'RBL',
    primaryColor: Color(0xFFE53935),
  );
  static const _centro = ScorerTeamMock(
    id: 3,
    name: 'Cfe Centro',
    shortName: 'CTR',
    primaryColor: Color(0xFF1E88E5),
  );
  static const _norte = ScorerTeamMock(
    id: 4,
    name: 'Cfe Norte',
    shortName: 'NTE',
    primaryColor: Color(0xFF43A047),
  );
  static const _sur = ScorerTeamMock(
    id: 5,
    name: 'Cfe Sur',
    shortName: 'SUR',
    primaryColor: Color(0xFF8E24AA),
  );
  static const _occidente = ScorerTeamMock(
    id: 7,
    name: 'Cfe Occidente',
    shortName: 'OCC',
    primaryColor: Color(0xFF00897B),
  );
  static const _aranjuez = ScorerTeamMock(
    id: 8,
    name: 'Cfe Aranjuez',
    shortName: 'ARJ',
    primaryColor: Color(0xFFD81B60),
  );
  static const _bocagrande = ScorerTeamMock(
    id: 9,
    name: 'Cfe Bocagrande',
    shortName: 'BCG',
    primaryColor: Color(0xFF6D4C41),
  );

  // ─── Scorers (sorted by goals desc) ────────────────────────────────
  static const scorers = <ScorerMock>[
    ScorerMock(
      rank: 1,
      player: PlayerMock(
        id: 101,
        firstName: 'Luis',
        lastName: 'Pérez',
        team: _laSalle,
        jerseyNumber: 10,
        position: 'delantero',
        church: 'Centro de Fe La Salle',
      ),
      goals: 15,
      matchesPlayed: 8,
      yellowCards: 2,
    ),
    ScorerMock(
      rank: 2,
      player: PlayerMock(
        id: 102,
        firstName: 'Mateo',
        lastName: 'López',
        team: _laSalle,
        jerseyNumber: 9,
        position: 'delantero',
        church: 'Centro de Fe La Salle',
      ),
      goals: 12,
      matchesPlayed: 8,
      yellowCards: 1,
      blueCards: 1,
    ),
    ScorerMock(
      rank: 3,
      player: PlayerMock(
        id: 103,
        firstName: 'Pablo',
        lastName: 'Restrepo',
        team: _sur,
        jerseyNumber: 7,
        position: 'mediocampista',
        church: 'Centro de Fe Sur',
      ),
      goals: 10,
      matchesPlayed: 8,
      yellowCards: 3,
    ),
    ScorerMock(
      rank: 4,
      player: PlayerMock(
        id: 104,
        firstName: 'Sergio',
        lastName: 'Mora',
        team: _occidente,
        jerseyNumber: 11,
        position: 'delantero',
      ),
      goals: 9,
      matchesPlayed: 7,
      yellowCards: 2,
      redCards: 1,
    ),
    ScorerMock(
      rank: 5,
      player: PlayerMock(
        id: 105,
        firstName: 'Carlos',
        lastName: 'Díaz',
        team: _laSalle,
        jerseyNumber: 8,
        position: 'mediocampista',
        church: 'Centro de Fe La Salle',
      ),
      goals: 7,
      matchesPlayed: 8,
      yellowCards: 1,
    ),
    ScorerMock(
      rank: 6,
      player: PlayerMock(
        id: 106,
        firstName: 'Juan',
        lastName: 'Gómez',
        team: _norte,
        jerseyNumber: 9,
        position: 'delantero',
      ),
      goals: 6,
      matchesPlayed: 7,
      yellowCards: 2,
    ),
    ScorerMock(
      rank: 7,
      player: PlayerMock(
        id: 107,
        firstName: 'Andrés',
        lastName: 'Ruiz',
        team: _robledo,
        jerseyNumber: 7,
        position: 'mediocampista',
      ),
      goals: 5,
      matchesPlayed: 8,
      yellowCards: 1,
      blueCards: 1,
    ),
    ScorerMock(
      rank: 8,
      player: PlayerMock(
        id: 108,
        firstName: 'Diego',
        lastName: 'Cano',
        team: _robledo,
        jerseyNumber: 11,
        position: 'delantero',
      ),
      goals: 5,
      matchesPlayed: 7,
    ),
    ScorerMock(
      rank: 9,
      player: PlayerMock(
        id: 109,
        firstName: 'Ricardo',
        lastName: 'Vélez',
        team: _occidente,
        jerseyNumber: 10,
        position: 'mediocampista',
      ),
      goals: 4,
      matchesPlayed: 7,
      yellowCards: 1,
    ),
    ScorerMock(
      rank: 10,
      player: PlayerMock(
        id: 110,
        firstName: 'Felipe',
        lastName: 'Martínez',
        team: _centro,
        jerseyNumber: 8,
        position: 'defensa',
      ),
      goals: 4,
      matchesPlayed: 8,
      yellowCards: 3,
    ),
    ScorerMock(
      rank: 11,
      player: PlayerMock(
        id: 111,
        firstName: 'Esteban',
        lastName: 'Hernández',
        team: _aranjuez,
        jerseyNumber: 9,
        position: 'delantero',
      ),
      goals: 3,
      matchesPlayed: 7,
    ),
    ScorerMock(
      rank: 12,
      player: PlayerMock(
        id: 112,
        firstName: 'Óscar',
        lastName: 'Castillo',
        team: _bocagrande,
        jerseyNumber: 11,
        position: 'delantero',
      ),
      goals: 3,
      matchesPlayed: 8,
      yellowCards: 2,
    ),
  ];
}
