import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/standings/data/standing.dart';
import 'package:torneo_leon_de_juda/features/standings/presentation/widgets/standings_row.dart';

/// Tabla de posiciones de un grupo. Header con etiquetas de columnas +
/// lista de filas con divider sutil entre cada una.
class StandingsTable extends StatelessWidget {
  const StandingsTable({
    required this.group,
    required this.standings,
    required this.onTapStanding,
    super.key,
  });

  final String group;
  final List<Standing> standings;
  final ValueChanged<Standing> onTapStanding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xxs,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            'GRUPO $group',
            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.brMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const _Header(),
              for (var i = 0; i < standings.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    color: AppColors.divider,
                  ),
                StandingsRow(
                  standing: standings[i],
                  onTap: () => onTapStanding(standings[i]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _Legend(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 26 + AppSpacing.sm),
          Expanded(
            child: Text(
              'EQUIPO',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              'PJ',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              'DG',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              'PTS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendChip(
          color: AppColors.victory,
          label: 'Top $kClassificationCut clasifica',
        ),
        SizedBox(width: AppSpacing.xs),
        _LegendChip(
          color: AppColors.defeat,
          label: 'Eliminados',
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.brPill,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.brXs,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
