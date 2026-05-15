import 'package:flutter/material.dart';

// Mock data de Patrocinadores. Reemplazado por SponsorsRepository en Step 19.
// Tiers (de mayor a menor visibilidad): oficial → aliado → apoyo.

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
}

class SponsorMock {
  const SponsorMock({
    required this.id,
    required this.name,
    required this.tier,
    required this.fallbackColor,
    this.logoUrl,
    this.description,
    this.website,
    this.category,
  });

  final int id;
  final String name;
  final SponsorTier tier;
  final Color fallbackColor;
  final String? logoUrl;
  final String? description;
  final String? website;
  final String? category;
}

abstract final class MockSponsorsData {
  MockSponsorsData._();

  static const sponsors = <SponsorMock>[
    // ─── Oficial ─────────────────────────────────────────────────────
    SponsorMock(
      id: 1,
      name: 'Centro de Fe',
      tier: SponsorTier.oficial,
      fallbackColor: Color(0xFFD68F03),
      category: 'Ministerio organizador',
      description:
          'Iglesia organizadora del Torneo León de Judá. Su misión es '
          'integrar a las congregaciones del Centro de Fe a través del '
          'deporte, los valores y la fe.',
      website: 'https://centrodefe.org',
    ),
    SponsorMock(
      id: 2,
      name: 'Coca-Cola FEMSA',
      tier: SponsorTier.oficial,
      fallbackColor: Color(0xFFE53935),
      category: 'Bebidas oficiales',
      description:
          'Aliado oficial de hidratación durante todas las jornadas y '
          'finales del torneo.',
      website: 'https://www.coca-colafemsa.com',
    ),
    SponsorMock(
      id: 3,
      name: 'Adidas Colombia',
      tier: SponsorTier.oficial,
      fallbackColor: Color(0xFF010100),
      category: 'Indumentaria',
      description:
          'Proveedor oficial de balones, uniformes arbitrales y kits '
          'deportivos del torneo.',
      website: 'https://www.adidas.co',
    ),

    // ─── Aliados ─────────────────────────────────────────────────────
    SponsorMock(
      id: 4,
      name: 'Postobón',
      tier: SponsorTier.aliado,
      fallbackColor: Color(0xFFFFB300),
      category: 'Bebidas',
      description: 'Hidratación para los equipos en jornadas regulares.',
      website: 'https://www.postobon.com',
    ),
    SponsorMock(
      id: 5,
      name: 'Bavaria',
      tier: SponsorTier.aliado,
      fallbackColor: Color(0xFFB71C1C),
      category: 'Aliado comercial',
      description: 'Aliado en logística y eventos especiales.',
      website: 'https://www.bavaria.co',
    ),
    SponsorMock(
      id: 6,
      name: 'Bancolombia',
      tier: SponsorTier.aliado,
      fallbackColor: Color(0xFFFDD835),
      category: 'Aliado financiero',
      description: 'Servicios bancarios y aliado en transacciones del torneo.',
      website: 'https://www.bancolombia.com',
    ),
    SponsorMock(
      id: 7,
      name: 'Claro Móvil',
      tier: SponsorTier.aliado,
      fallbackColor: Color(0xFFE53935),
      category: 'Telecomunicaciones',
      description: 'Conectividad oficial en los escenarios del torneo.',
      website: 'https://www.claro.com.co',
    ),

    // ─── Apoyos ──────────────────────────────────────────────────────
    SponsorMock(
      id: 8,
      name: 'Pan La Familia',
      tier: SponsorTier.apoyo,
      fallbackColor: Color(0xFFFB8C00),
      category: 'Alimentación',
    ),
    SponsorMock(
      id: 9,
      name: 'Frutería El Buen Sabor',
      tier: SponsorTier.apoyo,
      fallbackColor: Color(0xFF43A047),
      category: 'Alimentación',
    ),
    SponsorMock(
      id: 10,
      name: 'Droguería Cruz Verde',
      tier: SponsorTier.apoyo,
      fallbackColor: Color(0xFF1E88E5),
      category: 'Salud',
    ),
    SponsorMock(
      id: 11,
      name: 'Impresos Color',
      tier: SponsorTier.apoyo,
      fallbackColor: Color(0xFF8E24AA),
      category: 'Servicios',
    ),
    SponsorMock(
      id: 12,
      name: 'Transportes Rápido',
      tier: SponsorTier.apoyo,
      fallbackColor: Color(0xFF00897B),
      category: 'Transporte',
    ),
    SponsorMock(
      id: 13,
      name: 'Café del Sur',
      tier: SponsorTier.apoyo,
      fallbackColor: Color(0xFF6D4C41),
      category: 'Alimentación',
    ),
  ];

  /// Devuelve sponsors filtrados por tier (en orden de inserción).
  static List<SponsorMock> byTier(SponsorTier tier) =>
      sponsors.where((s) => s.tier == tier).toList(growable: false);
}
