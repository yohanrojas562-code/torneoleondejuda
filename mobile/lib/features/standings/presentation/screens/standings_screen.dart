import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/standings/data/standing.dart';
import 'package:torneo_leon_de_juda/features/standings/data/standings_repository.dart';
import 'package:torneo_leon_de_juda/features/standings/presentation/widgets/standing_detail_sheet.dart';
import 'package:torneo_leon_de_juda/features/standings/presentation/widgets/standings_header.dart';
import 'package:torneo_leon_de_juda/features/standings/presentation/widgets/standings_table.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';

/// Pantalla Tabla de Posiciones. Header del torneo + tablas agrupadas por
/// group (cuando aplica). Datos en vivo del backend, pull-to-refresh
/// invalida el provider para refetch.
class StandingsScreen extends ConsumerWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(standingsProvider);

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
        title: const Text('Tabla de Posiciones'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          ref.invalidate(standingsProvider);
          await ref.read(standingsProvider.future);
        },
        child: AsyncView<StandingsData>(
          value: async,
          onRetry: () => ref.invalidate(standingsProvider),
          data: (data) => _Body(data: data),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data});

  final StandingsData data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _EmptyState();
    }

    final byGroup = <String, List<Standing>>{};
    for (final s in data.standings) {
      final key = s.group ?? 'A';
      byGroup.putIfAbsent(key, () => []).add(s);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        StandingsHeader(
          tournamentName: data.tournamentName ?? 'Torneo León de Judá',
          seasonName: data.seasonName ?? 'Temporada en curso',
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final entry in byGroup.entries) ...[
          StandingsTable(
            group: entry.key,
            standings: entry.value,
            onTapStanding: (s) => StandingDetailSheet.show(context, s),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.huge),
      child: Center(
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
                Icons.emoji_events_outlined,
                size: 36,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin tabla disponible',
              style: AppTypography.headerSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Aún no hay una temporada activa o no se han jugado partidos.',
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
