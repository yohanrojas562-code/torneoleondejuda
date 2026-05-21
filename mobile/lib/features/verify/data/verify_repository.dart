import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/features/verify/data/verify_result.dart';

/// Resultado completo de un lookup en el Validador. Si `result` es null el
/// jugador no fue encontrado y `reason` explica por qué.
class VerifyLookup {
  const VerifyLookup({this.result, this.reason});

  final VerifyResult? result;
  final String? reason;

  bool get isFound => result != null;
}

class VerifyRepository {
  VerifyRepository(this._dio);

  final Dio _dio;

  Future<VerifyLookup> lookup(String code) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/verify',
        queryParameters: {'code': code},
      );
      final body = response.data ?? const {};
      final raw = body['result'];
      if (raw is Map<String, dynamic>) {
        return VerifyLookup(result: VerifyResult.fromJson(raw));
      }
      return VerifyLookup(reason: body['reason'] as String?);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final verifyRepositoryProvider = Provider<VerifyRepository>((ref) {
  return VerifyRepository(ref.watch(dioClientProvider));
});
