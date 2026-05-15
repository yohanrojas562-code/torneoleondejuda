import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torneo_leon_de_juda/main.dart';

void main() {
  testWidgets('App boots and lands on Home tab', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TorneoLeonDeJudaApp()),
    );
    await tester.pumpAndSettle();

    // El tab Inicio debe estar activo al arranque
    expect(find.text('Inicio'), findsWidgets);
    // Bottom nav presente con los 4 tabs
    expect(find.text('Calendario'), findsWidgets);
    expect(find.text('Posiciones'), findsWidgets);
    expect(find.text('Goleadores'), findsWidgets);
  });
}
