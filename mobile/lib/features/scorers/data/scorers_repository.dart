import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/features/scorers/data/scorer.dart';

class ScorersRepository {
  ScorersRepository(this._dio);

  final Dio _dio;

  Future<List<Scorer>> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/scorers');
      final raw = response.data?['scorers'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(Scorer.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final scorersRepositoryProvider = Provider<ScorersRepository>((ref) {
  return ScorersRepository(ref.watch(dioClientProvider));
});

final scorersProvider = FutureProvider.autoDispose<List<Scorer>>((ref) async {
  return ref.watch(scorersRepositoryProvider).fetch();
});
