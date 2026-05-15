import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';

/// Sistema tipografico de la app. Una sola familia (Inter) en distintos
/// pesos para mantener consistencia tipo app moderna (Sofascore, FotMob, etc.).
///
/// Uso: Text('Hola', style: AppTypography.titleLarge).
abstract final class AppTypography {
  AppTypography._();

  // ─── Display (numeros grandes: marcadores, dorsales, scores) ──────
  /// 56pt Black — score de pantalla completa
  static TextStyle get displayHero => GoogleFonts.inter(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
        height: 1,
      );

  /// 40pt Black — marcadores de cards detalladas
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -1,
        height: 1,
      );

  /// 28pt Black — dorsales grandes, numeros prominentes
  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1,
      );

  // ─── Headers / Titulos ─────────────────────────────────────────────
  /// 28pt Bold — titulo de pantalla (hero)
  static TextStyle get headerLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.15,
      );

  /// 22pt Bold — titulo de seccion
  static TextStyle get headerMedium => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.2,
      );

  /// 18pt Semibold — titulo de card
  static TextStyle get headerSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.25,
      );

  // ─── Body ──────────────────────────────────────────────────────────
  /// 16pt Medium — body principal, descripciones
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// 14pt Regular — body secundario, items de lista
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.45,
      );

  /// 13pt Regular — body pequeno, hints
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ─── Labels (uppercase + spaced) ───────────────────────────────────
  /// 12pt Semibold uppercase — labels de seccion, tab labels, badges
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
        height: 1,
      );

  /// 11pt Semibold uppercase — micro labels, status badges
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1,
        height: 1,
      );

  /// 10pt Bold uppercase — micro tags, etiquetas pequenas
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 1.5,
        height: 1,
      );

  // ─── Buttons ───────────────────────────────────────────────────────
  /// 16pt Bold — texto de botones primarios
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        height: 1,
      );

  /// 14pt Bold — texto de botones secundarios
  static TextStyle get buttonMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        height: 1,
      );

  /// 12pt Bold — chips, badges con texto
  static TextStyle get buttonSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        height: 1,
      );

  /// TextTheme completo para ThemeData
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displayMedium,
        headlineLarge: headerLarge,
        headlineMedium: headerMedium,
        headlineSmall: headerSmall,
        titleLarge: headerSmall,
        titleMedium: bodyLarge,
        titleSmall: bodyMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
