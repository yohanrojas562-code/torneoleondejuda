import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/standings/data/mock_standings_data.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Bottom sheet con detalle completo de un standing. Se muestra al tap en
/// una fila de la tabla. Incluye foto del equipo, todas las stats y form
/// de los ultimos 5 partidos.
class StandingDetailSheet extends StatelessWidget {
  const StandingDetailSheet({required this.standing, super.key});

  final StandingMock standing;

  /// Helper para abrir el sheet con la API estandar de Flutter.
  static Future<void> show(BuildContext context, StandingMock standing) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StandingDetailSheet(standing: standing),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                TeamBadge(
                  name: standing.team.name,
                  logoUrl: standing.team.logoUrl,
                  primaryColor: standing.team.primaryColor,
                  size: 56,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        standing.team.name,
                        style: AppTypography.headerSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Posición ${standing.position} · Grupo ${standing.group}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _PointsPill(points: standing.points),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('ESTADÍSTICAS', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            _StatsGrid(standing: standing),
            const SizedBox(height: AppSpacing.xl),
            Text('ÚLTIMOS 5 PARTIDOS', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            _FormRow(form: standing.form),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _PointsPill extends StatelessWidget {
  const _PointsPill({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          Text(
            '$points',
            style: AppTypography.displayMedium.copyWith(
              fontSize: 22,
              color: AppColors.textOnPrimary,
            ),
          ),
          Text(
            'PTS',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.8),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.standing});
  final StandingMock standing;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatCell(label: 'PJ', value: standing.played),
      _StatCell(label: 'PG', value: standing.won),
      _StatCell(label: 'PE', value: standing.drawn),
      _StatCell(label: 'PP', value: standing.lost),
      _StatCell(label: 'GF', value: standing.goalsFor),
      _StatCell(label: 'GC', value: standing.goalsAgainst),
      _StatCell(
        label: 'DG',
        value: standing.goalDifference,
        accent: standing.goalDifference != 0
            ? (standing.goalDifference > 0
                ? AppColors.victory
                : AppColors.defeat)
            : null,
      ),
      _StatCell(label: 'FP', value: standing.fairPlayPoints),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: AppSpacing.xs,
      mainAxisSpacing: AppSpacing.xs,
      childAspectRatio: 1.2,
      children: stats,
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, this.accent});

  final String label;
  final int value;
  final Color? accent;

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
            value > 0 && accent == AppColors.victory ? '+$value' : '$value',
            style: AppTypography.headerSmall.copyWith(
              color: accent ?? AppColors.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({required this.form});
  final List<String> form;

  Color _colorFor(String result) {
    return switch (result) {
      'W' => AppColors.victory,
      'D' => AppColors.primary,
      'L' => AppColors.defeat,
      _ => AppColors.textMuted,
    };
  }

  String _labelFor(String result) {
    return switch (result) {
      'W' => 'G',
      'D' => 'E',
      'L' => 'P',
      _ => '?',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < form.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xs),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _colorFor(form[i]).withValues(alpha: 0.18),
              borderRadius: AppRadius.brSm,
              border: Border.all(
                color: _colorFor(form[i]).withValues(alpha: 0.35),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _labelFor(form[i]),
              style: AppTypography.buttonSmall.copyWith(
                color: _colorFor(form[i]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
