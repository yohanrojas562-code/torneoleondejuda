import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/home/data/mock_home_data.dart';
import 'package:torneo_leon_de_juda/features/home/presentation/widgets/app_grid.dart';
import 'package:torneo_leon_de_juda/features/home/presentation/widgets/featured_action.dart';
import 'package:torneo_leon_de_juda/features/home/presentation/widgets/home_hero.dart';
import 'package:torneo_leon_de_juda/features/home/presentation/widgets/upcoming_matches.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';

/// Pantalla Home — primer punto de contacto del usuario. AppBar custom,
/// hero card de temporada activa, CTA Validar QR, AppGrid 2x4 con accesos
/// rapidos y row horizontal de proximos partidos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const season = MockHomeData.activeSeason;
    final upcoming = MockHomeData.upcomingMatches;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                'LJ',
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'León de Judá',
              style: AppTypography.headerSmall.copyWith(fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notificaciones',
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.xxs),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          // Mock refresh: en Step 19 invalidamos los providers
          await Future<void>.delayed(const Duration(milliseconds: 600));
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const HomeHero(season: season),
            const SizedBox(height: AppSpacing.lg),
            const FeaturedAction(),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xxs),
              child: Text('EXPLORA', style: AppTypography.labelLarge),
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppGrid(),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xxs),
                  child: Text(
                    'PRÓXIMOS PARTIDOS',
                    style: AppTypography.labelLarge,
                  ),
                ),
                const Spacer(),
                Text(
                  '${upcoming.length} programados',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            UpcomingMatchesRow(matches: upcoming),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}
