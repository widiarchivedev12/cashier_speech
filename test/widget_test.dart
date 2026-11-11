import 'package:cashier_speech/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KasirSuaraApp());
    expect(find.text('Kasir Suara'), findsAny);
  });
}
