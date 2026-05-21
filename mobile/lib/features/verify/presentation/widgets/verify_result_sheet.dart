import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/verify/data/verify_result.dart';
import 'package:torneo_leon_de_juda/shared/widgets/player_photo.dart';
import 'package:torneo_leon_de_juda/shared/widgets/team_badge.dart';

/// Bottom sheet con el resultado de la verificación de un jugador. Banner
/// de estado arriba (verde si aprobado, rojo/naranja si no), foto, datos y
/// razón si aplica. Si [result] es null muestra el estado "no encontrado".
class VerifyResultSheet extends StatelessWidget {
  const VerifyResultSheet({
    required this.result,
    required this.searchedCode,
    super.key,
  });

  final VerifyResult? result;
  final String searchedCode;

  static Future<void> show(
    BuildContext context, {
    required VerifyResult? result,
    required String searchedCode,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => VerifyResultSheet(
        result: result,
        searchedCode: searchedCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return _NotFoundView(searchedCode: searchedCode);
    }
    return _FoundView(result: result!);
  }
}

class _FoundView extends StatelessWidget {
  const _FoundView({required this.result});
  final VerifyResult result;

  Color get _statusColor {
    return switch (result.status) {
      VerifyStatus.approved => AppColors.victory,
      VerifyStatus.suspended => AppColors.defeat,
      VerifyStatus.expired => AppColors.warning,
      VerifyStatus.unregistered => AppColors.defeat,
    };
  }

  IconData get _statusIcon {
    return switch (result.status) {
      VerifyStatus.approved => Icons.check_circle_rounded,
      VerifyStatus.suspended => Icons.block_rounded,
      VerifyStatus.expired => Icons.schedule_rounded,
      VerifyStatus.unregistered => Icons.person_off_rounded,
    };
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
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.15),
                borderRadius: AppRadius.brSm,
                border: Border.all(
                  color: _statusColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon, color: _statusColor, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      result.status.label,
                      style: AppTypography.headerSmall.copyWith(
                        color: _statusColor,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayerPhoto(
                  firstName: result.firstName,
                  lastName: result.lastName,
                  photoUrl: result.photoUrl,
                  fallbackColor: result.team?.primaryColor ?? AppColors.primary,
                  size: 84,
                  shape: PlayerPhotoShape.squareRounded,
                  bordered: true,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.fullName,
                        style: AppTypography.headerSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CC ${result.document}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (result.team != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            TeamBadge(
                              name: result.team!.name,
                              logoUrl: result.team!.logoUrl,
                              primaryColor: result.team!.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                result.team!.name,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (result.jerseyNumber != null ||
                          result.position != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            if (result.jerseyNumber != null)
                              _Chip(label: '#${result.jerseyNumber}'),
                            if (result.jerseyNumber != null &&
                                result.position != null)
                              const SizedBox(width: 6),
                            if (result.position != null)
                              _Chip(label: result.position!),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (result.church != null) ...[
              const SizedBox(height: AppSpacing.md),
              _IconRow(
                icon: Icons.church_outlined,
                text: result.church!,
              ),
            ],
            if (result.reason != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.08),
                  borderRadius: AppRadius.brSm,
                  border: Border.all(
                    color: _statusColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: _statusColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        result.reason!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Escanear otro'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView({required this.searchedCode});
  final String searchedCode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.defeatTint,
                borderRadius: AppRadius.brLg,
                border: Border.all(
                  color: AppColors.defeat.withValues(alpha: 0.4),
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_off_rounded,
                size: 32,
                color: AppColors.defeat,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Jugador no encontrado',
              style: AppTypography.headerSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'No hay registro con el código "$searchedCode" en la base del torneo. '
              'Verifica el documento o pide al jugador su carnet oficial.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Volver a escanear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.brXs,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
