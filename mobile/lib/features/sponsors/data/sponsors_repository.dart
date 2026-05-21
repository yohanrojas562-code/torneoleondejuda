import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/features/sponsors/data/sponsor.dart';

/// Repositorio de Patrocinadores. Llama a `GET /api/v1/sponsors` y devuelve
/// la lista parseada como `Sponsor`. Errores de red/HTTP se propagan como
/// [ApiException] tipada para que la UI los muestre uniformemente.
class SponsorsRepository {
  SponsorsRepository(this._dio);

  final Dio _dio;

  Future<List<Sponsor>> fetchAll() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/sponsors');
      final raw = response.data?['sponsors'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(Sponsor.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

/// Provider del repositorio. Lo expone la app via DI de Riverpod.
final sponsorsRepositoryProvider = Provider<SponsorsRepository>((ref) {
  return SponsorsRepository(ref.watch(dioClientProvider));
});

/// Provider de la lista de sponsors. `autoDispose` para que se libere al
/// salir de la pantalla (libera memoria si el usuario navega lejos).
final sponsorsProvider = FutureProvider.autoDispose<List<Sponsor>>((ref) async {
  return ref.watch(sponsorsRepositoryProvider).fetchAll();
});
