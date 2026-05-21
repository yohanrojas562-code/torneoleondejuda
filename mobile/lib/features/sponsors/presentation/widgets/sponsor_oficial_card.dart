import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/sponsors/data/sponsor.dart';
import 'package:torneo_leon_de_juda/features/sponsors/presentation/widgets/sponsor_logo.dart';

/// Card destacada para patrocinadores tier "oficial". Logo grande + nombre +
/// categoría. Tap → bottom sheet.
class SponsorOficialCard extends StatelessWidget {
  const SponsorOficialCard({
    required this.sponsor,
    required this.onTap,
    super.key,
  });

  final Sponsor sponsor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brMd,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.cardPremiumGradient,
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.brMd,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SponsorLogo(sponsor: sponsor, size: 72),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sponsor.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sponsor.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        sponsor.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
