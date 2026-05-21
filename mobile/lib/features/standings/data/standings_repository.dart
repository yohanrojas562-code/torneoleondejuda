import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/features/standings/data/standing.dart';

class StandingsRepository {
  StandingsRepository(this._dio);

  final Dio _dio;

  Future<StandingsData> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/standings');
      final body = response.data ?? const {};

      final rawSeason = body['active_season'];
      String? seasonName;
      String? tournamentName;
      if (rawSeason is Map<String, dynamic>) {
        seasonName = rawSeason['name'] as String?;
        final t = rawSeason['tournament'];
        if (t is Map<String, dynamic>) {
          tournamentName = t['name'] as String?;
        }
      }

      final raw = body['standings'];
      final standings = <Standing>[];
      if (raw is List) {
        for (final s in raw) {
          if (s is Map<String, dynamic>) {
            standings.add(Standing.fromJson(s));
          }
        }
      }

      return StandingsData(
        standings: standings,
        seasonName: seasonName,
        tournamentName: tournamentName,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final standingsRepositoryProvider = Provider<StandingsRepository>((ref) {
  return StandingsRepository(ref.watch(dioClientProvider));
});

final standingsProvider =
    FutureProvider.autoDispose<StandingsData>((ref) async {
  return ref.watch(standingsRepositoryProvider).fetch();
});
