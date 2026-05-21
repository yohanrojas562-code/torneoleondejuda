import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/match_data.dart';

class CalendarRepository {
  CalendarRepository(this._dio);

  final Dio _dio;

  Future<CalendarData> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/calendar');
      final body = response.data ?? const {};
      return CalendarData(
        upcoming: _parseList(body['upcoming_matches']),
        finished: _parseList(body['finished_matches']),
        postponed: _parseList(body['postponed_matches']),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  List<MatchData> _parseList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(MatchData.fromJson)
        .toList(growable: false);
  }
}

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(ref.watch(dioClientProvider));
});

final calendarProvider =
    FutureProvider.autoDispose<CalendarData>((ref) async {
  return ref.watch(calendarRepositoryProvider).fetch();
});
