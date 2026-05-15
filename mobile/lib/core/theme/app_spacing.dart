/// Sistema de espaciado de 4pt — multiples de 4 para alinear con grid
/// estandar de Material Design.
///
/// Uso: SizedBox(height: AppSpacing.md), padding: EdgeInsets.all(AppSpacing.lg).
abstract final class AppSpacing {
  AppSpacing._();

  /// 4pt — micro spacing dentro de chips/badges
  static const double xxs = 4;

  /// 8pt — gap pequeno entre elementos relacionados
  static const double xs = 8;

  /// 12pt — gap default entre items de una lista
  static const double sm = 12;

  /// 16pt — padding default de cards y screens
  static const double md = 16;

  /// 20pt — separacion entre secciones
  static const double lg = 20;

  /// 24pt — padding generoso, separacion entre bloques grandes
  static const double xl = 24;

  /// 32pt — espacios significativos entre secciones diferentes
  static const double xxl = 32;

  /// 48pt — heros, separadores grandes, splash
  static const double huge = 48;

  /// Minimo touch target Material (48dp) — siempre respetar en botones,
  /// items de listas tappeables, etc. Accesibilidad.
  static const double minTouchTarget = 48;
}
