import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_leon_de_juda/core/router/app_router.dart';

/// Provider del GoRouter global. Construido una sola vez en arranque.
/// La UI lo consume con `ref.watch(routerProvider)` para pasarlo a MaterialApp.router.
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.buildRouter();
});
