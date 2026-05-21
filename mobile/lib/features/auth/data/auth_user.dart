/// Roles soportados por el panel admin de Filament y la app móvil. Mapean
/// 1:1 al backend (Spatie permission, table `roles`).
enum UserRole {
  admin,
  liderEquipo,
  capitan,
  arbitro;

  String get label => switch (this) {
        UserRole.admin => 'Administrador',
        UserRole.liderEquipo => 'Líder de Equipo',
        UserRole.capitan => 'Capitán',
        UserRole.arbitro => 'Árbitro',
      };

  static UserRole? fromApi(String name) {
    return switch (name) {
      'admin' => UserRole.admin,
      'lider_equipo' => UserRole.liderEquipo,
      'capitan' => UserRole.capitan,
      'arbitro' => UserRole.arbitro,
      _ => null,
    };
  }
}

/// Usuario autenticado de la app móvil. Se guarda en secure storage tras
/// login para restaurar la sesión al reabrir la app.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    this.phone,
    this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final roles = <UserRole>[];
    if (rawRoles is List) {
      for (final r in rawRoles) {
        if (r is String) {
          final parsed = UserRole.fromApi(r);
          if (parsed != null) roles.add(parsed);
        }
      }
    }
    return AuthUser(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      roles: List.unmodifiable(roles),
    );
  }

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final List<UserRole> roles;

  /// Rol "principal" para decidir la vista del dashboard. Prioridad:
  /// admin > lider_equipo > capitan > arbitro.
  UserRole? get primaryRole {
    if (roles.isEmpty) return null;
    for (final r in [
      UserRole.admin,
      UserRole.liderEquipo,
      UserRole.capitan,
      UserRole.arbitro,
    ]) {
      if (roles.contains(r)) return r;
    }
    return roles.first;
  }

  bool hasRole(UserRole role) => roles.contains(role);

  /// Iniciales para avatar fallback (ej. "Yohan Rojas" → "YR").
  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts[0];
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
