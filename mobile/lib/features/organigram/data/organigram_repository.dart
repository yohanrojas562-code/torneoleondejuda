import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/features/organigram/data/staff_member.dart';

/// Repositorio del Organigrama. Llama a `GET /api/v1/organigram` y agrupa
/// los miembros por `tier` (1=Dirección, 2=Coordinación, 3=Apoyo). El
/// presidente es el primer miembro tier 1.
class OrganigramRepository {
  OrganigramRepository(this._dio);

  final Dio _dio;

  Future<OrganigramData> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/organigram');
      return _parse(response.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  OrganigramData _parse(Map<String, dynamic> body) {
    final rawLabels = body['role_labels'];
    final labels = <String, String>{};
    if (rawLabels is Map) {
      for (final entry in rawLabels.entries) {
        if (entry.key is String && entry.value is String) {
          labels[entry.key as String] = entry.value as String;
        }
      }
    }

    final rawMembers = body['members'];
    final members = <StaffMember>[];
    if (rawMembers is List) {
      for (final m in rawMembers) {
        if (m is Map<String, dynamic>) {
          members.add(StaffMember.fromJson(m, labels));
        }
      }
    }

    StaffMember? president;
    final tier1Rest = <StaffMember>[];
    final tier2 = <StaffMember>[];
    final tier3 = <StaffMember>[];
    for (final m in members) {
      if (m.tier <= 1) {
        if (president == null) {
          president = m;
        } else {
          tier1Rest.add(m);
        }
      } else if (m.tier == 2) {
        tier2.add(m);
      } else {
        tier3.add(m);
      }
    }

    final sections = <OrgSection>[
      if (tier1Rest.isNotEmpty)
        OrgSection(title: 'Dirección', tier: 1, members: tier1Rest),
      if (tier2.isNotEmpty)
        OrgSection(title: 'Coordinación', tier: 2, members: tier2),
      if (tier3.isNotEmpty)
        OrgSection(title: 'Equipo de Apoyo', tier: 3, members: tier3),
    ];

    return OrganigramData(president: president, sections: sections);
  }
}

final organigramRepositoryProvider = Provider<OrganigramRepository>((ref) {
  return OrganigramRepository(ref.watch(dioClientProvider));
});

final organigramProvider =
    FutureProvider.autoDispose<OrganigramData>((ref) async {
  return ref.watch(organigramRepositoryProvider).fetch();
});
