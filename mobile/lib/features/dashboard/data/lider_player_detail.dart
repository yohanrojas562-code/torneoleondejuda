import 'package:torneo_leon_de_juda/features/standings/data/standing.dart';

/// Snapshot del endpoint `GET /api/v1/my/players/{id}` — datos completos
/// del jugador, archivos, stats y permisos (lock-when-approved).
///
/// Este modelo es para el flujo "mi equipo" del líder. NO se usa para los
/// listados públicos (esos siguen usando el `Player` compartido).
class LiderPlayerDetail {
  const LiderPlayerDetail({
    required this.id,
    required this.uniqueCode,
    required this.firstName,
    required this.lastName,
    required this.documentType,
    required this.documentNumber,
    required this.bloodType,
    required this.birthDate,
    required this.team,
    required this.jerseyNumber,
    required this.position,
    required this.isCaptain,
    required this.isActive,
    required this.hasEps,
    required this.specialRequest,
    required this.imageConsent,
    required this.habeasData,
    required this.approvalStatus,
    required this.stats,
    required this.lockedWhenApproved,
    this.fullName = '',
    this.age,
    this.isMinor = false,
    this.church,
    this.jerseyName,
    this.goalkeeperType,
    this.height,
    this.weight,
    this.photoUrl,
    this.documentFileUrl,
    this.epsCertificateUrl,
    this.noEpsConsentUrl,
    this.parentalConsentUrl,
    this.specialRequestReason,
    this.rejectionReason,
    this.lockMessage,
  });

  factory LiderPlayerDetail.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] as Map<String, dynamic>?) ?? const {};
    final perms = (json['permissions'] as Map<String, dynamic>?) ?? const {};
    final rawTeam = json['team'];
    return LiderPlayerDetail(
      id: json['id'] as int,
      uniqueCode: (json['unique_code'] as String?) ?? '',
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      documentType: (json['document_type'] as String?) ?? 'CC',
      documentNumber: (json['document_number'] as String?) ?? '',
      bloodType: (json['blood_type'] as String?) ?? 'O+',
      birthDate: json['birth_date'] as String? ?? '',
      age: json['age'] as int?,
      isMinor: (json['is_minor'] as bool?) ?? false,
      church: json['church'] as String?,
      team: rawTeam is Map<String, dynamic>
          ? TeamSummary.fromJson(rawTeam)
          : null,
      jerseyNumber: (json['jersey_number'] as int?) ?? 0,
      jerseyName: json['jersey_name'] as String?,
      position: (json['position'] as String?) ?? 'mediocampista',
      goalkeeperType: json['goalkeeper_type'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      isCaptain: (json['is_captain'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      photoUrl: json['photo_url'] as String?,
      documentFileUrl: json['document_file_url'] as String?,
      epsCertificateUrl: json['eps_certificate_url'] as String?,
      noEpsConsentUrl: json['no_eps_consent_url'] as String?,
      parentalConsentUrl: json['parental_consent_url'] as String?,
      hasEps: (json['has_eps'] as bool?) ?? true,
      specialRequest: (json['special_request'] as bool?) ?? false,
      specialRequestReason: json['special_request_reason'] as String?,
      imageConsent: (json['image_consent'] as bool?) ?? false,
      habeasData: (json['habeas_data'] as bool?) ?? false,
      approvalStatus: (json['approval_status'] as String?) ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
      stats: PlayerStats(
        totalMatches: (stats['total_matches'] as int?) ?? 0,
        totalGoals: (stats['total_goals'] as int?) ?? 0,
        yellowCards: (stats['yellow_cards'] as int?) ?? 0,
        blueCards: (stats['blue_cards'] as int?) ?? 0,
        redCards: (stats['red_cards'] as int?) ?? 0,
        totalFouls: (stats['total_fouls'] as int?) ?? 0,
      ),
      lockedWhenApproved: (perms['locked_when_approved'] as bool?) ?? false,
      lockMessage: perms['lock_message'] as String?,
    );
  }

  // Identidad
  final int id;
  final String uniqueCode;

  // Personales
  final String firstName;
  final String lastName;
  final String fullName;
  final String documentType;
  final String documentNumber;
  final String bloodType;
  final String birthDate; // ISO YYYY-MM-DD
  final int? age;
  final bool isMinor;
  final String? church;

  // Equipo + posición
  final TeamSummary? team;
  final int jerseyNumber;
  final String? jerseyName;
  final String position;
  final String? goalkeeperType;
  final double? height;
  final double? weight;
  final bool isCaptain;
  final bool isActive;

  // Archivos
  final String? photoUrl;
  final String? documentFileUrl;
  final String? epsCertificateUrl;
  final String? noEpsConsentUrl;
  final String? parentalConsentUrl;
  final bool hasEps;

  // Solicitud especial
  final bool specialRequest;
  final String? specialRequestReason;

  // Consentimientos
  final bool imageConsent;
  final bool habeasData;

  // Aprobación
  final String approvalStatus;
  final String? rejectionReason;

  // Stats
  final PlayerStats stats;

  // Permisos
  final bool lockedWhenApproved;
  final String? lockMessage;

  /// Equivalente a `approval_status === 'approved'` para el matcher del UI.
  bool get isApproved => approvalStatus == 'approved';
  bool get isRejected => approvalStatus == 'rejected';
  bool get isPending => approvalStatus == 'pending';
}

class PlayerStats {
  const PlayerStats({
    required this.totalMatches,
    required this.totalGoals,
    required this.yellowCards,
    required this.blueCards,
    required this.redCards,
    required this.totalFouls,
  });

  final int totalMatches;
  final int totalGoals;
  final int yellowCards;
  final int blueCards;
  final int redCards;
  final int totalFouls;
}

/// Tipos de archivo que puede subir el líder. Mapea al enum del backend en
/// `MyDashboardController.playerUploadFile`.
enum PlayerFileKind {
  photo,
  document,
  epsCertificate,
  noEpsConsent,
  parentalConsent;

  String get apiValue => switch (this) {
        PlayerFileKind.photo => 'photo',
        PlayerFileKind.document => 'document',
        PlayerFileKind.epsCertificate => 'eps_certificate',
        PlayerFileKind.noEpsConsent => 'no_eps_consent',
        PlayerFileKind.parentalConsent => 'parental_consent',
      };

  String get label => switch (this) {
        PlayerFileKind.photo => 'Foto del jugador',
        PlayerFileKind.document => 'Documento de identidad',
        PlayerFileKind.epsCertificate => 'Certificado EPS',
        PlayerFileKind.noEpsConsent => 'Consentimiento sin EPS',
        PlayerFileKind.parentalConsent => 'Consentimiento padres',
      };
}
