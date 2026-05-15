import 'package:dio/dio.dart';

/// Excepciones tipadas del API. Repos y use cases trabajan SOLO con estas
/// (nunca con DioException raw). UI puede hacer switch exhaustivo sobre los
/// subtipos para mostrar el error correcto al usuario.
///
/// Uso en repos:
///   try {
///     return await dio.get(...);
///   } on DioException catch (e) {
///     throw ApiException.fromDio(e);
///   }
sealed class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.cause});

  /// Convierte una DioException en una ApiException tipada. Inspecciona
  /// `DioExceptionType` y el codigo HTTP para clasificarla correctamente.
  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    final code = response?.statusCode;

    // Errores de red / conexion antes de llegar al servidor
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(cause: e);
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return NoConnectionException(cause: e);
      case DioExceptionType.cancel:
        return CancelledException(cause: e);
      case DioExceptionType.badCertificate:
        return CertificateException(cause: e);
      case DioExceptionType.badResponse:
        break;
    }

    // Errores HTTP del servidor
    final serverMessage = _extractMessage(response?.data) ??
        'Error del servidor (HTTP $code)';

    return switch (code) {
      400 => BadRequestException(serverMessage, statusCode: code, cause: e),
      401 => UnauthorizedException(serverMessage, statusCode: code, cause: e),
      403 => ForbiddenException(serverMessage, statusCode: code, cause: e),
      404 => NotFoundException(serverMessage, statusCode: code, cause: e),
      422 => ValidationException(
          serverMessage,
          statusCode: code,
          cause: e,
          errors: _extractValidationErrors(response?.data),
        ),
      429 => RateLimitException(serverMessage, statusCode: code, cause: e),
      final int s when s >= 500 && s < 600 => ServerException(
          serverMessage,
          statusCode: code,
          cause: e,
        ),
      _ => UnknownApiException(serverMessage, statusCode: code, cause: e),
    };
  }

  final String message;
  final int? statusCode;
  final Object? cause;

  static String? _extractMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      final err = data['error'];
      if (err is String && err.isNotEmpty) return err;
    }
    return null;
  }

  static Map<String, List<String>>? _extractValidationErrors(Object? data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map((key, value) {
          if (value is List) {
            return MapEntry(key, value.whereType<String>().toList());
          }
          return MapEntry(key, <String>[value.toString()]);
        });
      }
    }
    return null;
  }

  /// Etiqueta corta para identificar el tipo en logs (sobreescribir en subtipos).
  String get _tag => 'ApiException';

  @override
  String toString() => '$_tag: $message (status: $statusCode)';
}

/// 400 — Petición malformada
final class BadRequestException extends ApiException {
  const BadRequestException(super.message, {super.statusCode, super.cause});
}

/// 401 — No autenticado (token invalido/expirado). UI debe redirigir a login.
final class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.statusCode, super.cause});
}

/// 403 — Sin permiso para esta accion
final class ForbiddenException extends ApiException {
  const ForbiddenException(super.message, {super.statusCode, super.cause});
}

/// 404 — Recurso no encontrado
final class NotFoundException extends ApiException {
  const NotFoundException(super.message, {super.statusCode, super.cause});
}

/// 422 — Errores de validacion del form (Laravel ValidationException)
final class ValidationException extends ApiException {
  const ValidationException(
    super.message, {
    super.statusCode,
    super.cause,
    this.errors,
  });

  /// Mapa campo → lista de mensajes de error. Ej: `{ 'email': ['El email...'] }`
  final Map<String, List<String>>? errors;

  /// Devuelve el primer error de un campo, util para mostrarlo bajo el input.
  String? firstErrorFor(String field) => errors?[field]?.firstOrNull;
}

/// 429 — Demasiadas peticiones (rate limit)
final class RateLimitException extends ApiException {
  const RateLimitException(super.message, {super.statusCode, super.cause});
}

/// 5xx — Error interno del servidor
final class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode, super.cause});
}

/// Sin conexion a internet o el server no responde
final class NoConnectionException extends ApiException {
  const NoConnectionException({Object? cause})
      : super(
          'Sin conexión a internet. Verifica tu red e intenta de nuevo.',
          cause: cause,
        );
}

/// Timeout esperando respuesta del server
final class TimeoutException extends ApiException {
  const TimeoutException({Object? cause})
      : super(
          'El servidor está tardando demasiado. Intenta de nuevo.',
          cause: cause,
        );
}

/// Request cancelado (usuario salio de pantalla, etc.)
final class CancelledException extends ApiException {
  const CancelledException({Object? cause})
      : super('Solicitud cancelada.', cause: cause);
}

/// Problema con el certificado SSL del servidor
final class CertificateException extends ApiException {
  const CertificateException({Object? cause})
      : super(
          'Problema de seguridad con el servidor. Intenta más tarde.',
          cause: cause,
        );
}

/// Error desconocido — fallback final
final class UnknownApiException extends ApiException {
  const UnknownApiException(super.message, {super.statusCode, super.cause});
}
