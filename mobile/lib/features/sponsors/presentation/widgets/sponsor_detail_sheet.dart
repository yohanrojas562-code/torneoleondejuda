import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/sponsors/data/mock_sponsors_data.dart';
import 'package:torneo_leon_de_juda/features/sponsors/presentation/widgets/sponsor_logo.dart';

/// Bottom sheet con detalle de un patrocinador: logo grande, nombre,
/// categoría, descripción y sitio web (copiable).
class SponsorDetailSheet extends StatelessWidget {
  const SponsorDetailSheet({required this.sponsor, super.key});

  final SponsorMock sponsor;

  static Future<void> show(BuildContext context, SponsorMock sponsor) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SponsorDetailSheet(sponsor: sponsor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SponsorLogo(sponsor: sponsor, size: 110),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              sponsor.name,
              style: AppTypography.headerSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: _TierBadge(tier: sponsor.tier),
            ),
            if (sponsor.category != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                sponsor.category!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (sponsor.description != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                sponsor.description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
            if (sponsor.website != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _WebsiteRow(url: sponsor.website!),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});
  final SponsorTier tier;

  Color get _color {
    return switch (tier) {
      SponsorTier.oficial => AppColors.primary,
      SponsorTier.aliado => const Color(0xFFC0C0C0),
      SponsorTier.apoyo => const Color(0xFFCD7F32),
    };
  }

  String get _label {
    return switch (tier) {
      SponsorTier.oficial => 'OFICIAL',
      SponsorTier.aliado => 'ALIADO',
      SponsorTier.apoyo => 'APOYO',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: AppRadius.brXs,
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label,
        style: AppTypography.labelSmall.copyWith(
          color: _color,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _WebsiteRow extends StatelessWidget {
  const _WebsiteRow({required this.url});
  final String url;

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: url));
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Enlace copiado al portapapeles'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.surfaceHigh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _copy(context),
        borderRadius: AppRadius.brSm,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.brSm,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.link_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  url,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
