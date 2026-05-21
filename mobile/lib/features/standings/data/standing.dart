import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/utils/color_utils.dart';

/// Equipo (datos visuales) embebido en standings/scorers/defense.
class TeamSummary {
  const TeamSummary({
    required this.id,
    required this.name,
    required this.shortName,
    required this.primaryColor,
    this.logoUrl,
  });

  factory TeamSummary.fromJson(Map<String, dynamic> json) {
    return TeamSummary(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      shortName: (json['short_name'] as String?) ?? '',
      primaryColor: ColorUtils.fromHex(
        json['primary_color'] as String?,
        fallback: ColorUtils.deterministicFromString(
          (json['name'] as String?) ?? '',
        ),
      ),
      logoUrl: json['logo_url'] as String?,
    );
  }

  final int id;
  final String name;
  final String shortName;
  final Color primaryColor;
  final String? logoUrl;
}

/// Fila de la tabla de posiciones.
class Standing {
  const Standing({
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
    this.group,
  });

  factory Standing.fromJson(Map<String, dynamic> json) {
    final rawForm = json['form'];
    final form = <String>[];
    if (rawForm is List) {
      for (final f in rawForm) {
        if (f is String && f.isNotEmpty) {
          form.add(f.toUpperCase());
        }
      }
    }
    final rawGroup = json['group'];
    String? groupName;
    if (rawGroup is Map && rawGroup['name'] is String) {
      groupName = rawGroup['name'] as String;
    }
    return Standing(
      position: (json['position'] as int?) ?? 0,
      team: TeamSummary.fromJson(
        (json['team'] as Map<String, dynamic>?) ?? const {},
      ),
      played: (json['played'] as int?) ?? 0,
      won: (json['won'] as int?) ?? 0,
      drawn: (json['drawn'] as int?) ?? 0,
      lost: (json['lost'] as int?) ?? 0,
      goalsFor: (json['goals_for'] as int?) ?? 0,
      goalsAgainst: (json['goals_against'] as int?) ?? 0,
      points: (json['points'] as int?) ?? 0,
      fairPlayPoints: (json['fair_play_points'] as int?) ?? 0,
      form: List.unmodifiable(form),
      group: groupName,
    );
  }

  final int position;
  final TeamSummary team;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final int fairPlayPoints;
  final List<String> form;
  final String? group;

  int get goalDifference => goalsFor - goalsAgainst;
}

/// Snapshot completo de la pantalla Standings: temporada activa + filas.
class StandingsData {
  const StandingsData({
    required this.standings,
    this.seasonName,
    this.tournamentName,
  });

  final List<Standing> standings;
  final String? seasonName;
  final String? tournamentName;

  bool get isEmpty => standings.isEmpty;
}
