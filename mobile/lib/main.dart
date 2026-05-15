import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:torneo_leon_de_juda/core/router/router_providers.dart';
import 'package:torneo_leon_de_juda/core/storage/cache_storage.dart';
import 'package:torneo_leon_de_juda/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive antes de runApp para que los boxes esten listos al
  // primer frame y los providers puedan leer cache sincronicamente.
  await CacheStorage.init();

  // Carga datos de localizacion para formato de fechas en español (es_CO).
  await initializeDateFormatting('es_CO');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlay);
  runApp(const ProviderScope(child: TorneoLeonDeJudaApp()));
}

class TorneoLeonDeJudaApp extends ConsumerWidget {
  const TorneoLeonDeJudaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Torneo Leon de Juda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
