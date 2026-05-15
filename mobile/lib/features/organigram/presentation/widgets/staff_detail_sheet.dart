import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/organigram/data/mock_organigram_data.dart';
import 'package:torneo_leon_de_juda/shared/widgets/player_photo.dart';

/// Bottom sheet con detalle de un miembro del staff. Foto, nombre, rol,
/// iglesia, bio y contacto si está disponible.
class StaffDetailSheet extends StatelessWidget {
  const StaffDetailSheet({required this.member, super.key});

  final StaffMemberMock member;

  static Future<void> show(BuildContext context, StaffMemberMock member) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StaffDetailSheet(member: member),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayerPhoto(
                  firstName: member.firstName,
                  lastName: member.lastName,
                  photoUrl: member.photoUrl,
                  fallbackColor: AppColors.primary,
                  size: 72,
                  shape: PlayerPhotoShape.squareRounded,
                  bordered: true,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: AppTypography.headerSmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTintMedium,
                          borderRadius: AppRadius.brXs,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          member.role,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (member.church != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            const Icon(
                              Icons.church_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                member.church!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (member.bio != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('BIOGRAFÍA', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                member.bio!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
            if (member.email != null || member.phone != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('CONTACTO', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              if (member.email != null)
                _ContactRow(
                  icon: Icons.mail_outline_rounded,
                  value: member.email!,
                ),
              if (member.phone != null) ...[
                const SizedBox(height: AppSpacing.xs),
                _ContactRow(
                  icon: Icons.phone_outlined,
                  value: member.phone!,
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
