import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_leon_de_juda/core/router/app_route.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/dashboard_repository.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/lider_player_detail.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';
import 'package:torneo_leon_de_juda/shared/widgets/player_photo.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Detalle de un jugador del equipo del líder. Muestra foto, datos completos,
/// stats del torneo y aprobación. Botones: Editar (form) · Archivos (5 slots).
class MyPlayerDetailScreen extends ConsumerWidget {
  const MyPlayerDetailScreen({required this.playerId, super.key});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myPlayerDetailProvider(playerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de jugador')),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          ref.invalidate(myPlayerDetailProvider(playerId));
          await ref.read(myPlayerDetailProvider(playerId).future);
        },
        child: AsyncView<LiderPlayerDetail>(
          value: async,
          onRetry: () => ref.invalidate(myPlayerDetailProvider(playerId)),
          data: (player) => _Body(player: player),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.player});

  final LiderPlayerDetail player;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _HeaderCard(player: player),
        const SizedBox(height: AppSpacing.md),
        _StatusCard(player: player),
        const SizedBox(height: AppSpacing.md),
        _ActionsRow(player: player),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: 'Datos personales',
          children: [
            _Row(label: 'Código', value: player.uniqueCode),
            _Row(
              label: 'Documento',
              value: '${player.documentType} ${player.documentNumber}',
            ),
            _Row(label: 'Tipo de sangre', value: player.bloodType),
            _Row(label: 'Nacimiento', value: player.birthDate),
            if (player.age != null)
              _Row(
                label: 'Edad',
                value: '${player.age} años${player.isMinor ? " (menor)" : ""}',
              ),
            if (player.church != null && player.church!.isNotEmpty)
              _Row(label: 'Iglesia', value: player.church!),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: 'Equipo y posición',
          children: [
            if (player.team != null) _Row(label: 'Equipo', value: player.team!.name),
            _Row(label: 'Dorsal', value: '#${player.jerseyNumber}'),
            if (player.jerseyName != null && player.jerseyName!.isNotEmpty)
              _Row(label: 'Nombre dorsal', value: player.jerseyName!),
            _Row(label: 'Posición', value: _humanPosition(player.position)),
            if (player.position == 'portero' && player.goalkeeperType != null)
              _Row(
                label: 'Tipo de portero',
                value: player.goalkeeperType == 'titular'
                    ? 'Titular'
                    : 'Suplente',
              ),
            if (player.height != null)
              _Row(label: 'Estatura', value: '${player.height!.toStringAsFixed(0)} cm'),
            if (player.weight != null)
              _Row(label: 'Peso', value: '${player.weight!.toStringAsFixed(0)} kg'),
            _Row(label: 'Capitán', value: player.isCaptain ? 'Sí' : 'No'),
            _Row(label: 'Activo', value: player.isActive ? 'Sí' : 'No'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _StatsCard(stats: player.stats),
        const SizedBox(height: AppSpacing.lg),
        _DocsSummary(player: player),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }

  String _humanPosition(String p) => switch (p) {
        'portero' => 'Portero',
        'defensa' => 'Defensa',
        'mediocampista' => 'Mediocampista',
        'delantero' => 'Delantero',
        _ => p,
      };
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.player});
  final LiderPlayerDetail player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.cardPremiumGradient,
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          PlayerPhoto(
            firstName: player.firstName,
            lastName: player.lastName,
            photoUrl: player.photoUrl,
            fallbackColor: player.team?.primaryColor ?? AppColors.primary,
            size: 84,
            shape: PlayerPhotoShape.squareRounded,
            bordered: true,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.fullName.isNotEmpty
                      ? player.fullName
                      : '${player.firstName} ${player.lastName}',
                  style: AppTypography.headerSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (player.team != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      TeamBadge(
                        name: player.team!.name,
                        logoUrl: player.team!.logoUrl,
                        primaryColor: player.team!.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          player.team!.name,
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
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniChip(label: '#${player.jerseyNumber}'),
                    _MiniChip(label: _humanPosition(player.position)),
                    if (player.isCaptain) const _MiniChip(label: 'CAPITÁN'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _humanPosition(String p) => switch (p) {
        'portero' => 'Portero',
        'defensa' => 'Defensa',
        'mediocampista' => 'Mediocampista',
        'delantero' => 'Delantero',
        _ => p,
      };
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});
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
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.player});
  final LiderPlayerDetail player;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    final String title;
    final String subtitle;

    if (player.isApproved) {
      color = AppColors.victory;
      icon = Icons.check_circle_rounded;
      title = 'Jugador aprobado';
      subtitle = 'Habilitado para jugar.';
    } else if (player.isRejected) {
      color = AppColors.defeat;
      icon = Icons.cancel_rounded;
      title = 'Jugador rechazado';
      subtitle = player.rejectionReason ?? 'Sin motivo especificado';
    } else {
      color = AppColors.warning;
      icon = Icons.hourglass_top_rounded;
      title = 'Pendiente de revisión';
      subtitle = 'El comité revisará tu solicitud.';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.brSm,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsRow extends ConsumerWidget {
  const _ActionsRow({required this.player});
  final LiderPlayerDetail player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              await context.pushNamed(
                AppRoute.myPlayerEdit.name,
                pathParameters: {'id': '${player.id}'},
              );
              // Volvió del form: refresca detalle
              ref.invalidate(myPlayerDetailProvider(player.id));
            },
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Editar datos'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await context.pushNamed(
                AppRoute.myPlayerFiles.name,
                pathParameters: {'id': '${player.id}'},
              );
              ref.invalidate(myPlayerDetailProvider(player.id));
            },
            icon: const Icon(Icons.attach_file_rounded),
            label: const Text('Archivos'),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});
  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTADÍSTICAS DEL TORNEO',
            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.xs,
            mainAxisSpacing: AppSpacing.xs,
            childAspectRatio: 1.5,
            children: [
              _StatCell(
                label: 'Partidos',
                value: '${stats.totalMatches}',
              ),
              _StatCell(
                label: 'Goles',
                value: '${stats.totalGoals}',
                color: AppColors.primary,
              ),
              _StatCell(
                label: 'Faltas',
                value: '${stats.totalFouls}',
              ),
              _StatCell(
                label: 'T. amarillas',
                value: '${stats.yellowCards}',
                color: AppColors.cardYellow,
              ),
              _StatCell(
                label: 'T. azules',
                value: '${stats.blueCards}',
                color: AppColors.cardBlue,
              ),
              _StatCell(
                label: 'T. rojas',
                value: '${stats.redCards}',
                color: AppColors.cardRed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
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
              fontSize: 18,
              color: color ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DocsSummary extends StatelessWidget {
  const _DocsSummary({required this.player});
  final LiderPlayerDetail player;

  @override
  Widget build(BuildContext context) {
    final docs = [
      ('Foto', player.photoUrl != null),
      ('Documento de identidad', player.documentFileUrl != null),
      if (player.hasEps)
        ('Certificado EPS', player.epsCertificateUrl != null)
      else
        ('Consentimiento sin EPS', player.noEpsConsentUrl != null),
      if (player.isMinor)
        ('Consentimiento padres', player.parentalConsentUrl != null),
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ARCHIVOS',
            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final d in docs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(
                    d.$2
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: d.$2 ? AppColors.victory : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.$1,
                      style: AppTypography.bodyMedium.copyWith(
                        color: d.$2
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                  Text(
                    d.$2 ? 'Cargado' : 'Pendiente',
                    style: AppTypography.bodySmall.copyWith(
                      color: d.$2 ? AppColors.victory : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
