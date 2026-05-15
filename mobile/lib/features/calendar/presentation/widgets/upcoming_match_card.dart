import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/mock_calendar_data.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Card de partido proximo o en vivo. Si esta en vivo, muestra dot pulsante
/// + score + tiempo de partido. Si no, muestra hora programada.
class UpcomingMatchCard extends StatelessWidget {
  const UpcomingMatchCard({required this.match, super.key});

  final UpcomingMatchMock match;

  @override
  Widget build(BuildContext context) {
    final timeText = DateFormat.jm('es_CO').format(match.scheduledAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: match.isLive
              ? AppColors.live.withValues(alpha: 0.4)
              : AppColors.border,
        ),
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
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              if (match.isLive) const _LiveDot(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _TeamSide(team: match.home, alignEnd: true),
              ),
              const SizedBox(width: AppSpacing.sm),
              _CenterScore(
                isLive: match.isLive,
                liveHome: match.liveHomeScore,
                liveAway: match.liveAwayScore,
                liveStatus: match.liveStatus,
                scheduledTime: timeText,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TeamSide(team: match.away),
              ),
            ],
          ),
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
      size: 36,
    );
    final name = Flexible(
      child: Text(
        team.name,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
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

class _CenterScore extends StatelessWidget {
  const _CenterScore({
    required this.isLive,
    required this.scheduledTime,
    this.liveHome,
    this.liveAway,
    this.liveStatus,
  });

  final bool isLive;
  final int? liveHome;
  final int? liveAway;
  final String? liveStatus;
  final String scheduledTime;

  @override
  Widget build(BuildContext context) {
    if (isLive && liveHome != null && liveAway != null) {
      return Column(
        children: [
          Text(
            '$liveHome - $liveAway',
            style: AppTypography.displayMedium.copyWith(
              fontSize: 22,
              color: AppColors.live,
            ),
          ),
          if (liveStatus != null) ...[
            const SizedBox(height: 2),
            Text(
              liveStatus!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.live,
                fontSize: 9,
              ),
            ),
          ],
        ],
      );
    }
    return Column(
      children: [
        Text(
          scheduledTime,
          style: AppTypography.headerSmall.copyWith(
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text('VS', style: AppTypography.labelSmall),
      ],
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
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
            'EN VIVO',
            style: AppTypography.labelSmall.copyWith(color: AppColors.live),
          ),
        ],
      ),
    );
  }
}
