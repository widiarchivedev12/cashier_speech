import 'package:cashier_speech/features/cashier/domain/cart.dart';
import 'package:cashier_speech/features/cashier/domain/cart_item.dart';
import 'package:cashier_speech/features/cashier/presentation/cashier_page.dart';
import 'package:cashier_speech/features/cashier/presentation/providers/cart_provider.dart';
import 'package:cashier_speech/features/catalog/domain/product.dart';
import 'package:cashier_speech/features/catalog/presentation/providers/product_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product({
  String id = 'p1',
  String name = 'Brownies',
  int price = 10000,
}) {
  final now = DateTime(2026, 11, 11, 10).toUtc();
  return Product(
    id: id,
    storeId: 'store1',
    name: name,
    price: price,
    createdAt: now,
    updatedAt: now,
    serverUpdatedAt: now,
  );
}

void main() {
  group('CashierPage widget', () {
    testWidgets('shows product grid when catalog has products', (tester) async {
      final products = [_product(), _product(id: 'p2', name: 'Cookies')];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeProductsProvider.overrideWith((_) => Stream.value(products)),
          ],
          child: const MaterialApp(home: CashierPage()),
        ),
      );
      await tester.pump();

      expect(find.text('Brownies'), findsOneWidget);
      expect(find.text('Cookies'), findsOneWidget);
    });

    testWidgets('shows empty state when no products', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeProductsProvider.overrideWith((_) => Stream.value([])),
          ],
          child: const MaterialApp(home: CashierPage()),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Belum ada produk aktif'), findsOneWidget);
    });

    testWidgets('tapping product card adds it to cart', (tester) async {
      final products = [_product()];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeProductsProvider.overrideWith((_) => Stream.value(products)),
          ],
          child: const MaterialApp(home: CashierPage()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Brownies'));
      await tester.pump();

      expect(find.textContaining('10.000'), findsWidgets);
    });

    testWidgets('save button is disabled when cart is empty', (tester) async {
      final products = [_product()];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeProductsProvider.overrideWith((_) => Stream.value(products)),
          ],
          child: const MaterialApp(home: CashierPage()),
        ),
      );
      await tester.pump();

      final saveBtn = find.byKey(const Key('btn_save_transaction'));
      expect(tester.widget<FilledButton>(saveBtn).onPressed, isNull);
    });

    testWidgets('clearCart button appears when cart has items', (tester) async {
      final products = [_product()];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeProductsProvider.overrideWith((_) => Stream.value(products)),
            cartProvider.overrideWith(_FilledCartNotifier.new),
          ],
          child: const MaterialApp(home: CashierPage()),
        ),
      );
      await tester.pump();

      expect(find.text('Bersihkan'), findsOneWidget);
    });
  });
}

// Pre-filled cart for widget tests that need a non-empty state.
class _FilledCartNotifier extends CartNotifier {
  @override
  Cart build() => Cart(
        items: [
          CartItem(
            id: 'ci1',
            productId: 'p1',
            productName: 'Brownies',
            unitPrice: 10000,
            qty: 1,
          ),
        ],
      );
}
