import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/mock_calendar_data.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Card de partido finalizado. Muestra marcador prominente, lista compacta
/// de goleadores por equipo y conteo de tarjetas. Sede al pie.
class FinishedMatchCard extends StatelessWidget {
  const FinishedMatchCard({required this.match, super.key});

  final FinishedMatchMock match;

  @override
  Widget build(BuildContext context) {
    final homeWon = match.homeScore > match.awayScore;
    final awayWon = match.awayScore > match.homeScore;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                match.matchDay.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: AppRadius.brPill,
                ),
                child: Text(
                  'FINALIZADO',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _TeamWithResult(
                  team: match.home,
                  alignEnd: true,
                  isWinner: homeWon,
                  isLoser: awayWon,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: _Score(home: match.homeScore, away: match.awayScore),
              ),
              Expanded(
                child: _TeamWithResult(
                  team: match.away,
                  isWinner: awayWon,
                  isLoser: homeWon,
                ),
              ),
            ],
          ),
          if (match.hasGoals) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _GoalsList(goals: match.homeGoals)),
                Expanded(
                  child: _GoalsList(
                    goals: match.awayGoals,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ],
          if (match.hasCards) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _CardsRow(
                    yellows: match.homeYellows,
                    blues: match.homeBlues,
                    reds: match.homeReds,
                  ),
                ),
                Expanded(
                  child: _CardsRow(
                    yellows: match.awayYellows,
                    blues: match.awayBlues,
                    reds: match.awayReds,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  match.venue,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamWithResult extends StatelessWidget {
  const _TeamWithResult({
    required this.team,
    required this.isWinner,
    required this.isLoser,
    this.alignEnd = false,
  });

  final MatchTeamMock team;
  final bool isWinner;
  final bool isLoser;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final badge = TeamBadge(
      name: team.name,
      logoUrl: team.logoUrl,
      primaryColor: team.primaryColor,
      size: 36,
    );
    final color = isLoser
        ? AppColors.textMuted
        : AppColors.textPrimary;
    final name = Flexible(
      child: Text(
        team.name,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: isWinner ? FontWeight.w800 : FontWeight.w500,
          color: color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      ),
    );

    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [name, const SizedBox(width: AppSpacing.xs), badge]
          : [badge, const SizedBox(width: AppSpacing.xs), name],
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.home, required this.away});
  final int home;
  final int away;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$home — $away',
      style: AppTypography.displayMedium.copyWith(fontSize: 22),
    );
  }
}

class _GoalsList extends StatelessWidget {
  const _GoalsList({required this.goals, this.alignEnd = false});

  final List<MatchGoalMock> goals;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        for (final g in goals)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!alignEnd) ...[
                  const Text('⚽ ', style: TextStyle(fontSize: 11)),
                ],
                Flexible(
                  child: Text(
                    "${g.playerName} ${g.minute}'"
                    "${g.isPenalty ? ' (P)' : ''}"
                    "${g.isOwnGoal ? ' (AG)' : ''}",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    textAlign: alignEnd ? TextAlign.end : TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (alignEnd) ...[
                  const Text(' ⚽', style: TextStyle(fontSize: 11)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _CardsRow extends StatelessWidget {
  const _CardsRow({
    required this.yellows,
    required this.blues,
    required this.reds,
    this.alignEnd = false,
  });

  final int yellows;
  final int blues;
  final int reds;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    if (yellows + blues + reds == 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (yellows > 0)
          _CardChip(color: AppColors.cardYellow, count: yellows),
        if (blues > 0) ...[
          const SizedBox(width: 4),
          _CardChip(color: AppColors.cardBlue, count: blues),
        ],
        if (reds > 0) ...[
          const SizedBox(width: 4),
          _CardChip(color: AppColors.cardRed, count: reds),
        ],
      ],
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip({required this.color, required this.count});
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '$count',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
