import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/pqrs/data/pqrs.dart';

/// Selector segmentado de tipo de PQRS (Petición / Queja / Reclamo /
/// Sugerencia). Grid 2x2 con tile resaltada para la selección activa.
class PqrsTypeSelector extends StatelessWidget {
  const PqrsTypeSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final PqrsType selected;
  final ValueChanged<PqrsType> onChanged;

  IconData _iconFor(PqrsType type) {
    return switch (type) {
      PqrsType.peticion => Icons.assignment_outlined,
      PqrsType.queja => Icons.report_problem_outlined,
      PqrsType.reclamo => Icons.gavel_rounded,
      PqrsType.sugerencia => Icons.lightbulb_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.4,
      children: [
        for (final type in PqrsType.values)
          _TypeTile(
            type: type,
            icon: _iconFor(type),
            isSelected: type == selected,
            onTap: () => onChanged(type),
          ),
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.type,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final PqrsType type;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brSm,
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryTintMedium
                : AppColors.surfaceLow,
            borderRadius: AppRadius.brSm,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  type.label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
