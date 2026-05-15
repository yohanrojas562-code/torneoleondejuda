import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';

/// Forma del PlayerPhoto: circular (avatares pequeños) o squareRounded
/// (cards heroes, perfiles, modales).
enum PlayerPhotoShape { circle, squareRounded }

/// Foto del jugador con cache y fallback elegante a inicial sobre el color
/// primario del equipo. Usado en Goleadores, Valla, perfiles, etc.
class PlayerPhoto extends StatelessWidget {
  const PlayerPhoto({
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.fallbackColor,
    this.size = 40,
    this.shape = PlayerPhotoShape.circle,
    this.bordered = false,
    super.key,
  });

  final String firstName;
  final String lastName;
  final String? photoUrl;
  final Color? fallbackColor;
  final double size;
  final PlayerPhotoShape shape;
  final bool bordered;

  BorderRadius get _radius => shape == PlayerPhotoShape.circle
      ? BorderRadius.circular(size / 2)
      : BorderRadius.circular(size * 0.18);

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    final border = bordered ? Border.all(color: AppColors.border) : null;

    if (hasPhoto) {
      return Container(
        width: size,
        height: size,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: _radius, border: border),
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          fit: BoxFit.cover,
          placeholder: (_, __) => _Fallback(
            initial: _initial,
            color: fallbackColor ?? AppColors.primary,
            size: size,
            radius: _radius,
          ),
          errorWidget: (_, __, ___) => _Fallback(
            initial: _initial,
            color: fallbackColor ?? AppColors.primary,
            size: size,
            radius: _radius,
          ),
        ),
      );
    }

    return _Fallback(
      initial: _initial,
      color: fallbackColor ?? AppColors.primary,
      size: size,
      radius: _radius,
      border: border,
    );
  }

  String get _initial {
    if (firstName.isNotEmpty) return firstName.characters.first.toUpperCase();
    if (lastName.isNotEmpty) return lastName.characters.first.toUpperCase();
    return '?';
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.initial,
    required this.color,
    required this.size,
    required this.radius,
    this.border,
  });

  final String initial;
  final Color color;
  final double size;
  final BorderRadius radius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
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
