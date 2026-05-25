import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/scorers/data/scorer.dart';
import 'package:torneo_leon_de_juda/features/scorers/data/scorers_repository.dart';
import 'package:torneo_leon_de_juda/features/scorers/presentation/widgets/scorer_detail_sheet.dart';
import 'package:torneo_leon_de_juda/features/scorers/presentation/widgets/scorer_podium.dart';
import 'package:torneo_leon_de_juda/features/scorers/presentation/widgets/scorer_row.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';
import 'package:torneo_leon_de_juda/shared/widgets/brand_menu_button.dart';

/// Pantalla Goleadores. Top 3 en podio + lista del resto del ranking.
class ScorersScreen extends ConsumerWidget {
  const ScorersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(scorersProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: const BrandMenuButton(),
        leadingWidth: 52,
        title: const Text('Goleadores'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          ref.invalidate(scorersProvider);
          await ref.read(scorersProvider.future);
        },
        child: AsyncView<List<Scorer>>(
          value: async,
          onRetry: () => ref.invalidate(scorersProvider),
          data: (scorers) => _Body(scorers: scorers),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.scorers});

  final List<Scorer> scorers;

  @override
  Widget build(BuildContext context) {
    if (scorers.isEmpty) {
      return const _EmptyState();
    }

    final top1 = scorers[0];
    final top2 = scorers.length > 1 ? scorers[1] : null;
    final top3 = scorers.length > 2 ? scorers[2] : null;
    final rest = scorers.length > 3 ? scorers.sublist(3) : <Scorer>[];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
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
                    const Divider(height: 1, color: AppColors.divider),
                  ScorerRow(
                    scorer: rest[i],
                    onTap: () => ScorerDetailSheet.show(context, rest[i]),
                  ),
                ],
              ],
            ),
          ),
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
