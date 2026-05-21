import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/features/standings/data/standing.dart' show TeamSummary;

/// Jugador (datos públicos). Compartido entre scorers, defense y verify
/// — cualquier feature que reciba un `PlayerResource` del backend.
class Player {
  const Player({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.team,
    this.uniqueCode,
    this.photoUrl,
    this.jerseyNumber,
    this.position,
    this.goalkeeperType,
    this.church,
    this.isCaptain = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    final rawTeam = json['team'];
    final team = rawTeam is Map<String, dynamic>
        ? TeamSummary.fromJson(rawTeam)
        : const TeamSummary(
            id: 0,
            name: '',
            shortName: '',
            primaryColor: Color(0xFF6D6D6D),
          );

    return Player(
      id: (json['id'] as int?) ?? 0,
      uniqueCode: json['unique_code'] as String?,
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
      jerseyNumber: json['jersey_number'] as int?,
      position: json['position'] as String?,
      goalkeeperType: json['goalkeeper_type'] as String?,
      church: json['church'] as String?,
      isCaptain: (json['is_captain'] as bool?) ?? false,
      team: team,
    );
  }

  final int id;
  final String? uniqueCode;
  final String firstName;
  final String lastName;
  final TeamSummary team;
  final String? photoUrl;
  final int? jerseyNumber;
  final String? position;
  final String? goalkeeperType;
  final String? church;
  final bool isCaptain;

  String get fullName => '$firstName $lastName'.trim();

  /// "L. Pérez" — útil para listas estrechas.
  String get shortName {
    final initial =
        firstName.isNotEmpty ? firstName.characters.first.toUpperCase() : '';
    return '$initial. $lastName'.trim();
  }
}
