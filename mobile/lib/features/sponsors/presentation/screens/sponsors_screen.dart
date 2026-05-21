import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/sponsors/data/sponsor.dart';
import 'package:torneo_leon_de_juda/features/sponsors/data/sponsors_repository.dart';
import 'package:torneo_leon_de_juda/features/sponsors/presentation/widgets/sponsor_detail_sheet.dart';
import 'package:torneo_leon_de_juda/features/sponsors/presentation/widgets/sponsor_grid_tile.dart';
import 'package:torneo_leon_de_juda/features/sponsors/presentation/widgets/sponsor_oficial_card.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';

/// Pantalla Patrocinadores. Tres secciones jerárquicas: Oficiales (cards
/// destacadas), Aliados (grid 2-col), Apoyos (grid 3-col compacto).
class SponsorsScreen extends ConsumerWidget {
  const SponsorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSponsors = ref.watch(sponsorsProvider);

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
        title: const Text('Patrocinadores'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          ref.invalidate(sponsorsProvider);
          await ref.read(sponsorsProvider.future);
        },
        child: AsyncView<List<Sponsor>>(
          value: asyncSponsors,
          onRetry: () => ref.invalidate(sponsorsProvider),
          data: (sponsors) => _SponsorsList(sponsors: sponsors),
        ),
      ),
    );
  }
}

class _SponsorsList extends StatelessWidget {
  const _SponsorsList({required this.sponsors});

  final List<Sponsor> sponsors;

  @override
  Widget build(BuildContext context) {
    final oficiales = sponsors.where((s) => s.tier == SponsorTier.oficial).toList(growable: false);
    final aliados = sponsors.where((s) => s.tier == SponsorTier.aliado).toList(growable: false);
    final apoyos = sponsors.where((s) => s.tier == SponsorTier.apoyo).toList(growable: false);

    if (sponsors.isEmpty) {
      return const _EmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const _IntroBanner(),
        const SizedBox(height: AppSpacing.xl),

        if (oficiales.isNotEmpty) ...[
          _SectionHeader(
            title: SponsorTier.oficial.displayName,
            count: oficiales.length,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < oficiales.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            SponsorOficialCard(
              sponsor: oficiales[i],
              onTap: () => SponsorDetailSheet.show(context, oficiales[i]),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],

        if (aliados.isNotEmpty) ...[
          _SectionHeader(
            title: SponsorTier.aliado.displayName,
            count: aliados.length,
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.3,
            children: [
              for (final sponsor in aliados)
                SponsorGridTile(
                  sponsor: sponsor,
                  logoSize: 64,
                  onTap: () => SponsorDetailSheet.show(context, sponsor),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],

        if (apoyos.isNotEmpty) ...[
          _SectionHeader(
            title: SponsorTier.apoyo.displayName,
            count: apoyos.length,
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.xs,
            mainAxisSpacing: AppSpacing.xs,
            childAspectRatio: 0.95,
            children: [
              for (final sponsor in apoyos)
                SponsorGridTile(
                  sponsor: sponsor,
                  logoSize: 48,
                  onTap: () => SponsorDetailSheet.show(context, sponsor),
                ),
            ],
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
                Icons.favorite_outline_rounded,
                size: 36,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin patrocinadores activos',
              style: AppTypography.headerSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Aún no se han registrado aliados del torneo.',
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

class _IntroBanner extends StatelessWidget {
  const _IntroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.cardPremiumGradient,
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryTintMedium,
              borderRadius: AppRadius.brSm,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hacen posible el torneo',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Gracias a nuestros aliados por apoyar este sueño deportivo.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: AppTypography.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: AppRadius.brXs,
            ),
            child: Text(
              '$count',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
