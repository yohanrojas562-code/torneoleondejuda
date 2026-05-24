import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/dashboard_data.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/lider_player_detail.dart';
import 'package:torneo_leon_de_juda/shared/models/player.dart';

class MyPlayersData {
  const MyPlayersData({required this.players, required this.counts});

  factory MyPlayersData.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'];
    final players = <Player>[];
    if (rawPlayers is List) {
      for (final p in rawPlayers) {
        if (p is Map<String, dynamic>) {
          players.add(Player.fromJson(p));
        }
      }
    }
    final counts = <String, int>{};
    final rawCounts = json['counts'];
    if (rawCounts is Map) {
      for (final entry in rawCounts.entries) {
        if (entry.key is String && entry.value is num) {
          counts[entry.key as String] = (entry.value as num).toInt();
        }
      }
    }
    return MyPlayersData(players: players, counts: counts);
  }

  final List<Player> players;
  final Map<String, int> counts;
}

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<DashboardData> fetchDashboard() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/v1/my/dashboard');
      return DashboardData.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MyMatchesData> fetchMatches() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/v1/my/matches');
      return MyMatchesData.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MyPlayersData> fetchPlayers() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/v1/my/players');
      return MyPlayersData.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /api/v1/my/players/{id} — detalle completo del jugador.
  Future<LiderPlayerDetail> fetchPlayerDetail(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/my/players/$id',
      );
      final raw = response.data?['player'] as Map<String, dynamic>?;
      if (raw == null) {
        throw const UnknownApiException(
          'El servidor no devolvió los datos del jugador.',
        );
      }
      return LiderPlayerDetail.fromJson(raw);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /api/v1/my/players — crea un jugador en el equipo del líder.
  Future<LiderPlayerDetail> createPlayer(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/my/players',
        data: data,
      );
      final raw = response.data?['player'] as Map<String, dynamic>?;
      if (raw == null) {
        throw const UnknownApiException(
          'El servidor no devolvió el jugador creado.',
        );
      }
      return LiderPlayerDetail.fromJson(raw);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// PATCH /api/v1/my/players/{id} — edita campos permitidos del jugador.
  Future<LiderPlayerDetail> updatePlayer(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/v1/my/players/$id',
        data: data,
      );
      final raw = response.data?['player'] as Map<String, dynamic>?;
      if (raw == null) {
        throw const UnknownApiException(
          'El servidor no devolvió el jugador actualizado.',
        );
      }
      return LiderPlayerDetail.fromJson(raw);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /api/v1/my/players/{id}/files — sube uno de los 5 archivos.
  Future<LiderPlayerDetail> uploadPlayerFile({
    required int playerId,
    required PlayerFileKind kind,
    required String filePath,
  }) async {
    try {
      final form = FormData.fromMap({
        'kind': kind.apiValue,
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/my/players/$playerId/files',
        data: form,
        options: Options(
          headers: const {'Content-Type': 'multipart/form-data'},
        ),
      );
      final raw = response.data?['player'] as Map<String, dynamic>?;
      if (raw == null) {
        throw const UnknownApiException(
          'El servidor no devolvió el jugador después del upload.',
        );
      }
      return LiderPlayerDetail.fromJson(raw);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioClientProvider));
});

final dashboardProvider =
    FutureProvider.autoDispose<DashboardData>((ref) async {
  return ref.watch(dashboardRepositoryProvider).fetchDashboard();
});

final myMatchesProvider =
    FutureProvider.autoDispose<MyMatchesData>((ref) async {
  return ref.watch(dashboardRepositoryProvider).fetchMatches();
});

final myPlayersProvider =
    FutureProvider.autoDispose<MyPlayersData>((ref) async {
  return ref.watch(dashboardRepositoryProvider).fetchPlayers();
});

final myPlayerDetailProvider = FutureProvider.autoDispose
    .family<LiderPlayerDetail, int>((ref, id) async {
  return ref.watch(dashboardRepositoryProvider).fetchPlayerDetail(id);
});
