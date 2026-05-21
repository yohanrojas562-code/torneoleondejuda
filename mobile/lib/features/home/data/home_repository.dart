import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/match_data.dart';
import 'package:torneo_leon_de_juda/features/home/data/home_data.dart';

class HomeRepository {
  HomeRepository(this._dio);

  final Dio _dio;

  Future<HomeData> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/home');
      final body = response.data ?? const {};

      final upcoming = <MatchData>[];
      final rawMatches = body['upcoming_matches'];
      if (rawMatches is List) {
        for (final m in rawMatches) {
          if (m is Map<String, dynamic>) {
            upcoming.add(MatchData.fromJson(m));
          }
        }
      }

      final liveCount = upcoming.where((m) => m.isLive).length;

      ActiveSeason? season;
      final rawSeason = body['active_season'];
      if (rawSeason is Map<String, dynamic>) {
        season = ActiveSeason.fromJson(rawSeason, liveMatchesToday: liveCount);
      }

      return HomeData(activeSeason: season, upcomingMatches: upcoming);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(dioClientProvider));
});

final homeProvider = FutureProvider.autoDispose<HomeData>((ref) async {
  return ref.watch(homeRepositoryProvider).fetch();
});
