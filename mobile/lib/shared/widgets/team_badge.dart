import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';

/// Badge circular del logo del equipo. Si hay url de logo, lo descarga y
/// cachea (cached_network_image). Si no, muestra la inicial del nombre del
/// equipo sobre un circulo del primary_color del equipo (fallback elegante).
///
/// Reutilizado en Standings, Calendario, Goleadores, Valla y Modal de
/// jugador para mantener consistencia visual de equipos en toda la app.
class TeamBadge extends StatelessWidget {
  const TeamBadge({
    required this.name,
    this.logoUrl,
    this.primaryColor,
    this.size = 32,
    this.bordered = false,
    super.key,
  });

  /// Nombre del equipo (se usa para la inicial fallback)
  final String name;

  /// URL completa del logo del equipo (ej. https://torneoleondejuda.com/storage/...)
  /// Si es null o vacio, se muestra el fallback con la inicial.
  final String? logoUrl;

  /// Color del equipo para el fondo del fallback (sin logo).
  /// Si es null, usa el primary brand-gold.
  final Color? primaryColor;

  /// Tamaño del badge en pixeles.
  final double size;

  /// Si true, agrega un borde sutil al rededor (util sobre fondos claros).
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;

    final border = bordered
        ? Border.all(color: AppColors.border)
        : null;

    if (hasLogo) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
        ),
        clipBehavior: Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: logoUrl!,
          fit: BoxFit.cover,
          placeholder: (_, __) => _Fallback(
            initial: _initial,
            color: primaryColor ?? AppColors.primary,
            size: size,
          ),
          errorWidget: (_, __, ___) => _Fallback(
            initial: _initial,
            color: primaryColor ?? AppColors.primary,
            size: size,
          ),
        ),
      );
    }

    return _Fallback(
      initial: _initial,
      color: primaryColor ?? AppColors.primary,
      size: size,
      border: border,
    );
  }

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    // Toma la primera letra del primer nombre que no sea articulo (Cfe, El, La)
    final words = trimmed.split(RegExp(r'\s+'));
    const articles = {'cfe', 'el', 'la', 'los', 'las', 'de', 'del'};
    final firstReal = words.firstWhere(
      (w) => !articles.contains(w.toLowerCase()) && w.isNotEmpty,
      orElse: () => words.first,
    );
    return firstReal.characters.first.toUpperCase();
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.initial,
    required this.color,
    required this.size,
    this.border,
  });

  final String initial;
  final Color color;
  final double size;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
          height: 1,
        ),
      ),
    );
  }
}
