import 'package:controlix/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows connection screen when no configuration is stored', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(ControlixApp(sharedPreferences: sharedPreferences));
    await tester.pumpAndSettle();

    expect(find.text('Connecter le mobile\nau poste Windows'), findsOneWidget);
    expect(find.text('Sauvegarder et tester'), findsOneWidget);
  });
}
