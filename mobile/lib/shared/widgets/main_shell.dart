import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';

/// Shell con bottom navigation bar persistente para las 4 tabs principales.
/// Cada tab tiene su propio Navigator (no se mezcla el back stack entre tabs).
///
/// Se monta automaticamente para las rutas Home, Calendario, Posiciones y
/// Goleadores (las 4 branches del StatefulShellRoute).
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  /// Provista por StatefulShellRoute — el "switcher" entre las 4 ramas.
  final StatefulNavigationShell navigationShell;

  static const _tabs = <_NavItem>[
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Inicio',
    ),
    _NavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      label: 'Calendario',
    ),
    _NavItem(
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
      label: 'Posiciones',
    ),
    _NavItem(
      icon: Icons.sports_soccer_outlined,
      activeIcon: Icons.sports_soccer_rounded,
      label: 'Goleadores',
    ),
  ];

  void _onTabSelected(int index) {
    // Si tap a la tab actual, hacer pop hasta la root de la tab (estandar app)
    final isSameTab = index == navigationShell.currentIndex;
    navigationShell.goBranch(index, initialLocation: isSameTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTabSelected,
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.activeIcon, color: AppColors.primary),
                label: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
