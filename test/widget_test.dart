import 'package:cashier_speech/features/catalog/domain/product.dart';
import 'package:cashier_speech/features/catalog/presentation/providers/product_providers.dart';
import 'package:cashier_speech/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProductsProvider.overrideWith(
            (_) => Stream<List<Product>>.value([]),
          ),
        ],
        child: const KasirSuaraApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Kasir Suara'), findsAny);
  });
}
