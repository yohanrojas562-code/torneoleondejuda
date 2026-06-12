import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_leon_de_juda/core/router/app_route.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/auth/data/auth_repository.dart';

/// Pantalla de splash con animación al arrancar la app:
///   0.0s — fade-in de un balón de fútbol (rota + escala)
///   1.4s — el balón se desvanece y aparece el logo del torneo (scale-up)
///   2.6s — el logo brilla suave y baja el "TORNEO LEÓN DE JUDÁ"
///   3.4s — navega automáticamente a /home (o /dashboard si hay sesion)
///
/// Si el auth controller aún está restaurando la sesión, esperamos a que
/// termine antes de redirigir para evitar un flash de la pantalla pública.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 3400), _redirect);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _redirect() {
    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    // Si todavía está chequeando el token, espera 400ms más.
    if (auth.isInitializing) {
      _timer = Timer(const Duration(milliseconds: 400), _redirect);
      return;
    }
    if (auth.isAuthenticated) {
      context.goNamed(AppRoute.dashboard.name);
    } else {
      context.goNamed(AppRoute.home.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient sutil de fondo
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.9,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.10),
                    AppColors.bgDeep,
                  ],
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 200,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ─── 1) Balón de fútbol con rotación + escala ─────
                    const _SoccerBall()
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        )
                        .rotate(
                          begin: -0.5,
                          end: 0,
                          duration: 900.ms,
                          curve: Curves.easeOut,
                        )
                        .then(delay: 400.ms)
                        .fadeOut(duration: 350.ms),

                    // ─── 2) Logo del torneo ────────────────────────────
                    const _Logo()
                        .animate(delay: 1400.ms)
                        .fadeIn(duration: 500.ms)
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        )
                        // Pulse sutil
                        .then(delay: 200.ms)
                        .scaleXY(
                          begin: 1,
                          end: 1.05,
                          duration: 400.ms,
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scaleXY(
                          begin: 1.05,
                          end: 1,
                          duration: 400.ms,
                          curve: Curves.easeInOut,
                        ),
                  ],
                ),
              ),
            ),

            // ─── 3) Texto inferior ────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.xl,
              child: Column(
                children: [
                  Text(
                    'TORNEO LEÓN DE JUDÁ',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 3,
                    ),
                  )
                      .animate(delay: 2600.ms)
                      .fadeIn(duration: 500.ms)
                      .moveY(begin: 12, end: 0, duration: 500.ms),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Fe · Comunidad · Disciplina · Excelencia',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ).animate(delay: 2900.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Balón de fútbol — usa el ícono nativo Material para evitar dependencias
/// de assets externos. Color blanco con sombra dorada.
class _SoccerBall extends StatelessWidget {
  const _SoccerBall();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceHigh,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.6),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_soccer_rounded,
        color: Colors.white,
        size: 110,
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: -2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: AppRadius.brMd,
        child: Image.asset(
          'assets/branding/tournament_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(gradient: AppColors.goldGradient),
            alignment: Alignment.center,
            child: Text(
              'LJ',
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.textOnPrimary,
                fontSize: 56,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
