import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_leon_de_juda/core/router/app_route.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/auth/data/auth_repository.dart';
import 'package:torneo_leon_de_juda/features/auth/data/auth_user.dart';

/// Drawer lateral compartido entre todas las pantallas principales.
/// Lista todas las rutas con highlight del item activo segun la ruta
/// actual de go_router.
///
/// Uso: en cualquier Scaffold, `drawer: const AppDrawer()`.
/// Para abrirlo desde un boton: `Scaffold.of(context).openDrawer()` desde
/// un Builder que tenga el Scaffold como ancestor.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  static const _items = <_DrawerItem>[
    _DrawerItem(
      route: AppRoute.home,
      icon: Icons.home_rounded,
      label: 'Inicio',
    ),
    _DrawerItem(
      route: AppRoute.calendar,
      icon: Icons.calendar_today_rounded,
      label: 'Calendario',
    ),
    _DrawerItem(
      route: AppRoute.standings,
      icon: Icons.emoji_events_rounded,
      label: 'Tabla de Posiciones',
    ),
    _DrawerItem(
      route: AppRoute.scorers,
      icon: Icons.sports_soccer_rounded,
      label: 'Goleadores',
    ),
    _DrawerItem(
      route: AppRoute.defense,
      icon: Icons.shield_rounded,
      label: 'Valla menos vencida',
    ),
    _DrawerItem(
      route: AppRoute.verify,
      icon: Icons.qr_code_scanner_rounded,
      label: 'Validar jugador',
    ),
    _DrawerItem(
      route: AppRoute.team,
      icon: Icons.groups_rounded,
      label: 'Equipo organizador',
    ),
    _DrawerItem(
      route: AppRoute.sponsors,
      icon: Icons.favorite_rounded,
      label: 'Patrocinadores',
    ),
    _DrawerItem(
      route: AppRoute.about,
      icon: Icons.info_rounded,
      label: 'Sobre el Torneo',
    ),
    _DrawerItem(
      route: AppRoute.pqrs,
      icon: Icons.chat_bubble_outline_rounded,
      label: 'PQRS',
    ),
  ];

  bool _isActive(String location, AppRoute route) {
    if (route == AppRoute.home) return location == '/';
    return location == route.path || location.startsWith('${route.path}/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final auth = ref.watch(authControllerProvider);

    return Drawer(
      backgroundColor: AppColors.bgDeep,
      width: width * 0.85,
      shape: const RoundedRectangleBorder(),
      child: Column(
        children: [
          _DrawerHeader(user: auth.user),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.xs,
              ),
              children: [
                if (auth.isAuthenticated)
                  _DrawerNavItem(
                    item: const _DrawerItem(
                      route: AppRoute.dashboard,
                      icon: Icons.dashboard_rounded,
                      label: 'Mi Panel',
                    ),
                    isActive:
                        _isActive(currentLocation, AppRoute.dashboard),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.goNamed(AppRoute.dashboard.name);
                    },
                  ),
                for (final item in _items)
                  _DrawerNavItem(
                    item: item,
                    isActive: _isActive(currentLocation, item.route),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.goNamed(item.route.name);
                    },
                  ),
              ],
            ),
          ),
          _DrawerFooter(user: auth.user),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.of(context).padding.top + AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceHigh, AppColors.bgDeep],
        ),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: AppRadius.brMd,
            ),
            alignment: Alignment.center,
            child: Text(
              user?.initials ?? 'LJ',
              style: AppTypography.headerSmall.copyWith(
                color: AppColors.textOnPrimary,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.name ?? 'León de Judá',
                  style: AppTypography.headerSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'Torneo de Fútbol',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  const _DrawerNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _DrawerItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brSm,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: AppRadius.brSm,
              border: isActive
                  ? const Border(
                      left: BorderSide(
                        color: AppColors.primary,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerFooter extends ConsumerWidget {
  const _DrawerFooter({this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = user != null;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: isLoggedIn
          ? OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
              ),
            )
          : FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.goNamed(AppRoute.login.name);
              },
              icon: const Icon(Icons.login_rounded, size: 20),
              label: const Text('Ingresar'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
              ),
            ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) return;
    // El drawer está abierto sobre la pantalla; lo cerramos y vamos a /home.
    Navigator.of(context).pop();
    context.goNamed(AppRoute.home.name);
  }
}

class _DrawerItem {
  const _DrawerItem({
    required this.route,
    required this.icon,
    required this.label,
  });

  final AppRoute route;
  final IconData icon;
  final String label;
}
