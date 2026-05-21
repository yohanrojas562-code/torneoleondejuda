import 'package:flutter/material.dart';

/// Utilidades para colores de la app cuando vienen del backend como string.
abstract final class ColorUtils {
  ColorUtils._();

  /// Parsea un string hex tipo `#D68F03` / `D68F03` / `#FFD68F03` a [Color].
  /// Devuelve [fallback] (o `AppColors.primary` indirecto via gris) si la
  /// entrada no es válida. Útil para `team.primary_color` que viene de DB.
  static Color fromHex(String? hex, {Color fallback = const Color(0xFF808080)}) {
    if (hex == null || hex.isEmpty) return fallback;

    var clean = hex.trim();
    if (clean.startsWith('#')) clean = clean.substring(1);
    if (clean.startsWith('0x') || clean.startsWith('0X')) {
      clean = clean.substring(2);
    }

    if (clean.length == 6) clean = 'FF$clean';
    if (clean.length != 8) return fallback;

    final value = int.tryParse(clean, radix: 16);
    if (value == null) return fallback;
    return Color(value);
  }

  /// Genera un color determinista a partir de un string (nombre de sponsor,
  /// iglesia, etc.) cuando el backend no expone un color. Devuelve siempre
  /// el mismo color para el mismo input — útil para que cada sponsor sin
  /// logo tenga un fallback consistente entre renders.
  static Color deterministicFromString(String input) {
    if (input.isEmpty) return const Color(0xFF6D4C41);
    var hash = 5381;
    for (final code in input.codeUnits) {
      hash = ((hash << 5) + hash) + code; // djb2
    }
    // Paleta curada: 8 colores saturados pero no chillones, contrastan con
    // texto blanco para el fallback de iniciales.
    const palette = [
      Color(0xFF1E88E5), // azul
      Color(0xFF43A047), // verde
      Color(0xFFE53935), // rojo
      Color(0xFF8E24AA), // morado
      Color(0xFFFB8C00), // naranja
      Color(0xFF00897B), // teal
      Color(0xFFD81B60), // rosa
      Color(0xFF6D4C41), // marrón
    ];
    return palette[hash.abs() % palette.length];
  }
}
