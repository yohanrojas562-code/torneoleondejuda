import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/mock_calendar_data.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/finished_match_card.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/matches_tab.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/postponed_match_card.dart';
import 'package:torneo_leon_de_juda/features/calendar/presentation/widgets/upcoming_match_card.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';

/// Pantalla Calendario con 3 tabs: Proximos · Finalizados · Aplazados.
/// Cada tab tiene su propia lista, pull-to-refresh y empty state.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  Map<DateTime, List<T>> _groupByDate<T>(
    List<T> items,
    DateTime Function(T) dateOf,
  ) {
    final map = <DateTime, List<T>>{};
    final sorted = [...items]..sort(
      (a, b) => dateOf(a).compareTo(dateOf(b)),
    );
    for (final item in sorted) {
      final d = dateOf(item);
      final key = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = MockCalendarData.upcoming;
    final finished = MockCalendarData.finished;
    final postponed = MockCalendarData.postponed;

    final upcomingByDate = _groupByDate<UpcomingMatchMock>(
      upcoming,
      (m) => m.scheduledAt,
    );
    // Finalizados: orden desc (mas reciente primero)
    final finishedByDate = Map.fromEntries(
      _groupByDate<FinishedMatchMock>(finished, (m) => m.playedAt)
          .entries
          .toList()
          .reversed,
    );
    final postponedByDate = _groupByDate<PostponedMatchMock>(
      postponed,
      (m) => m.originalDate,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Menú',
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text('Calendario'),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: AppTypography.buttonMedium,
            unselectedLabelStyle: AppTypography.buttonMedium,
            dividerColor: AppColors.border,
            tabs: [
              Tab(
                child: _TabLabel(label: 'Próximos', count: upcoming.length),
              ),
              Tab(
                child: _TabLabel(label: 'Finalizados', count: finished.length),
              ),
              Tab(
                child: _TabLabel(label: 'Aplazados', count: postponed.length),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MatchesTab<UpcomingMatchMock>(
              itemsByDate: upcomingByDate,
              itemBuilder: (_, m) => UpcomingMatchCard(match: m),
              emptyIcon: Icons.calendar_today_rounded,
              emptyTitle: 'No hay partidos próximos',
              emptySubtitle:
                  'Cuando se programe la siguiente jornada, aparecerá aquí.',
            ),
            MatchesTab<FinishedMatchMock>(
              itemsByDate: finishedByDate,
              itemBuilder: (_, m) => FinishedMatchCard(match: m),
              emptyIcon: Icons.history_rounded,
              emptyTitle: 'Sin partidos finalizados',
              emptySubtitle:
                  'Los resultados aparecerán aquí cuando comience el torneo.',
            ),
            MatchesTab<PostponedMatchMock>(
              itemsByDate: postponedByDate,
              itemBuilder: (_, m) => PostponedMatchCard(match: m),
              emptyIcon: Icons.event_available_rounded,
              emptyTitle: 'Sin partidos aplazados',
              emptySubtitle: 'Cualquier reprogramación se mostrará en esta sección.',
            ),
          ],
        ),
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
