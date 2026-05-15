import 'dart:math';

// Mock data y servicio fake de PQRS. Reemplazado por PqrsRepository en
// Step 19, que envía a POST /api/pqrs en el servidor Laravel.

enum PqrsType {
  peticion,
  queja,
  reclamo,
  sugerencia;

  String get label {
    return switch (this) {
      PqrsType.peticion => 'Petición',
      PqrsType.queja => 'Queja',
      PqrsType.reclamo => 'Reclamo',
      PqrsType.sugerencia => 'Sugerencia',
    };
  }

  String get description {
    return switch (this) {
      PqrsType.peticion => 'Una solicitud formal al comité organizador.',
      PqrsType.queja => 'Inconformidad con un servicio o actuación.',
      PqrsType.reclamo => 'Reclamación sobre una decisión del torneo.',
      PqrsType.sugerencia => 'Idea o propuesta para mejorar el torneo.',
    };
  }
}

class PqrsSubmission {
  const PqrsSubmission({
    required this.type,
    required this.fullName,
    required this.email,
    required this.subject,
    required this.message,
    required this.evidencePaths,
    this.phone,
  });

  final PqrsType type;
  final String fullName;
  final String email;
  final String? phone;
  final String subject;
  final String message;
  final List<String> evidencePaths;
}

/// Servicio simulado. En Step 19 se reemplaza por un cliente Dio.
abstract final class MockPqrsService {
  MockPqrsService._();

  /// Simula latencia de red y devuelve un código único de caso.
  static Future<String> submit(PqrsSubmission submission) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return _generateCaseCode(submission.type);
  }

  static String _generateCaseCode(PqrsType type) {
    final prefix = switch (type) {
      PqrsType.peticion => 'PET',
      PqrsType.queja => 'QJA',
      PqrsType.reclamo => 'RCL',
      PqrsType.sugerencia => 'SUG',
    };
    final rng = Random();
    final n = rng.nextInt(900000) + 100000; // 6 digits
    return '$prefix-$n';
  }
}
