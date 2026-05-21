import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/home/data/home_data.dart';
import 'package:torneo_leon_de_juda/features/home/data/home_repository.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';

/// Pantalla "Sobre el Torneo". Muestra los 4 pilares del torneo (Fe,
/// Comunidad, Disciplina, Excelencia) + la temporada activa (reusa el
/// home provider para no duplicar requests).
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeProvider);
    final season = async.maybeWhen(
      data: (data) => data.activeSeason,
      orElse: () => null,
    );

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
        title: const Text('Sobre el Torneo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _HeroBanner(season: season),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xxs),
            child: Text(
              'NUESTROS PILARES',
              style: AppTypography.labelLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _PillarCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Fe en Cristo',
            description:
                'Cada jugada es un testimonio de nuestra fe y compromiso '
                'con los valores del Evangelio.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _PillarCard(
            icon: Icons.groups_rounded,
            title: 'Comunidad',
            description:
                'Fortalecemos lazos entre iglesias y familias, creando un '
                'ambiente de hermandad.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _PillarCard(
            icon: Icons.shield_rounded,
            title: 'Disciplina',
            description:
                'El deporte nos enseña perseverancia, respeto y trabajo en '
                'equipo.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _PillarCard(
            icon: Icons.emoji_events_rounded,
            title: 'Excelencia',
            description:
                'Damos lo mejor de nosotros dentro y fuera de la cancha, '
                'para la gloria de Dios.',
          ),
          const SizedBox(height: AppSpacing.xl),
          const _MissionCard(),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({this.season});

  final ActiveSeason? season;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.cardPremiumGradient,
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: AppRadius.brMd,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 32,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            season?.tournamentName ?? 'Torneo León de Judá',
            style: AppTypography.headerLarge,
          ),
          if (season?.seasonName != null) ...[
            const SizedBox(height: 4),
            Text(
              season!.seasonName,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'Un torneo de fútbol que une a las iglesias del Centro de Fe '
            'a través del deporte, la fe y la sana competencia.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  const _PillarCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryTintMedium,
              borderRadius: AppRadius.brSm,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headerSmall.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'NUESTRA MISIÓN',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Promover la unidad entre las iglesias del Centro de Fe a '
            'través del deporte, fortalecer los lazos comunitarios y dar '
            'testimonio de los valores del Evangelio en cada encuentro.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
