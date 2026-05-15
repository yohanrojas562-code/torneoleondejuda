import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';

/// Pantalla placeholder para rutas que aun no estan implementadas.
/// Muestra icono + titulo + leyenda "Proximamente". Se reemplaza cuando
/// cada feature se construye en su Step correspondiente.
///
/// Por defecto incluye el AppDrawer compartido — consistente con el patron
/// del web mobile. Para una pantalla sin drawer (ej. login, modal), pasa
/// `showDrawer: false`.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.icon,
    this.subtitle,
    this.stepRef,
    this.showDrawer = true,
    super.key,
  });

  final String title;
  final IconData icon;
  final String? subtitle;

  /// Referencia al Step donde se implementa (ej. 'Step 10') — solo dev.
  final String? stepRef;

  final bool showDrawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: showDrawer ? const AppDrawer() : null,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primaryTintMedium,
                  borderRadius: AppRadius.brXl,
                ),
                child: Icon(icon, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTypography.headerLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle ?? 'Próximamente disponible',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (stepRef != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow,
                    borderRadius: AppRadius.brPill,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    stepRef!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
