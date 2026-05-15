import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/defense/data/mock_defense_data.dart';
import 'package:torneo_leon_de_juda/shared/widgets/player_photo.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Bottom sheet con detalle de un portero. Foto, equipo, dorsal, y stats:
/// goles encajados, partidos, vallas invictas, promedio GC, tarjetas.
class DefenseDetailSheet extends StatelessWidget {
  const DefenseDetailSheet({required this.defense, super.key});

  final DefenseMock defense;

  static Future<void> show(BuildContext context, DefenseMock defense) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DefenseDetailSheet(defense: defense),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gk = defense.goalkeeper;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gk.fullName,
                        style: AppTypography.headerSmall,
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
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          if (gk.jerseyNumber != null)
                            _Chip(label: '#${gk.jerseyNumber}'),
                          if (gk.jerseyNumber != null)
                            const SizedBox(width: 6),
                          const _Chip(label: 'Portero'),
                        ],
                      ),
                    ],
                  ),
                ),
                _RankPill(rank: defense.rank),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('ESTADÍSTICAS', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            _StatsGrid(defense: defense),
            if (gk.church != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: AppRadius.brSm,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.church_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        gk.church!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.brXs,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _RankPill extends StatelessWidget {
  const _RankPill({required this.rank});
  final int rank;

  Color get _color {
    return switch (rank) {
      1 => AppColors.primary,
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.textMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            '#$rank',
            style: AppTypography.displayMedium.copyWith(
              fontSize: 22,
              color: _color,
            ),
          ),
          Text(
            'RANK',
            style: AppTypography.labelSmall.copyWith(
              color: _color,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.defense});
  final DefenseMock defense;

  @override
  Widget build(BuildContext context) {
    final stats = <Widget>[
      _StatCell(
        label: 'Goles en contra',
        value: '${defense.goalsAgainst}',
        color: AppColors.primary,
      ),
      _StatCell(label: 'Partidos', value: '${defense.matchesPlayed}'),
      _StatCell(
        label: 'Vallas invictas',
        value: '${defense.cleanSheets}',
        color: AppColors.victory,
      ),
      _StatCell(
        label: 'Promedio GC',
        value: defense.goalsAgainstPerMatch.toStringAsFixed(2),
      ),
      _StatCell(
        label: 'T. amarillas',
        value: '${defense.yellowCards}',
        color: AppColors.cardYellow,
      ),
      _StatCell(
        label: 'T. azules',
        value: '${defense.blueCards}',
        color: AppColors.cardBlue,
      ),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: AppSpacing.xs,
      mainAxisSpacing: AppSpacing.xs,
      childAspectRatio: 1.4,
      children: stats,
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTypography.headerSmall.copyWith(
              color: color ?? AppColors.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(fontSize: 9),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
