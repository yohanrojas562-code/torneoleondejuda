import 'package:flutter/material.dart';

// Mock data del Validador. Reemplazado por VerifyRepository en Step 19.
// Acepta tanto el formato QR oficial "TLJ-<id>" como búsqueda por número de
// documento de identidad.

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
}

class VerifyTeamMock {
  const VerifyTeamMock({
    required this.name,
    required this.primaryColor,
    this.logoUrl,
  });

  final String name;
  final Color primaryColor;
  final String? logoUrl;
}

class VerifyResultMock {
  const VerifyResultMock({
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

  final String firstName;
  final String lastName;
  final String document;
  final VerifyStatus status;
  final VerifyTeamMock? team;
  final String? photoUrl;
  final int? jerseyNumber;
  final String? position;
  final String? church;
  final String? reason;

  String get fullName => '$firstName $lastName';
}

abstract final class MockVerifyData {
  MockVerifyData._();

  static const _laSalle = VerifyTeamMock(
    name: 'Cfe La Salle',
    primaryColor: Color(0xFFD68F03),
  );
  static const _sur = VerifyTeamMock(
    name: 'Cfe Sur',
    primaryColor: Color(0xFF8E24AA),
  );
  static const _norte = VerifyTeamMock(
    name: 'Cfe Norte',
    primaryColor: Color(0xFF43A047),
  );
  static const _robledo = VerifyTeamMock(
    name: 'Cfe Robledo',
    primaryColor: Color(0xFFE53935),
  );

  /// Lookup principal — clave es el ID interno (QR `TLJ-<id>`) o documento.
  static const _results = <String, VerifyResultMock>{
    '101': VerifyResultMock(
      firstName: 'Luis',
      lastName: 'Pérez',
      document: '1037625148',
      status: VerifyStatus.approved,
      team: _laSalle,
      jerseyNumber: 10,
      position: 'Delantero',
      church: 'Centro de Fe La Salle',
    ),
    '102': VerifyResultMock(
      firstName: 'Mateo',
      lastName: 'López',
      document: '1098712445',
      status: VerifyStatus.approved,
      team: _laSalle,
      jerseyNumber: 9,
      position: 'Delantero',
      church: 'Centro de Fe La Salle',
    ),
    '103': VerifyResultMock(
      firstName: 'Pablo',
      lastName: 'Restrepo',
      document: '71234567',
      status: VerifyStatus.suspended,
      team: _sur,
      jerseyNumber: 7,
      position: 'Mediocampista',
      church: 'Centro de Fe Sur',
      reason: 'Suspendido 2 fechas por acumulación de amarillas.',
    ),
    '104': VerifyResultMock(
      firstName: 'Sergio',
      lastName: 'Mora',
      document: '1112334455',
      status: VerifyStatus.expired,
      team: _norte,
      jerseyNumber: 11,
      position: 'Delantero',
      reason: 'El carnet expiró. Debe renovarse en la coordinación.',
    ),
    '105': VerifyResultMock(
      firstName: 'Carlos',
      lastName: 'Díaz',
      document: '888777666',
      status: VerifyStatus.unregistered,
      team: _robledo,
      reason: 'Jugador no aparece inscrito en la nómina oficial del equipo.',
    ),
  };

  /// Busca por el código QR oficial (formato `TLJ-<id>`), por número de
  /// documento, o por el ID interno solo. Devuelve null si no existe.
  static VerifyResultMock? lookup(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return null;

    // Formato QR oficial: TLJ-<id>
    final qrMatch = RegExp(r'^TLJ-(\d+)$').firstMatch(trimmed);
    if (qrMatch != null) {
      return _results[qrMatch.group(1)];
    }

    // Búsqueda por ID interno directo
    if (_results.containsKey(trimmed)) {
      return _results[trimmed];
    }

    // Búsqueda por número de documento
    for (final r in _results.values) {
      if (r.document == trimmed) return r;
    }
    return null;
  }
}
