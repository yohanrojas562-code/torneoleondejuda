/// Configuracion de ambiente de la app. Los valores son compile-time
/// constants — se pueden sobreescribir via `--dart-define=KEY=value` al
/// ejecutar `flutter run` o `flutter build`.
///
/// Ejemplo dev local:
///   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api
abstract final class Env {
  Env._();

  /// URL base del API Laravel. Por defecto produccion.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://torneoleondejuda.com/api',
  );

  /// URL base del sitio publico (para abrir links externos como /verificar/).
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'https://torneoleondejuda.com',
  );

  /// App version mostrada en pantalla "Acerca de" — sincronizada con
  /// pubspec.yaml manualmente para mostrar la version comercial.
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
}
