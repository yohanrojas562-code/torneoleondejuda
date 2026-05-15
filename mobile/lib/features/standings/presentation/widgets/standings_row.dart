import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/standings/data/mock_standings_data.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Constantes de cupos para badge de clasificacion. Reutilizadas en el
/// header de columnas y en el legend al pie de la tabla.
const int kClassificationCut = 8;

/// Fila individual de la tabla de posiciones. Columnas:
/// `#` · Equipo · PJ · DG · PTS. Tap → abre bottom sheet con detalle.
class StandingsRow extends StatelessWidget {
  const StandingsRow({
    required this.standing,
    required this.onTap,
    super.key,
  });

  final StandingMock standing;
  final VoidCallback onTap;

  bool get _classifies => standing.position <= kClassificationCut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _PositionBadge(
                position: standing.position,
                classifies: _classifies,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Row(
                  children: [
                    TeamBadge(
                      name: standing.team.name,
                      logoUrl: standing.team.logoUrl,
                      primaryColor: standing.team.primaryColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        standing.team.name,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${standing.played}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 44,
                child: _GoalDifference(value: standing.goalDifference),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${standing.points}',
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.position, required this.classifies});

  final int position;
  final bool classifies;

  @override
  Widget build(BuildContext context) {
    final color = classifies ? AppColors.victory : AppColors.defeat;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.brXs,
      ),
      alignment: Alignment.center,
      child: Text(
        '$position',
        style: AppTypography.buttonSmall.copyWith(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _GoalDifference extends StatelessWidget {
  const _GoalDifference({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;
    if (value > 0) {
      color = AppColors.victory;
      text = '+$value';
    } else if (value < 0) {
      color = AppColors.defeat;
      text = '$value';
    } else {
      color = AppColors.textMuted;
      text = '0';
    }
    return Text(
      text,
      style: AppTypography.bodyMedium.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }
}
