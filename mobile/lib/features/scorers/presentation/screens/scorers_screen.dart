import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/scorers/data/mock_scorers_data.dart';
import 'package:torneo_leon_de_juda/features/scorers/presentation/widgets/scorer_detail_sheet.dart';
import 'package:torneo_leon_de_juda/features/scorers/presentation/widgets/scorer_podium.dart';
import 'package:torneo_leon_de_juda/features/scorers/presentation/widgets/scorer_row.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';

/// Pantalla Goleadores. Top 3 en podio destacado + lista del resto del
/// ranking. Tap en cualquier jugador → bottom sheet con detalle.
class ScorersScreen extends StatelessWidget {
  const ScorersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const scorers = MockScorersData.scorers;
    final top1 = scorers.isNotEmpty ? scorers[0] : null;
    final top2 = scorers.length > 1 ? scorers[1] : null;
    final top3 = scorers.length > 2 ? scorers[2] : null;
    final rest = scorers.length > 3 ? scorers.sublist(3) : <ScorerMock>[];

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
        title: const Text('Goleadores'),
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
            if (top1 == null)
              const _EmptyState()
            else ...[
              ScorerPodium(
                top1: top1,
                top2: top2,
                top3: top3,
                onTap: (s) => ScorerDetailSheet.show(context, s),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (rest.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xxs),
                  child: Text(
                    'RANKING COMPLETO',
                    style: AppTypography.labelLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow,
                    borderRadius: AppRadius.brMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < rest.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            color: AppColors.divider,
                          ),
                        ScorerRow(
                          scorer: rest[i],
                          onTap: () =>
                              ScorerDetailSheet.show(context, rest[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
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
                Icons.sports_soccer_outlined,
                size: 36,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin goles registrados',
              style: AppTypography.headerSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'El ranking de goleadores aparecerá cuando se jueguen los primeros partidos.',
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
