/// Tipo de PQRS. Mapea 1:1 al enum `type` del backend Laravel.
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

  /// Valor que espera el backend en el campo `type`.
  String get apiValue => switch (this) {
        PqrsType.peticion => 'peticion',
        PqrsType.queja => 'queja',
        PqrsType.reclamo => 'reclamo',
        PqrsType.sugerencia => 'sugerencia',
      };
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
