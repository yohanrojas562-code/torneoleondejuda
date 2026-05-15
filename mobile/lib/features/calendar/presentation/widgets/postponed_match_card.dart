import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/mock_calendar_data.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Card de partido aplazado/suspendido/cancelado. Sin marcador, con badge
/// de estado prominente en color warning/red.
class PostponedMatchCard extends StatelessWidget {
  const PostponedMatchCard({required this.match, super.key});

  final PostponedMatchMock match;

  @override
  Widget build(BuildContext context) {
    final isCancelled = match.status == PostponedStatus.cancelled;
    final accent = isCancelled ? AppColors.defeat : AppColors.warning;
    final dateText =
        DateFormat("d 'de' MMMM 'a' h:mm a", 'es_CO').format(match.originalDate);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: accent.withValues(alpha: 0.3)),
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
              _StatusBadge(label: match.status.label, color: accent),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _TeamSide(team: match.home, alignEnd: true)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Text(
                  'vs',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: _TeamSide(team: match.away)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.event_busy_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Fecha original: $dateText',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
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

class _TeamSide extends StatelessWidget {
  const _TeamSide({required this.team, this.alignEnd = false});

  final MatchTeamMock team;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final badge = TeamBadge(
      name: team.name,
      logoUrl: team.logoUrl,
      primaryColor: team.primaryColor,
    );
    final name = Flexible(
      child: Text(
        team.name,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.brPill,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(color: color, fontSize: 9),
      ),
    );
  }
}
