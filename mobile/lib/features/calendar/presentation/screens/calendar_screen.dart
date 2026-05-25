import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/calendar_repository.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/match_data.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/finished_match_card.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/matches_tab.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/postponed_match_card.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/upcoming_match_card.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';
import 'package:torneo_leon_de_juda/shared/widgets/brand_menu_button.dart';

/// Pantalla Calendario con 3 tabs: Próximos · Finalizados · Aplazados.
/// Cada tab tiene su propia lista, pull-to-refresh y empty state.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(calendarProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: const BrandMenuButton(),
        leadingWidth: 52,
        title: const Text('Calendario'),
      ),
      body: AsyncView<CalendarData>(
        value: async,
        onRetry: () => ref.invalidate(calendarProvider),
        data: (data) => _Tabs(
          data: data,
          onRefresh: () async {
            ref.invalidate(calendarProvider);
            await ref.read(calendarProvider.future);
          },
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.data, required this.onRefresh});

  final CalendarData data;
  final Future<void> Function() onRefresh;

  Map<DateTime, List<MatchData>> _groupByDate(List<MatchData> items) {
    final map = <DateTime, List<MatchData>>{};
    final sorted = [...items]
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    for (final item in sorted) {
      final d = item.scheduledAt;
      final key = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final upcomingByDate = _groupByDate(data.upcoming);
    // Finalizados: orden desc (más reciente primero).
    final finishedByDate = Map.fromEntries(
      _groupByDate(data.finished).entries.toList().reversed,
    );
    final postponedByDate = _groupByDate(data.postponed);

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
              indicatorWeight: 3,
              labelStyle: AppTypography.buttonMedium,
              unselectedLabelStyle: AppTypography.buttonMedium,
              dividerColor: AppColors.border,
              tabs: [
                Tab(
                  child: _TabLabel(
                    label: 'Próximos',
                    count: data.upcoming.length,
                  ),
                ),
                Tab(
                  child: _TabLabel(
                    label: 'Finalizados',
                    count: data.finished.length,
                  ),
                ),
                Tab(
                  child: _TabLabel(
                    label: 'Aplazados',
                    count: data.postponed.length,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                MatchesTab<MatchData>(
                  itemsByDate: upcomingByDate,
                  onRefresh: onRefresh,
                  itemBuilder: (_, m) => UpcomingMatchCard(match: m),
                  emptyIcon: Icons.calendar_today_rounded,
                  emptyTitle: 'No hay partidos próximos',
                  emptySubtitle:
                      'Cuando se programe la siguiente jornada, aparecerá aquí.',
                ),
                MatchesTab<MatchData>(
                  itemsByDate: finishedByDate,
                  onRefresh: onRefresh,
                  itemBuilder: (_, m) => FinishedMatchCard(match: m),
                  emptyIcon: Icons.history_rounded,
                  emptyTitle: 'Sin partidos finalizados',
                  emptySubtitle:
                      'Los resultados aparecerán aquí cuando comience el torneo.',
                ),
                MatchesTab<MatchData>(
                  itemsByDate: postponedByDate,
                  onRefresh: onRefresh,
                  itemBuilder: (_, m) => PostponedMatchCard(match: m),
                  emptyIcon: Icons.event_available_rounded,
                  emptyTitle: 'Sin partidos aplazados',
                  emptySubtitle:
                      'Cualquier reprogramación se mostrará en esta sección.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.primaryTintMedium,
              borderRadius: AppRadius.brPill,
            ),
            constraints: const BoxConstraints(minWidth: 18),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
