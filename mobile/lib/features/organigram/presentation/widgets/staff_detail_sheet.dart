import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/organigram/data/staff_member.dart';
import 'package:torneo_leon_de_juda/shared/widgets/player_photo.dart';

/// Bottom sheet con detalle de un miembro del staff. Foto, nombre, roles
/// como chips, y descripción libre si existe.
class StaffDetailSheet extends StatelessWidget {
  const StaffDetailSheet({required this.member, super.key});

  final StaffMember member;

  static Future<void> show(BuildContext context, StaffMember member) {
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
                        member.name,
                        style: AppTypography.headerSmall,
                      ),
                      if (member.roles.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final role in member.roles) _RoleChip(role),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (member.description != null &&
                member.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('DESCRIPCIÓN', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                member.description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryTintMedium,
        borderRadius: AppRadius.brXs,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.primary,
          fontSize: 11,
        ),
      ),
    );
  }
}
