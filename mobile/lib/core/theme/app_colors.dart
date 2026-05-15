import 'package:flutter/material.dart';

/// Tokens de color de la app. La paleta brand (gold + black) es identica
/// a la del sitio web para garantizar identidad unificada entre canales.
///
/// Uso: AppColors.primary, AppColors.bgDeep, etc.
/// NO usar Colors.X de Material directo en widgets — siempre via este archivo.
abstract final class AppColors {
  AppColors._();

  // ─── Brand (fiel al web) ───────────────────────────────────────────
  /// brand-gold del web — color primario de toda la app
  static const Color primary = Color(0xFFD68F03);

  /// brand-gold-light del web — hover, glow, acentos
  static const Color primaryLight = Color(0xFFE5A824);

  /// brand-gold-dark del web — pressed states, texto sobre fondo dorado
  static const Color primaryDark = Color(0xFFB57A02);

  /// brand-black del web — fondo base de la app
  static const Color bgDeep = Color(0xFF010100);

  // ─── Surfaces (jerarquia de profundidad) ───────────────────────────
  /// Cards normales — un nivel arriba del fondo
  static const Color surfaceLow = Color(0xFF0F0F12);

  /// Cards elevadas, dialogs, bottom sheets — dos niveles arriba
  static const Color surfaceHigh = Color(0xFF18181D);

  /// Sutil tinte gold sobre cards (para active states)
  static Color get primaryTintWeak => primary.withValues(alpha: 0.08);
  static Color get primaryTintMedium => primary.withValues(alpha: 0.15);
  static Color get primaryTintStrong => primary.withValues(alpha: 0.30);

  // ─── Bordes y dividers ─────────────────────────────────────────────
  static const Color border = Color(0x14FFFFFF); // 0.08 alpha
  static const Color borderStrong = Color(0x1FFFFFFF); // 0.12 alpha
  static const Color divider = Color(0x0AFFFFFF); // 0.04 alpha

  // ─── Texto ─────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA8A8B3);
  static const Color textMuted = Color(0xFF6B6B7B);
  static const Color textOnPrimary = Color(0xFF0A0A0A); // texto sobre fondo dorado

  // ─── Estados (semantic) ────────────────────────────────────────────
  /// Victoria / aprobado / clasificado
  static const Color victory = Color(0xFF10B981);
  static Color get victoryTint => victory.withValues(alpha: 0.15);

  /// Derrota / rechazado / eliminado
  static const Color defeat = Color(0xFFEF4444);
  static Color get defeatTint => defeat.withValues(alpha: 0.15);

  /// Partido en vivo (pulsa con animacion)
  static const Color live = Color(0xFFFF1744);
  static Color get liveTint => live.withValues(alpha: 0.15);

  /// Pendiente / aplazado
  static const Color warning = Color(0xFFF59E0B);
  static Color get warningTint => warning.withValues(alpha: 0.15);

  /// Informativo / draw / neutral
  static const Color info = Color(0xFF3B82F6);
  static Color get infoTint => info.withValues(alpha: 0.15);

  // ─── Tarjetas (futsal/soccer) ──────────────────────────────────────
  static const Color cardYellow = Color(0xFFFBBF24);
  static const Color cardBlue = Color(0xFF60A5FA);
  static const Color cardRed = Color(0xFFEF4444);

  // ─── Gradientes (para hero, splash, accents) ───────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient goldShimmer = LinearGradient(
    colors: [primary, primaryLight, primary],
  );

  /// Gradient sutil para fondo de cards premium (top-3, captain, etc.)
  static LinearGradient get cardPremiumGradient => LinearGradient(
        colors: [
          primary.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      );
}
