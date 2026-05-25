import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/home/data/home_data.dart';
import 'package:torneo_leon_de_juda/features/home/data/home_repository.dart';

/// Reemplazo del IconButton hamburger en los AppBars de la app. Muestra el
/// logo del torneo (cuando la API lo expone) o el placeholder "LJ" gold
/// como fallback. Tap → abre el drawer del Scaffold padre.
class BrandMenuButton extends ConsumerWidget {
  const BrandMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reusa el homeProvider porque ya tiene la info de la temporada activa
    // con tournament logo. Si no está cargado, cae al placeholder LJ.
    final logoUrl = ref.watch(homeProvider).maybeWhen(
          data: (HomeData data) => data.activeSeason?.tournamentLogoUrl,
          orElse: () => null,
        );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Scaffold.of(context).openDrawer(),
          borderRadius: AppRadius.brSm,
          child: Ink(
            decoration: BoxDecoration(
              gradient:
                  logoUrl == null ? AppColors.goldGradient : null,
              color: logoUrl == null ? null : Colors.white,
              borderRadius: AppRadius.brSm,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: SizedBox(
              width: 36,
              height: 36,
              child: logoUrl != null
                  ? Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: AppRadius.brXs,
                        child: CachedNetworkImage(
                          imageUrl: logoUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const _PlaceholderLJ(),
                          errorWidget: (_, __, ___) =>
                              const _PlaceholderLJ(),
                        ),
                      ),
                    )
                  : const _PlaceholderLJ(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderLJ extends StatelessWidget {
  const _PlaceholderLJ();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'LJ',
        style: AppTypography.buttonSmall.copyWith(
          color: AppColors.textOnPrimary,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
