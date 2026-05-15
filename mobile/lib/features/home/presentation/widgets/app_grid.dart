import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_leon_de_juda/core/router/app_route.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';

/// Grid 2x4 de accesos rapidos a subpaginas. Patron AppGrid del web pero
/// rediseñado para feel app: ripple, surface elevation, tap targets grandes.
class AppGrid extends StatelessWidget {
  const AppGrid({super.key});

  static const _items = <_GridItem>[
    _GridItem(
      route: AppRoute.calendar,
      icon: Icons.calendar_today_rounded,
      label: 'Calendario',
      description: 'Próximos y finalizados',
    ),
    _GridItem(
      route: AppRoute.standings,
      icon: Icons.emoji_events_rounded,
      label: 'Posiciones',
      description: 'Clasificación por grupos',
    ),
    _GridItem(
      route: AppRoute.scorers,
      icon: Icons.sports_soccer_rounded,
      label: 'Goleadores',
      description: 'Máximos artilleros',
    ),
    _GridItem(
      route: AppRoute.defense,
      icon: Icons.shield_rounded,
      label: 'Valla',
      description: 'Menos vencida',
    ),
    _GridItem(
      route: AppRoute.team,
      icon: Icons.groups_rounded,
      label: 'Equipo',
      description: 'Organigrama oficial',
    ),
    _GridItem(
      route: AppRoute.sponsors,
      icon: Icons.favorite_rounded,
      label: 'Patrocinadores',
      description: 'Aliados del torneo',
    ),
    _GridItem(
      route: AppRoute.about,
      icon: Icons.info_rounded,
      label: 'Sobre el Torneo',
      description: 'Información oficial',
    ),
    _GridItem(
      route: AppRoute.pqrs,
      icon: Icons.chat_bubble_outline_rounded,
      label: 'PQRS',
      description: 'Peticiones y sugerencias',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.55,
      children: [
        for (final item in _items) _AppGridCard(item: item),
      ],
    );
  }
}

class _AppGridCard extends StatelessWidget {
  const _AppGridCard({required this.item});
  final _GridItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.goNamed(item.route.name),
        borderRadius: AppRadius.brMd,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.brMd,
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryTintMedium,
                  borderRadius: AppRadius.brSm,
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: AppTypography.headerSmall.copyWith(
                    fontSize: 15,
                  ),),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridItem {
  const _GridItem({
    required this.route,
    required this.icon,
    required this.label,
    required this.description,
  });

  final AppRoute route;
  final IconData icon;
  final String label;
  final String description;
}
