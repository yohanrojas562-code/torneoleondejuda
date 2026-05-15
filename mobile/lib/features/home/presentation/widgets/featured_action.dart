import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_leon_de_juda/core/router/app_route.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';

/// CTA prominente "Validar jugador con QR". Full-width gold, principal accion
/// para arbitros y staff. Lleva a /verificar (Step 16 implementa la pantalla).
class FeaturedAction extends StatelessWidget {
  const FeaturedAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.goNamed(AppRoute.verify.name),
        borderRadius: AppRadius.brLg,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: AppRadius.brLg,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brMd,
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.textOnPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validar jugador',
                      style: AppTypography.headerSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Escanea el QR del carnet o busca por documento',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textOnPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
