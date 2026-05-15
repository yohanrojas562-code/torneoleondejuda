import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/storage/cache_storage.dart';
import 'package:torneo_leon_de_juda/core/storage/secure_storage.dart';

/// Provider del SecureStorage (singleton manual via constructor por defecto).
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Provider del CacheStorage (singleton estricto).
final cacheStorageProvider = Provider<CacheStorage>((ref) {
  return CacheStorage.instance;
});
