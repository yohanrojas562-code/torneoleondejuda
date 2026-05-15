import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/dio_client.dart';
import 'package:torneo_leon_de_juda/core/storage/storage_providers.dart';

/// Provider del Dio client global. Los repos inyectan esta instancia via
/// `ref.watch(dioClientProvider)`.
///
/// El AuthInterceptor lee el token de SecureStorage en cada request. Si el
/// server responde 401, el callback onUnauthorized limpia el token —
/// el redirect a login lo cablearemos en Step 7 con go_router.
final dioClientProvider = Provider<Dio>((ref) {
  final secureStorage = ref.read(secureStorageProvider);

  return DioClient.create(
    getToken: secureStorage.getAuthToken,
    onUnauthorized: () async {
      await secureStorage.clearAuthToken();
      // El redirect a /login se conecta en Step 7 via go_router refreshListenable
    },
  );
});
