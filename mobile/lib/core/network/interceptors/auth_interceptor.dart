import 'package:dio/dio.dart';

/// Inyecta el bearer token Sanctum en cada request si esta disponible.
///
/// El interceptor NO accede a flutter_secure_storage directamente — recibe
/// un callback `getToken()` para mantener desacoplamiento. La implementacion
/// concreta de storage se conecta en el nivel de Riverpod providers.
///
/// Tambien marca 401 como "session expirada" llamando al callback opcional
/// `onUnauthorized` (UI lo usa para redirigir a login y limpiar token).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.getToken,
    this.onUnauthorized,
  });

  /// Funcion async que devuelve el token actual o null si no hay.
  final Future<String?> Function() getToken;

  /// Hook opcional cuando el server responde 401 (token expirado/invalido).
  final Future<void> Function()? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip si el caller marca la request como public (login, register, etc.)
    if (options.extra['public'] == true) {
      handler.next(options);
      return;
    }

    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && onUnauthorized != null) {
      await onUnauthorized!();
    }
    handler.next(err);
  }
}
