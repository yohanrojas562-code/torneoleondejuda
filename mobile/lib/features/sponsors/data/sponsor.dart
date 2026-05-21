import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/utils/color_utils.dart';

/// Tier de visibilidad de un patrocinador. Mapea 1:1 con el campo `type` del
/// backend Laravel:
///   patrocinio → oficial   (cards destacadas, 1 col)
///   alianza    → aliado    (grid 2-col)
///   apoyo      → apoyo     (grid 3-col compacto)
enum SponsorTier {
  oficial,
  aliado,
  apoyo;

  String get displayName {
    return switch (this) {
      SponsorTier.oficial => 'Patrocinadores Oficiales',
      SponsorTier.aliado => 'Aliados',
      SponsorTier.apoyo => 'Apoyos',
    };
  }

  /// Parsea el `type` de la API Laravel a un tier. Default = apoyo si
  /// llega un valor desconocido (defensivo).
  static SponsorTier fromApiType(String? type) {
    return switch (type) {
      'patrocinio' => SponsorTier.oficial,
      'alianza' => SponsorTier.aliado,
      'apoyo' => SponsorTier.apoyo,
      _ => SponsorTier.apoyo,
    };
  }
}

class Sponsor {
  const Sponsor({
    required this.id,
    required this.name,
    required this.tier,
    required this.fallbackColor,
    this.logoUrl,
    this.description,
    this.website,
  });

  /// Construye desde la respuesta JSON del endpoint `/api/v1/sponsors`.
  /// El backend no expone color por sponsor, así que generamos uno
  /// determinista del nombre — siempre el mismo color para el mismo sponsor.
  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      tier: SponsorTier.fromApiType(json['type'] as String?),
      fallbackColor: ColorUtils.deterministicFromString(
        (json['name'] as String?) ?? '',
      ),
      logoUrl: json['logo_url'] as String?,
      description: json['description'] as String?,
      website: json['website'] as String?,
    );
  }

  final int id;
  final String name;
  final SponsorTier tier;
  final Color fallbackColor;
  final String? logoUrl;
  final String? description;
  final String? website;
}
