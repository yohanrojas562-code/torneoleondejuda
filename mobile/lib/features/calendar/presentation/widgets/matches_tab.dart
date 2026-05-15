import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/calendar/data/mock_calendar_data.dart';

/// Wrapper generico para una tab del calendario. Recibe la lista pre-agrupada
/// por dia y un builder que renderiza cada item. Maneja empty state y
/// pull-to-refresh por separado.
class MatchesTab<T> extends StatelessWidget {
  const MatchesTab({
    required this.itemsByDate,
    required this.itemBuilder,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    super.key,
  });

  /// Map ordenado: fecha (key, ya formateada) → lista de matches.
  final Map<DateTime, List<T>> itemsByDate;

  final Widget Function(BuildContext, T) itemBuilder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceLow,
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: itemsByDate.isEmpty
          ? _EmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              subtitle: emptySubtitle,
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                for (final entry in itemsByDate.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.xxs,
                      bottom: AppSpacing.xs,
                    ),
                    child: Text(
                      matchDateLabel(entry.key),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  for (final item in entry.value) ...[
                    itemBuilder(context, item),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.huge),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    // ListView wrapping para permitir pull-to-refresh aun cuando esta vacio
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.huge),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: AppSpacing.huge),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: AppRadius.brLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, size: 36, color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTypography.headerSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
