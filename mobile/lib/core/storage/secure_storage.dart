import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper tipado de `flutter_secure_storage`. Guarda datos sensibles cifrados
/// usando el Keychain en iOS y EncryptedSharedPreferences en Android.
///
/// SOLO para datos sensibles (tokens, credenciales). Para cache de listas y
/// settings normales, usar `CacheStorage` (Hive — mucho mas rapido).
class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  final FlutterSecureStorage _storage;

  // ─── Keys (single source of truth) ─────────────────────────────────
  static const _kAuthToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kUserEmail = 'user_email';
  static const _kUserRole = 'user_role';

  // ─── Auth token (Sanctum bearer) ───────────────────────────────────
  Future<String?> getAuthToken() => _storage.read(key: _kAuthToken);

  Future<void> saveAuthToken(String token) =>
      _storage.write(key: _kAuthToken, value: token);

  Future<void> clearAuthToken() => _storage.delete(key: _kAuthToken);

  // ─── User basics (id, email, role) ─────────────────────────────────
  Future<int?> getUserId() async {
    final raw = await _storage.read(key: _kUserId);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> saveUserId(int id) =>
      _storage.write(key: _kUserId, value: id.toString());

  Future<String?> getUserEmail() => _storage.read(key: _kUserEmail);

  Future<void> saveUserEmail(String email) =>
      _storage.write(key: _kUserEmail, value: email);

  Future<String?> getUserRole() => _storage.read(key: _kUserRole);

  Future<void> saveUserRole(String role) =>
      _storage.write(key: _kUserRole, value: role);

  // ─── Logout / wipe ─────────────────────────────────────────────────
  /// Borra el contenido completo del secure storage. Llamar al hacer logout.
  Future<void> clearAll() => _storage.deleteAll();

  /// Devuelve true si hay sesion activa (token presente).
  Future<bool> hasActiveSession() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
