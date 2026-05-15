import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/sponsors/data/mock_sponsors_data.dart';
import 'package:torneo_leon_de_juda/features/sponsors/presentation/widgets/sponsor_logo.dart';

/// Tile compacta para patrocinadores en grid (aliados y apoyos). Logo
/// centrado + nombre debajo. El parametro [logoSize] permite reutilizar la
/// misma tile en 2-col (aliados, logo 64) y 3-col (apoyos, logo 48).
class SponsorGridTile extends StatelessWidget {
  const SponsorGridTile({
    required this.sponsor,
    required this.onTap,
    required this.logoSize,
    super.key,
  });

  final SponsorMock sponsor;
  final VoidCallback onTap;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brSm,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.brSm,
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SponsorLogo(sponsor: sponsor, size: logoSize),
              const SizedBox(height: AppSpacing.xs),
              Text(
                sponsor.name,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: logoSize >= 60 ? 12 : 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
