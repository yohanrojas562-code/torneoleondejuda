import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/defense/data/defense.dart';
import 'package:torneo_leon_de_juda/features/defense/data/defense_repository.dart';
import 'package:torneo_leon_de_juda/features/defense/presentation/widgets/defense_detail_sheet.dart';
import 'package:torneo_leon_de_juda/features/defense/presentation/widgets/defense_podium.dart';
import 'package:torneo_leon_de_juda/features/defense/presentation/widgets/defense_row.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';

/// Pantalla Valla Menos Vencida.
class DefenseScreen extends ConsumerWidget {
  const DefenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(defenseProvider);

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
        title: const Text('Valla Menos Vencida'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          ref.invalidate(defenseProvider);
          await ref.read(defenseProvider.future);
        },
        child: AsyncView<List<Defense>>(
          value: async,
          onRetry: () => ref.invalidate(defenseProvider),
          data: (defenses) => _Body(defenses: defenses),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.defenses});

  final List<Defense> defenses;

  @override
  Widget build(BuildContext context) {
    if (defenses.isEmpty) {
      return const _EmptyState();
    }

    final top1 = defenses[0];
    final top2 = defenses.length > 1 ? defenses[1] : null;
    final top3 = defenses.length > 2 ? defenses[2] : null;
    final rest = defenses.length > 3 ? defenses.sublist(3) : <Defense>[];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        DefensePodium(
          top1: top1,
          top2: top2,
          top3: top3,
          onTap: (d) => DefenseDetailSheet.show(context, d),
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
                  DefenseRow(
                    defense: rest[i],
                    onTap: () =>
                        DefenseDetailSheet.show(context, rest[i]),
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
                Icons.shield_outlined,
                size: 36,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin datos de porteros',
              style: AppTypography.headerSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'El ranking de vallas aparecerá cuando se jueguen los primeros partidos.',
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
