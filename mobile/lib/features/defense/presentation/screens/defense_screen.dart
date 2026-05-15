import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/defense/data/mock_defense_data.dart';
import 'package:torneo_leon_de_juda/features/defense/presentation/widgets/defense_detail_sheet.dart';
import 'package:torneo_leon_de_juda/features/defense/presentation/widgets/defense_podium.dart';
import 'package:torneo_leon_de_juda/features/defense/presentation/widgets/defense_row.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';

/// Pantalla Valla Menos Vencida. Top 3 porteros titulares con menos goles
/// encajados en podio destacado + lista del resto. Tap en cualquier portero
/// → bottom sheet con detalle.
class DefenseScreen extends StatelessWidget {
  const DefenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const defenses = MockDefenseData.defenses;
    final top1 = defenses.isNotEmpty ? defenses[0] : null;
    final top2 = defenses.length > 1 ? defenses[1] : null;
    final top3 = defenses.length > 2 ? defenses[2] : null;
    final rest = defenses.length > 3 ? defenses.sublist(3) : <DefenseMock>[];

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
          await Future<void>.delayed(const Duration(milliseconds: 600));
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (top1 == null)
              const _EmptyState()
            else ...[
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
                          const Divider(
                            height: 1,
                            color: AppColors.divider,
                          ),
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
