import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/features/standings/data/mock_standings_data.dart';
import 'package:torneo_leon_de_juda/features/standings/presentation/widgets/standing_detail_sheet.dart';
import 'package:torneo_leon_de_juda/features/standings/presentation/widgets/standings_header.dart';
import 'package:torneo_leon_de_juda/features/standings/presentation/widgets/standings_table.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';

/// Pantalla Tabla de Posiciones. Muestra el header del torneo + las tablas
/// agrupadas por grupo (por ahora solo grupo A en mock). Cada fila es
/// tappeable y abre un bottom sheet con el detalle completo del equipo.
class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final standingsByGroup = <String, List<StandingMock>>{};
    for (final s in MockStandingsData.standings) {
      standingsByGroup.putIfAbsent(s.group, () => []).add(s);
    }

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
          await Future<void>.delayed(const Duration(milliseconds: 600));
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const StandingsHeader(
              tournamentName: MockStandingsData.tournamentName,
              seasonName: MockStandingsData.seasonName,
              category: MockStandingsData.category,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final entry in standingsByGroup.entries) ...[
              StandingsTable(
                group: entry.key,
                standings: entry.value,
                onTapStanding: (s) => StandingDetailSheet.show(context, s),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}
