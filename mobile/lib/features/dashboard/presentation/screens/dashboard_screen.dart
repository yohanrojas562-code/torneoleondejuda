import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_leon_de_juda/core/router/app_route.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/auth/data/auth_repository.dart';
import 'package:torneo_leon_de_juda/features/auth/data/auth_user.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/match_data.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/upcoming_match_card.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/dashboard_data.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/dashboard_repository.dart';
import 'package:torneo_leon_de_juda/features/standings/data/standing.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Pantalla principal post-login. Hero con el usuario + sus roles, y debajo
/// renderiza widgets distintos según `data.view` (admin | lider | capitan |
/// arbitro | generic).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final async = ref.watch(dashboardProvider);
    final user = auth.user;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menú',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Mi Panel'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
          await ref.read(dashboardProvider.future);
        },
        child: AsyncView<DashboardData>(
          value: async,
          onRetry: () => ref.invalidate(dashboardProvider),
          data: (data) => _Body(user: user, data: data),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) return;
    context.goNamed(AppRoute.home.name);
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.user, required this.data});

  final AuthUser? user;
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (user != null) _UserHero(user: user!),
        const SizedBox(height: AppSpacing.lg),
        if (data.activeSeasonName != null)
          _SeasonBanner(
            tournament: data.tournamentName,
            season: data.activeSeasonName!,
          ),
        const SizedBox(height: AppSpacing.lg),
        if (data.view == 'admin')
          _AdminView(data: data)
        else if (data.view == 'lider')
          _LiderView(data: data)
        else if (data.view == 'capitan')
          _CapitanView(data: data)
        else if (data.view == 'arbitro')
          _ArbitroView(data: data)
        else
          _GenericView(message: data.message),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

class _UserHero extends StatelessWidget {
  const _UserHero({required this.user});

  final AuthUser user;

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
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: AppRadius.brMd,
            ),
            alignment: Alignment.center,
            child: Text(
              user.initials,
              style: AppTypography.headerMedium.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTypography.headerSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.roles.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final r in user.roles) _RoleChip(role: r),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryTintMedium,
        borderRadius: AppRadius.brXs,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        role.label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _SeasonBanner extends StatelessWidget {
  const _SeasonBanner({required this.season, this.tournament});

  final String? tournament;
  final String season;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              tournament != null ? '$tournament · $season' : season,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vistas por rol ─────────────────────────────────────────────────

class _AdminView extends StatelessWidget {
  const _AdminView({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final c = data.counts ?? const <String, int>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RESUMEN GENERAL', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Equipos',
                value: '${c['teams'] ?? 0}',
                icon: Icons.shield_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'Jugadores',
                value: '${c['players'] ?? 0}',
                icon: Icons.groups_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Por aprobar',
                value: '${c['players_pending'] ?? 0}',
                icon: Icons.hourglass_top_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'Partidos jugados',
                value: '${c['matches_played'] ?? 0}',
                icon: Icons.sports_soccer_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _StatCard(
          label: 'Próximos partidos',
          value: '${c['matches_upcoming'] ?? 0}',
          icon: Icons.calendar_today_rounded,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('PANEL COMPLETO', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.brMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 36,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Administración completa',
                style: AppTypography.headerSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Para gestionar equipos, jugadores, partidos y configuración '
                'del torneo, copia el enlace al panel web.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              if (data.webAdminUrl != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _copyAdminLink(context, data.webAdminUrl!),
                    icon: const Icon(Icons.content_copy_rounded),
                    label: const Text('Copiar enlace al panel'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _copyAdminLink(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: url));
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Enlace copiado. Ábrelo en el navegador para gestionar.'),
        backgroundColor: AppColors.surfaceHigh,
      ),
    );
  }
}

class _LiderView extends StatelessWidget {
  const _LiderView({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final pc = data.playerCounts ?? const <String, int>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MIS EQUIPOS', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        if (data.teams.isEmpty)
          const _EmptyHint(
            icon: Icons.shield_outlined,
            message:
                'No tienes equipos asignados. Contacta al comité para que '
                'te asignen tu equipo.',
          )
        else
          Column(
            children: [
              for (final t in data.teams) _TeamRow(team: t),
            ],
          ),
        const SizedBox(height: AppSpacing.xl),
        Text('JUGADORES', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Aprobados',
                value: '${pc['approved'] ?? 0}',
                icon: Icons.check_circle_rounded,
                color: AppColors.victory,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'Por aprobar',
                value: '${pc['pending'] ?? 0}',
                icon: Icons.hourglass_top_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'Rechazados',
                value: '${pc['rejected'] ?? 0}',
                icon: Icons.cancel_rounded,
                color: AppColors.defeat,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    GoRouter.of(context).goNamed(AppRoute.myPlayers.name),
                icon: const Icon(Icons.list_alt_rounded),
                label: const Text('Ver mis jugadores'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _UpcomingMatchesSection(matches: data.upcomingMatches),
      ],
    );
  }
}

class _CapitanView extends StatelessWidget {
  const _CapitanView({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MI EQUIPO', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        if (data.teams.isEmpty)
          const _EmptyHint(
            icon: Icons.shield_outlined,
            message:
                'Aún no estás asignado como capitán de ningún equipo. '
                'Pregúntale a tu líder de equipo o al comité.',
          )
        else
          Column(
            children: [
              for (final t in data.teams) _TeamRow(team: t),
            ],
          ),
        const SizedBox(height: AppSpacing.xl),
        _UpcomingMatchesSection(matches: data.upcomingMatches),
      ],
    );
  }
}

class _ArbitroView extends StatelessWidget {
  const _ArbitroView({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return _EmptyHint(
      icon: Icons.sports_rounded,
      message: data.message ??
          'Pronto verás aquí los partidos que tienes asignados para arbitrar.',
    );
  }
}

class _GenericView extends StatelessWidget {
  const _GenericView({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return _EmptyHint(
      icon: Icons.info_outline_rounded,
      message: message ?? 'Tu cuenta no tiene un dashboard asignado todavía.',
    );
  }
}

// ─── Pieces reutilizables ───────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
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
          Row(
            children: [
              Icon(icon, size: 16, color: c),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              fontSize: 22,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.team});
  final TeamSummary team;

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
          TeamBadge(
            name: team.name,
            logoUrl: team.logoUrl,
            primaryColor: team.primaryColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              team.name,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingMatchesSection extends StatelessWidget {
  const _UpcomingMatchesSection({required this.matches});
  final List<MatchData> matches;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('PRÓXIMOS PARTIDOS', style: AppTypography.labelLarge),
            const Spacer(),
            if (matches.isNotEmpty)
              TextButton(
                onPressed: () =>
                    GoRouter.of(context).goNamed(AppRoute.myMatches.name),
                child: const Text('Ver todos'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (matches.isEmpty)
          const _EmptyHint(
            icon: Icons.event_outlined,
            message: 'No tienes partidos programados.',
          )
        else
          Column(
            children: [
              for (final m in matches) ...[
                UpcomingMatchCard(match: m),
                const SizedBox(height: AppSpacing.xs),
              ],
            ],
          ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
