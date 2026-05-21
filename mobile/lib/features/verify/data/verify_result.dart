import 'package:torneo_leon_de_juda/features/standings/data/standing.dart';

/// Estado del jugador devuelto por el endpoint `/api/v1/verify`.
enum VerifyStatus {
  approved,
  suspended,
  unregistered,
  expired;

  String get label {
    return switch (this) {
      VerifyStatus.approved => 'APROBADO',
      VerifyStatus.suspended => 'SUSPENDIDO',
      VerifyStatus.unregistered => 'NO INSCRITO',
      VerifyStatus.expired => 'CARNET VENCIDO',
    };
  }

  bool get isApproved => this == VerifyStatus.approved;

  static VerifyStatus fromApi(String? status) {
    return switch (status) {
      'approved' => VerifyStatus.approved,
      'suspended' => VerifyStatus.suspended,
      'expired' => VerifyStatus.expired,
      _ => VerifyStatus.unregistered,
    };
  }
}

/// Resultado del Validador. Cuando el servidor responde `result: null` la app
/// muestra el estado "no encontrado" — el repositorio devuelve `null` en ese
/// caso, no instancia esta clase.
class VerifyResult {
  const VerifyResult({
    required this.firstName,
    required this.lastName,
    required this.document,
    required this.status,
    this.team,
    this.photoUrl,
    this.jerseyNumber,
    this.position,
    this.church,
    this.reason,
  });

  factory VerifyResult.fromJson(Map<String, dynamic> json) {
    final status = VerifyStatus.fromApi(json['status'] as String?);
    final reason = json['reason'] as String?;
    final player = (json['player'] as Map<String, dynamic>?) ?? const {};

    TeamSummary? team;
    final rawTeam = player['team'];
    if (rawTeam is Map<String, dynamic>) {
      team = TeamSummary.fromJson(rawTeam);
    }

    return VerifyResult(
      firstName: (player['first_name'] as String?) ?? '',
      lastName: (player['last_name'] as String?) ?? '',
      document: (player['document'] as String?) ?? '',
      status: status,
      team: team,
      photoUrl: player['photo_url'] as String?,
      jerseyNumber: player['jersey_number'] as int?,
      position: player['position'] as String?,
      church: player['church'] as String?,
      reason: reason,
    );
  }

  final String firstName;
  final String lastName;
  final String document;
  final VerifyStatus status;
  final TeamSummary? team;
  final String? photoUrl;
  final int? jerseyNumber;
  final String? position;
  final String? church;
  final String? reason;

  String get fullName => '$firstName $lastName'.trim();
}
