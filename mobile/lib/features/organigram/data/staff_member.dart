/// Miembro del organigrama del torneo. Reusa el campo `tier` de la BD para
/// agrupar visualmente: 1 = Dirección, 2 = Coordinación, 3 = Apoyo.
class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.tier,
    required this.roles,
    this.description,
    this.photoUrl,
  });

  factory StaffMember.fromJson(
    Map<String, dynamic> json,
    Map<String, String> roleLabels,
  ) {
    final rawRoles = json['roles'];
    final roles = <String>[];
    if (rawRoles is List) {
      for (final r in rawRoles) {
        if (r is String) {
          roles.add(roleLabels[r] ?? r);
        }
      }
    }
    return StaffMember(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      tier: (json['tier'] as int?) ?? 3,
      roles: List.unmodifiable(roles),
      description: json['description'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  final int id;
  final String name;

  /// 1 = Dirección, 2 = Coordinación, 3 = Apoyo. Por defecto 3 (apoyo) si
  /// el backend no lo expone.
  final int tier;

  /// Roles legibles, ya mapeados con `role_labels` del backend.
  /// Ej: ['Director', 'Tesorero'].
  final List<String> roles;

  final String? description;
  final String? photoUrl;

  /// Rol principal (primero del array) o `null` si no tiene roles.
  String? get primaryRole => roles.isEmpty ? null : roles.first;

  /// Concatena los roles para mostrarlos como texto. Útil cuando el miembro
  /// tiene múltiples roles asignados.
  String get rolesLabel => roles.join(' · ');

  /// Primer nombre — usado en saludos o avatares con inicial.
  String get firstName {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    return parts.isEmpty ? '' : parts.first;
  }

  /// Apellido (todo lo que sigue al primer nombre) — usado en player_photo
  /// para generar iniciales coherentes.
  String get lastName {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length <= 1) return '';
    return parts.skip(1).join(' ');
  }
}

/// Sección lógica del organigrama. Generada en el cliente agrupando los
/// miembros del backend por `tier`.
class OrgSection {
  const OrgSection({
    required this.title,
    required this.tier,
    required this.members,
  });

  final String title;
  final int tier;
  final List<StaffMember> members;
}

/// Snapshot completo del organigrama: presidente (opcional) + secciones.
class OrganigramData {
  const OrganigramData({
    required this.president,
    required this.sections,
  });

  final StaffMember? president;
  final List<OrgSection> sections;

  bool get isEmpty => president == null && sections.isEmpty;
}
