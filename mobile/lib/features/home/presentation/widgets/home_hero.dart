import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/home/data/home_data.dart';

/// Card hero con info de la temporada activa. Si hay partidos en vivo hoy,
/// muestra un dot pulsante con el conteo (UX live-aware tipo Sofascore).
class HomeHero extends StatelessWidget {
  const HomeHero({required this.season, super.key});

  final ActiveSeason season;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.cardPremiumGradient,
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brPill,
                ),
                child: Text(
                  'TEMPORADA ACTIVA',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (season.isLive && season.liveMatchesToday > 0)
                _LiveBadge(count: season.liveMatchesToday),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _TournamentLogo(url: season.tournamentLogoUrl),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.tournamentName,
                      style: AppTypography.headerMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      season.seasonName,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _StatusChip(label: season.statusLabel, accent: true),
        ],
      ),
    );
  }
}

/// Logo del torneo. Si el backend expone `tournamentLogoUrl` lo carga via
/// CachedNetworkImage; si no hay logo, muestra el placeholder "LJ" dorado
/// (consistente con la identidad de marca).
class _TournamentLogo extends StatelessWidget {
  const _TournamentLogo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    final hasUrl = url != null && url!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: hasUrl ? null : AppColors.goldGradient,
        color: hasUrl ? Colors.white : null,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      alignment: Alignment.center,
      child: hasUrl
          ? Padding(
              padding: const EdgeInsets.all(4),
              child: CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.contain,
                placeholder: (_, __) => const _LogoFallback(size: size),
                errorWidget: (_, __, ___) => const _LogoFallback(size: size),
              ),
            )
          : const _LogoFallback(size: size),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(gradient: AppColors.goldGradient),
      alignment: Alignment.center,
      child: Text(
        'LJ',
        style: AppTypography.headerMedium.copyWith(
          color: AppColors.textOnPrimary,
          fontSize: 22,
        ),
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  const _LiveBadge({required this.count});
  final int count;

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.live.withValues(alpha: 0.15),
        borderRadius: AppRadius.brPill,
        border: Border.all(color: AppColors.live.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0.3, end: 1).animate(_ctrl),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.live,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '${widget.count} hoy',
            style: AppTypography.labelSmall.copyWith(color: AppColors.live),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, this.accent = false});
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surfaceHigh,
        borderRadius: AppRadius.brSm,
        border: Border.all(
          color: accent
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: accent ? AppColors.primary : AppColors.textPrimary,
          fontSize: 11,
        ),
      ),
    );
  }
}
