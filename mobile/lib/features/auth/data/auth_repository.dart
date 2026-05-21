import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/network/network_providers.dart';
import 'package:torneo_leon_de_juda/core/storage/storage_providers.dart';
import 'package:torneo_leon_de_juda/features/auth/data/auth_user.dart';

/// Cliente de los endpoints `/api/v1/auth/*`. Encargado de:
/// - hacer login (POST credenciales → token + user)
/// - obtener el user del token actual (GET /me)
/// - revocar el token (POST /logout)
class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  /// Hace login con email/password. Si OK guarda el token y devuelve el
  /// AuthUser. Si falla lanza ApiException (la UI muestra el message).
  Future<({String token, AuthUser user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/login',
        data: {
          'email': email,
          'password': password,
          'device_name': 'flutter-app',
        },
      );
      final body = response.data ?? const {};
      final token = body['token'] as String?;
      final rawUser = body['user'] as Map<String, dynamic>?;
      if (token == null || token.isEmpty || rawUser == null) {
        throw const UnknownApiException(
          'Respuesta del servidor incompleta. Intenta de nuevo.',
        );
      }
      return (token: token, user: AuthUser.fromJson(rawUser));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Carga el user actual usando el token del AuthInterceptor. Útil para
  /// restaurar sesión al abrir la app o cuando el token puede haber sido
  /// revocado desde otro dispositivo.
  Future<AuthUser> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/auth/me');
      final rawUser = response.data?['user'] as Map<String, dynamic>?;
      if (rawUser == null) {
        throw const UnknownApiException('Sesión no válida.');
      }
      return AuthUser.fromJson(rawUser);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Revoca el token actual en el servidor. Si la red falla devuelve
  /// silenciosamente — el cliente igual borra el token local.
  Future<void> logout() async {
    try {
      await _dio.post<dynamic>('/v1/auth/logout');
    } on DioException {
      // Best-effort: si el server no responde, igual hacemos logout local.
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioClientProvider));
});

/// Estado de autenticación global. La UI se suscribe a este provider y
/// reacciona al login/logout. El token se persiste en SecureStorage.
class AuthState {
  const AuthState({this.user, this.isInitializing = false});

  /// User autenticado actual. Si es null, no hay sesión activa.
  final AuthUser? user;

  /// True mientras la app arranca y revisa si hay token persistido.
  /// La UI usa esto para mostrar splash en vez de pantalla de login.
  final bool isInitializing;

  bool get isAuthenticated => user != null;

  AuthState copyWith({AuthUser? user, bool? isInitializing, bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isInitializing: isInitializing ?? this.isInitializing,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Al construirse, intenta restaurar sesión del SecureStorage.
    Future.microtask(_restoreSession);
    return const AuthState(isInitializing: true);
  }

  Future<void> _restoreSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getAuthToken();
    if (token == null || token.isEmpty) {
      state = const AuthState();
      return;
    }
    // Hay token guardado. Intento refrescar el user con /auth/me.
    try {
      final user = await ref.read(authRepositoryProvider).me();
      state = AuthState(user: user);
    } on Object {
      // Token inválido o sin red: limpio para forzar re-login.
      await storage.clearAuthToken();
      state = const AuthState();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final result = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    final storage = ref.read(secureStorageProvider);
    await storage.saveAuthToken(result.token);
    await storage.saveUserEmail(result.user.email);
    await storage.saveUserId(result.user.id);
    final primary = result.user.primaryRole;
    if (primary != null) {
      await storage.saveUserRole(primary.name);
    }
    state = AuthState(user: result.user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    await ref.read(secureStorageProvider).clearAll();
    state = const AuthState();
  }

}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
