import 'package:dio/dio.dart';
import 'package:torneo_leon_de_juda/core/config/env.dart';
import 'package:torneo_leon_de_juda/core/network/interceptors/auth_interceptor.dart';
import 'package:torneo_leon_de_juda/core/network/interceptors/logging_interceptor.dart';

/// Factory del cliente Dio. Centraliza configuracion (base url, timeouts,
/// headers default, interceptors).
///
/// Se expone via Riverpod en network_providers.dart — los repos NO crean
/// instancias de Dio directamente, las reciben por inyeccion.
abstract final class DioClient {
  DioClient._();

  /// Crea un Dio configurado con interceptors y defaults para la app.
  ///
  /// [getToken] callback async que devuelve el token de auth actual o null.
  /// [onUnauthorized] callback opcional cuando el server responde 401.
  static Dio create({
    required Future<String?> Function() getToken,
    Future<void> Function()? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-App-Platform': 'mobile',
          'X-App-Version': Env.appVersion,
        },
        // No tratamos 4xx/5xx como exception — DioException se dispara solo
        // para errores reales (timeouts, conn errors). Los HTTP errors los
        // convertimos manualmente via ApiException.fromDio en los repos.
        // Esto da control fino sobre como reaccionar a cada status code.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(
        getToken: getToken,
        onUnauthorized: onUnauthorized,
      ),
      LoggingInterceptor(),
    ]);

    return dio;
  }
}
