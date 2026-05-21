import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/features/pqrs/data/pqrs.dart';

/// Cliente para el endpoint `POST /api/v1/pqrs`. Sube los datos como
/// `multipart/form-data` para soportar adjuntos. Devuelve el `case_number`
/// generado por Laravel (formato PQRS-2026-0042).
class PqrsRepository {
  PqrsRepository(this._dio);

  final Dio _dio;

  Future<String> submit(PqrsSubmission submission) async {
    try {
      final fields = <String, dynamic>{
        'type': submission.type.apiValue,
        'subject': submission.subject,
        'description': submission.message,
        'submitter_name': submission.fullName,
        'submitter_email': submission.email,
        if (submission.phone != null && submission.phone!.isNotEmpty)
          'submitter_phone': submission.phone,
      };

      final attachments = <MapEntry<String, MultipartFile>>[];
      for (final path in submission.evidencePaths) {
        attachments.add(
          MapEntry(
            'attachments[]',
            await MultipartFile.fromFile(path),
          ),
        );
      }

      final form = FormData.fromMap(fields)..files.addAll(attachments);

      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/pqrs',
        data: form,
        options: Options(
          // Multipart usa su propio content-type; el cliente lo setea solo.
          headers: const {'Content-Type': 'multipart/form-data'},
        ),
      );

      final caseNumber = response.data?['case_number'] as String?;
      if (caseNumber == null || caseNumber.isEmpty) {
        throw const UnknownApiException(
          'El servidor no devolvió un código de caso.',
        );
      }
      return caseNumber;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final pqrsRepositoryProvider = Provider<PqrsRepository>((ref) {
  return PqrsRepository(ref.watch(dioClientProvider));
});
