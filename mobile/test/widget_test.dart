// Smoke test: la app arranca y muestra la pantalla de login.

import 'package:flutter_test/flutter_test.dart';

import 'package:dental_history_app/main.dart';

void main() {
  testWidgets('La app arranca y muestra la pantalla de login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DentalHistoryApp());

    expect(find.text('Dentity'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
