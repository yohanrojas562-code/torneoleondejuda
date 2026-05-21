import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/organigram/data/staff_member.dart';
import 'package:torneo_leon_de_juda/features/organigram/presentation/widgets/staff_row.dart';

/// Grupo de staff. Header con icono (derivado del tier) + título + contador
/// y lista de [StaffRow]. La sección se construye en el repositorio
/// agrupando miembros por tier — ver organigram_repository.dart.
class StaffSection extends StatelessWidget {
  const StaffSection({
    required this.section,
    required this.onTapMember,
    super.key,
  });

  final OrgSection section;
  final ValueChanged<StaffMember> onTapMember;

  IconData get _icon {
    return switch (section.tier) {
      1 => Icons.gavel_rounded,
      2 => Icons.groups_rounded,
      _ => Icons.shield_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xxs),
          child: Row(
            children: [
              Icon(_icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  section.title.toUpperCase(),
                  style: AppTypography.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: AppRadius.brXs,
                ),
                child: Text(
                  '${section.members.length}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.brMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < section.members.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: AppColors.divider),
                StaffRow(
                  member: section.members[i],
                  onTap: () => onTapMember(section.members[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
