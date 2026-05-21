import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/match_data.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/finished_match_card.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/postponed_match_card.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/upcoming_match_card.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/dashboard_data.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/dashboard_repository.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';

/// Pantalla "Mis Partidos" — solo los partidos de los equipos del usuario
/// autenticado (líder o capitán). 3 tabs como en el calendario público.
class MyMatchesScreen extends ConsumerWidget {
  const MyMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myMatchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Partidos')),
      body: AsyncView<MyMatchesData>(
        value: async,
        onRetry: () => ref.invalidate(myMatchesProvider),
        data: (data) => _Tabs(
          data: data,
          onRefresh: () async {
            ref.invalidate(myMatchesProvider);
            await ref.read(myMatchesProvider.future);
          },
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.data, required this.onRefresh});

  final MyMatchesData data;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Próximos (${data.upcoming.length})'),
                Tab(text: 'Finalizados (${data.finished.length})'),
                Tab(text: 'Aplazados (${data.postponed.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _MatchList(
                  matches: data.upcoming,
                  builder: (m) => UpcomingMatchCard(match: m),
                  emptyText: 'No tienes próximos partidos.',
                  onRefresh: onRefresh,
                ),
                _MatchList(
                  matches: data.finished,
                  builder: (m) => FinishedMatchCard(match: m),
                  emptyText: 'No tienes partidos finalizados.',
                  onRefresh: onRefresh,
                ),
                _MatchList(
                  matches: data.postponed,
                  builder: (m) => PostponedMatchCard(match: m),
                  emptyText: 'No tienes partidos aplazados.',
                  onRefresh: onRefresh,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList({
    required this.matches,
    required this.builder,
    required this.emptyText,
    required this.onRefresh,
  });

  final List<MatchData> matches;
  final Widget Function(MatchData) builder;
  final String emptyText;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceLow,
      onRefresh: onRefresh,
      child: matches.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(AppSpacing.huge),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: AppSpacing.huge),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow,
                    borderRadius: AppRadius.brSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    emptyText,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (_, i) => builder(matches[i]),
            ),
    );
  }
}
