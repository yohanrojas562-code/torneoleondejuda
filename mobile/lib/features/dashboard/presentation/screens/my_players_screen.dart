import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/dashboard_repository.dart';
import 'package:torneo_leon_de_juda/shared/models/player.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';
import 'package:torneo_leon_de_juda/shared/widgets/player_photo.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Pantalla "Mis Jugadores" — lista de jugadores de los equipos del usuario
/// agrupados por estado de aprobación (pendientes arriba, luego aprobados,
/// luego rechazados).
class MyPlayersScreen extends ConsumerWidget {
  const MyPlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myPlayersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Jugadores')),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          ref.invalidate(myPlayersProvider);
          await ref.read(myPlayersProvider.future);
        },
        child: AsyncView<MyPlayersData>(
          value: async,
          onRetry: () => ref.invalidate(myPlayersProvider),
          data: (data) => _Body(data: data),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data});

  final MyPlayersData data;

  @override
  Widget build(BuildContext context) {
    if (data.players.isEmpty) {
      return const _EmptyState();
    }

    // Orden: pending > approved > rejected
    final pending = data.players
        .where((p) => _statusOf(p) == 'pending')
        .toList(growable: false);
    final approved = data.players
        .where((p) => _statusOf(p) == 'approved')
        .toList(growable: false);
    final rejected = data.players
        .where((p) => _statusOf(p) == 'rejected')
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _CountsRow(counts: data.counts),
        const SizedBox(height: AppSpacing.lg),
        if (pending.isNotEmpty) ...[
          _SectionHeader(
            title: 'POR APROBAR',
            count: pending.length,
            accent: AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final p in pending) _PlayerRow(player: p, status: 'pending'),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (approved.isNotEmpty) ...[
          _SectionHeader(
            title: 'APROBADOS',
            count: approved.length,
            accent: AppColors.victory,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final p in approved) _PlayerRow(player: p, status: 'approved'),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (rejected.isNotEmpty) ...[
          _SectionHeader(
            title: 'RECHAZADOS',
            count: rejected.length,
            accent: AppColors.defeat,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final p in rejected) _PlayerRow(player: p, status: 'rejected'),
        ],
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }

  /// Devuelve el approval_status del jugador. El backend lo expone via
  /// PlayerResource → `approval_status`. Default a 'approved' si por alguna
  /// razón el campo no llega (defensivo).
  String _statusOf(Player p) => p.approvalStatus ?? 'approved';
}

class _CountsRow extends StatelessWidget {
  const _CountsRow({required this.counts});
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CountCard(
            label: 'Total',
            value: '${counts['total'] ?? 0}',
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _CountCard(
            label: 'Aprobados',
            value: '${counts['approved'] ?? 0}',
            color: AppColors.victory,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _CountCard(
            label: 'Pendientes',
            value: '${counts['pending'] ?? 0}',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              fontSize: 22,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.accent,
  });

  final String title;
  final int count;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xxs),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: AppRadius.brXs,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(title, style: AppTypography.labelLarge),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: AppRadius.brXs,
            ),
            child: Text(
              '$count',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player, required this.status});

  final Player player;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          PlayerPhoto(
            firstName: player.firstName,
            lastName: player.lastName,
            photoUrl: player.photoUrl,
            fallbackColor: player.team.primaryColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        player.fullName,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (player.jerseyNumber != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTintMedium,
                          borderRadius: AppRadius.brXs,
                        ),
                        child: Text(
                          '#${player.jerseyNumber}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    TeamBadge(
                      name: player.team.name,
                      logoUrl: player.team.logoUrl,
                      primaryColor: player.team.primaryColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        player.team.name,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (player.position != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· ${player.position}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.huge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: AppRadius.brLg,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.groups_outlined,
                size: 36,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin jugadores',
              style: AppTypography.headerSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Aún no hay jugadores inscritos en tus equipos.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
