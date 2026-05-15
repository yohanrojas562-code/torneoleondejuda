import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/features/organigram/data/mock_organigram_data.dart';
import 'package:torneo_leon_de_juda/features/organigram/presentation/widgets/president_hero.dart';
import 'package:torneo_leon_de_juda/features/organigram/presentation/widgets/staff_detail_sheet.dart';
import 'package:torneo_leon_de_juda/features/organigram/presentation/widgets/staff_section.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';

/// Pantalla Equipo / Organigrama. Presidente como hero card arriba +
/// secciones (Junta Directiva, Coordinación, Comisión Técnica, Árbitros,
/// Comité de Disciplina). Tap en cualquier miembro → bottom sheet.
class OrganigramScreen extends StatelessWidget {
  const OrganigramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const president = MockOrganigramData.president;
    const sections = MockOrganigramData.sections;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menú',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Equipo'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 600));
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            PresidentHero(
              president: president,
              onTap: () => StaffDetailSheet.show(context, president),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.lg),
              StaffSection(
                section: sections[i],
                onTapMember: (m) => StaffDetailSheet.show(context, m),
              ),
            ],
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}
