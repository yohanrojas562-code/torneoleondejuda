import 'package:flutter/material.dart';

/// Mock data de Valla Menos Vencida. Reemplazado por DefenseRepository en
/// Step 19. Solo porteros titulares (un titular por equipo).

class DefenseTeamMock {
  const DefenseTeamMock({
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

class GoalkeeperMock {
  const GoalkeeperMock({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.team,
    this.photoUrl,
    this.jerseyNumber,
    this.church,
  });

  final int id;
  final String firstName;
  final String lastName;
  final DefenseTeamMock team;
  final String? photoUrl;
  final int? jerseyNumber;
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

class DefenseMock {
  const DefenseMock({
    required this.rank,
    required this.goalkeeper,
    required this.goalsAgainst,
    required this.matchesPlayed,
    required this.cleanSheets,
    this.yellowCards = 0,
    this.blueCards = 0,
    this.redCards = 0,
  });

  final int rank;
  final GoalkeeperMock goalkeeper;
  final int goalsAgainst;
  final int matchesPlayed;
  final int cleanSheets;
  final int yellowCards;
  final int blueCards;
  final int redCards;

  /// Promedio de goles encajados por partido (menor = mejor).
  double get goalsAgainstPerMatch =>
      matchesPlayed == 0 ? 0 : goalsAgainst / matchesPlayed;

  /// % de partidos con valla invicta.
  double get cleanSheetRatio =>
      matchesPlayed == 0 ? 0 : cleanSheets / matchesPlayed;
}

abstract final class MockDefenseData {
  MockDefenseData._();

  // ─── Equipos ───────────────────────────────────────────────────────
  static const _laSalle = DefenseTeamMock(
    id: 1,
    name: 'Cfe La Salle',
    shortName: 'LSL',
    primaryColor: Color(0xFFD68F03),
  );
  static const _robledo = DefenseTeamMock(
    id: 2,
    name: 'Cfe Robledo',
    shortName: 'RBL',
    primaryColor: Color(0xFFE53935),
  );
  static const _centro = DefenseTeamMock(
    id: 3,
    name: 'Cfe Centro',
    shortName: 'CTR',
    primaryColor: Color(0xFF1E88E5),
  );
  static const _norte = DefenseTeamMock(
    id: 4,
    name: 'Cfe Norte',
    shortName: 'NTE',
    primaryColor: Color(0xFF43A047),
  );
  static const _sur = DefenseTeamMock(
    id: 5,
    name: 'Cfe Sur',
    shortName: 'SUR',
    primaryColor: Color(0xFF8E24AA),
  );
  static const _oriente = DefenseTeamMock(
    id: 6,
    name: 'Cfe Oriente',
    shortName: 'ORI',
    primaryColor: Color(0xFFF4511E),
  );
  static const _occidente = DefenseTeamMock(
    id: 7,
    name: 'Cfe Occidente',
    shortName: 'OCC',
    primaryColor: Color(0xFF00897B),
  );
  static const _aranjuez = DefenseTeamMock(
    id: 8,
    name: 'Cfe Aranjuez',
    shortName: 'ARJ',
    primaryColor: Color(0xFFD81B60),
  );
  static const _bocagrande = DefenseTeamMock(
    id: 9,
    name: 'Cfe Bocagrande',
    shortName: 'BCG',
    primaryColor: Color(0xFF6D4C41),
  );
  static const _olaya = DefenseTeamMock(
    id: 10,
    name: 'Cfe Olaya',
    shortName: 'OLA',
    primaryColor: Color(0xFF3949AB),
  );

  // ─── Goalkeepers titulares (sorted by goalsAgainst asc, ties by
  //     cleanSheets desc) ────────────────────────────────────────────
  static const defenses = <DefenseMock>[
    DefenseMock(
      rank: 1,
      goalkeeper: GoalkeeperMock(
        id: 201,
        firstName: 'David',
        lastName: 'Quintero',
        team: _laSalle,
        jerseyNumber: 1,
        church: 'Centro de Fe La Salle',
      ),
      goalsAgainst: 3,
      matchesPlayed: 8,
      cleanSheets: 5,
    ),
    DefenseMock(
      rank: 2,
      goalkeeper: GoalkeeperMock(
        id: 202,
        firstName: 'Andrés',
        lastName: 'Cabrera',
        team: _sur,
        jerseyNumber: 1,
        church: 'Centro de Fe Sur',
      ),
      goalsAgainst: 5,
      matchesPlayed: 8,
      cleanSheets: 4,
      yellowCards: 1,
    ),
    DefenseMock(
      rank: 3,
      goalkeeper: GoalkeeperMock(
        id: 203,
        firstName: 'Camilo',
        lastName: 'Restrepo',
        team: _occidente,
        jerseyNumber: 12,
        church: 'Centro de Fe Occidente',
      ),
      goalsAgainst: 6,
      matchesPlayed: 7,
      cleanSheets: 3,
    ),
    DefenseMock(
      rank: 4,
      goalkeeper: GoalkeeperMock(
        id: 204,
        firstName: 'Julián',
        lastName: 'Bedoya',
        team: _norte,
        jerseyNumber: 1,
      ),
      goalsAgainst: 7,
      matchesPlayed: 7,
      cleanSheets: 3,
      yellowCards: 1,
    ),
    DefenseMock(
      rank: 5,
      goalkeeper: GoalkeeperMock(
        id: 205,
        firstName: 'Sebastián',
        lastName: 'Marín',
        team: _centro,
        jerseyNumber: 12,
      ),
      goalsAgainst: 8,
      matchesPlayed: 8,
      cleanSheets: 2,
      blueCards: 1,
    ),
    DefenseMock(
      rank: 6,
      goalkeeper: GoalkeeperMock(
        id: 206,
        firstName: 'Iván',
        lastName: 'Mendoza',
        team: _aranjuez,
        jerseyNumber: 1,
      ),
      goalsAgainst: 9,
      matchesPlayed: 7,
      cleanSheets: 2,
    ),
    DefenseMock(
      rank: 7,
      goalkeeper: GoalkeeperMock(
        id: 207,
        firstName: 'Cristian',
        lastName: 'Galindo',
        team: _robledo,
        jerseyNumber: 1,
      ),
      goalsAgainst: 10,
      matchesPlayed: 8,
      cleanSheets: 1,
      yellowCards: 2,
    ),
    DefenseMock(
      rank: 8,
      goalkeeper: GoalkeeperMock(
        id: 208,
        firstName: 'Mauricio',
        lastName: 'Salazar',
        team: _bocagrande,
        jerseyNumber: 12,
      ),
      goalsAgainst: 11,
      matchesPlayed: 8,
      cleanSheets: 1,
    ),
    DefenseMock(
      rank: 9,
      goalkeeper: GoalkeeperMock(
        id: 209,
        firstName: 'Jorge',
        lastName: 'Patiño',
        team: _oriente,
        jerseyNumber: 1,
      ),
      goalsAgainst: 13,
      matchesPlayed: 7,
      cleanSheets: 1,
      redCards: 1,
    ),
    DefenseMock(
      rank: 10,
      goalkeeper: GoalkeeperMock(
        id: 210,
        firstName: 'Néstor',
        lastName: 'Vargas',
        team: _olaya,
        jerseyNumber: 1,
      ),
      goalsAgainst: 15,
      matchesPlayed: 8,
      cleanSheets: 0,
      yellowCards: 1,
    ),
  ];
}
