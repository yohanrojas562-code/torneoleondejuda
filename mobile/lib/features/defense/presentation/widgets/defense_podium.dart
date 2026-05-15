import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/defense/data/mock_defense_data.dart';
import 'package:torneo_leon_de_juda/shared/widgets/player_photo.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Podio del top 3 de menos vencidos. #1 hero card con shield gold,
/// #2 y #3 lado a lado debajo. Tap → bottom sheet con detalle.
class DefensePodium extends StatelessWidget {
  const DefensePodium({
    required this.top1,
    required this.top2,
    required this.top3,
    required this.onTap,
    super.key,
  });

  final DefenseMock top1;
  final DefenseMock? top2;
  final DefenseMock? top3;
  final ValueChanged<DefenseMock> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroCard(defense: top1, onTap: () => onTap(top1)),
        if (top2 != null || top3 != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (top2 != null)
                Expanded(
                  child: _RunnerUpCard(
                    defense: top2!,
                    medalColor: const Color(0xFFC0C0C0),
                    onTap: () => onTap(top2!),
                  ),
                ),
              if (top2 != null && top3 != null)
                const SizedBox(width: AppSpacing.sm),
              if (top3 != null)
                Expanded(
                  child: _RunnerUpCard(
                    defense: top3!,
                    medalColor: const Color(0xFFCD7F32),
                    onTap: () => onTap(top3!),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.defense, required this.onTap});

  final DefenseMock defense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gk = defense.goalkeeper;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brLg,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.cardPremiumGradient,
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.brLg,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PlayerPhoto(
                    firstName: gk.firstName,
                    lastName: gk.lastName,
                    photoUrl: gk.photoUrl,
                    fallbackColor: gk.team.primaryColor,
                    size: 72,
                    shape: PlayerPhotoShape.squareRounded,
                    bordered: true,
                  ),
                  Positioned(
                    top: -6,
                    left: -6,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 16,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEJOR PORTERO',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gk.fullName,
                      style: AppTypography.headerSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        TeamBadge(
                          name: gk.team.name,
                          logoUrl: gk.team.logoUrl,
                          primaryColor: gk.team.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            gk.team.name,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  Text(
                    '${defense.goalsAgainst}',
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 44,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'GC',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunnerUpCard extends StatelessWidget {
  const _RunnerUpCard({
    required this.defense,
    required this.medalColor,
    required this.onTap,
  });

  final DefenseMock defense;
  final Color medalColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gk = defense.goalkeeper;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brMd,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.brMd,
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PlayerPhoto(
                    firstName: gk.firstName,
                    lastName: gk.lastName,
                    photoUrl: gk.photoUrl,
                    fallbackColor: gk.team.primaryColor,
                    size: 56,
                    shape: PlayerPhotoShape.squareRounded,
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: medalColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.bgDeep,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${defense.rank}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                gk.shortName,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                gk.team.name,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${defense.goalsAgainst}',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 24,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'GC',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
