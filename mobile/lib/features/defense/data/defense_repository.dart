import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/features/defense/data/defense.dart';

class DefenseRepository {
  DefenseRepository(this._dio);

  final Dio _dio;

  Future<List<Defense>> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/defense');
      final raw = response.data?['defenses'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(Defense.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final defenseRepositoryProvider = Provider<DefenseRepository>((ref) {
  return DefenseRepository(ref.watch(dioClientProvider));
});

final defenseProvider = FutureProvider.autoDispose<List<Defense>>((ref) async {
  return ref.watch(defenseRepositoryProvider).fetch();
});
