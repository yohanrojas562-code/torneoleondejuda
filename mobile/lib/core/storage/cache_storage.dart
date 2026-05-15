import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Boxes (namespaces) de cache disponibles. Evita strings magicos en el codigo.
enum CacheBox {
  matches('matches_cache'),
  standings('standings_cache'),
  scorers('scorers_cache'),
  defense('defense_cache'),
  players('players_cache'),
  teams('teams_cache'),
  sponsors('sponsors_cache'),
  teamMembers('team_members_cache'),
  settings('app_settings');

  const CacheBox(this.name);
  final String name;
}

/// Wrapper de Hive con TTL. Cada entry se guarda con su timestamp para que
/// el caller pueda decidir si lo considera fresco o stale.
///
/// Patron caller-managed TTL (no auto-eviction): la app muestra cached data
/// INMEDIATAMENTE (UX instantanea) y refresca de red en background. Cuando
/// llega la nueva data, sobreescribe el cache.
///
/// Inicializar en main() ANTES de runApp() llamando `await CacheStorage.init()`.
class CacheStorage {
  CacheStorage._();

  /// Singleton.
  static final CacheStorage instance = CacheStorage._();

  /// Inicializa Hive y abre todos los boxes. Llamar UNA SOLA VEZ en main().
  static Future<void> init() async {
    await Hive.initFlutter();
    for (final box in CacheBox.values) {
      await Hive.openBox<String>(box.name);
    }
  }

  /// Guarda un objeto JSON-serializable en el box dado con timestamp.
  Future<void> save(
    CacheBox box,
    String key,
    Object data,
  ) async {
    final entry = <String, Object?>{
      'cachedAt': DateTime.now().toIso8601String(),
      'data': data,
    };
    await Hive.box<String>(box.name).put(key, jsonEncode(entry));
  }

  /// Lee un objeto del cache. Devuelve null si no existe.
  /// [maxAge] es opcional — si lo das, retorna null cuando la entrada es
  /// mas vieja que ese duracion (considerada stale).
  Object? read(CacheBox box, String key, {Duration? maxAge}) {
    final raw = Hive.box<String>(box.name).get(key);
    if (raw == null) return null;

    final entry = jsonDecode(raw) as Map<String, dynamic>;
    final cachedAtRaw = entry['cachedAt'];
    if (cachedAtRaw is! String) return null;

    final cachedAt = DateTime.tryParse(cachedAtRaw);
    if (cachedAt == null) return null;

    if (maxAge != null && DateTime.now().difference(cachedAt) > maxAge) {
      // Stale — devolvemos null para forzar fetch de red
      return null;
    }

    return entry['data'];
  }

  /// Lee un objeto sin TTL (siempre devuelve aunque este viejo). Util cuando
  /// queremos mostrar data cacheada offline aunque sea desactualizada.
  Object? readAnyAge(CacheBox box, String key) => read(box, key);

  /// Borra una entrada especifica.
  Future<void> remove(CacheBox box, String key) =>
      Hive.box<String>(box.name).delete(key);

  /// Vacia un box entero.
  Future<void> clearBox(CacheBox box) => Hive.box<String>(box.name).clear();

  /// Vacia TODOS los boxes — util para logout o reset completo.
  Future<void> clearAll() async {
    for (final box in CacheBox.values) {
      await Hive.box<String>(box.name).clear();
    }
  }

  /// Devuelve la edad de una entrada o null si no existe.
  Duration? ageOf(CacheBox box, String key) {
    final raw = Hive.box<String>(box.name).get(key);
    if (raw == null) return null;
    try {
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAtRaw = entry['cachedAt'] as String?;
      final cachedAt = cachedAtRaw == null ? null : DateTime.tryParse(cachedAtRaw);
      if (cachedAt == null) return null;
      return DateTime.now().difference(cachedAt);
    } on Object {
      return null;
    }
  }
}
