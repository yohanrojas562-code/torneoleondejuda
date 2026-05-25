import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/organigram/data/organigram_repository.dart';
import 'package:torneo_leon_de_juda/features/organigram/data/staff_member.dart';
import 'package:torneo_leon_de_juda/features/organigram/presentation/widgets/president_hero.dart';
import 'package:torneo_leon_de_juda/features/organigram/presentation/widgets/staff_detail_sheet.dart';
import 'package:torneo_leon_de_juda/features/organigram/presentation/widgets/staff_section.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';
import 'package:torneo_leon_de_juda/shared/widgets/brand_menu_button.dart';

/// Pantalla Equipo / Organigrama. Presidente como hero card + secciones
/// agrupadas por tier (Dirección, Coordinación, Apoyo). Tap en cualquier
/// miembro → bottom sheet.
class OrganigramScreen extends ConsumerWidget {
  const OrganigramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(organigramProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: const BrandMenuButton(),
        leadingWidth: 52,
        title: const Text('Equipo'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          ref.invalidate(organigramProvider);
          await ref.read(organigramProvider.future);
        },
        child: AsyncView<OrganigramData>(
          value: async,
          onRetry: () => ref.invalidate(organigramProvider),
          data: (data) => _Body(data: data),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data});

  final OrganigramData data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _EmptyState();
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (data.president != null)
          PresidentHero(
            president: data.president!,
            onTap: () =>
                StaffDetailSheet.show(context, data.president!),
          ),
        if (data.president != null && data.sections.isNotEmpty)
          const SizedBox(height: AppSpacing.xl),
        for (var i = 0; i < data.sections.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          StaffSection(
            section: data.sections[i],
            onTapMember: (m) => StaffDetailSheet.show(context, m),
          ),
        ],
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.huge),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: AppRadius.brLg,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.groups_outlined,
                size: 36,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin miembros activos',
              style: AppTypography.headerSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'El equipo organizador del torneo aún no se ha publicado.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
