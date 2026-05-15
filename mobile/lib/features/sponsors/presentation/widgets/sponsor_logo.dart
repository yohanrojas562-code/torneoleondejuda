import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/sponsors/data/mock_sponsors_data.dart';

/// Logo del patrocinador con cache + fallback elegante a iniciales sobre
/// gradient del color de marca. Tamaños sugeridos: oficial 120, aliado 80,
/// apoyo 48.
class SponsorLogo extends StatelessWidget {
  const SponsorLogo({
    required this.sponsor,
    required this.size,
    super.key,
  });

  final SponsorMock sponsor;
  final double size;

  String get _initials {
    final words = sponsor.name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].characters.take(2).toString().toUpperCase();
    }
    return (words[0].characters.first + words[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasLogo = sponsor.logoUrl != null && sponsor.logoUrl!.isNotEmpty;

    if (hasLogo) {
      return Container(
        width: size,
        height: size,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.18),
        ),
        padding: const EdgeInsets.all(6),
        child: CachedNetworkImage(
          imageUrl: sponsor.logoUrl!,
          fit: BoxFit.contain,
          placeholder: (_, __) => _InitialFallback(
            initials: _initials,
            color: sponsor.fallbackColor,
            size: size,
          ),
          errorWidget: (_, __, ___) => _InitialFallback(
            initials: _initials,
            color: sponsor.fallbackColor,
            size: size,
          ),
        ),
      );
    }
    return _InitialFallback(
      initials: _initials,
      color: sponsor.fallbackColor,
      size: size,
    );
  }
}

class _InitialFallback extends StatelessWidget {
  const _InitialFallback({
    required this.initials,
    required this.color,
    required this.size,
  });

  final String initials;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(size * 0.18),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.displayMedium.copyWith(
          color: Colors.white,
          fontSize: size * 0.32,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
