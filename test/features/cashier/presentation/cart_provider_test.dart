import 'package:cashier_speech/features/cashier/domain/cart.dart';
import 'package:cashier_speech/features/cashier/domain/cart_item.dart';
import 'package:cashier_speech/features/cashier/presentation/providers/cart_provider.dart';
import 'package:cashier_speech/features/catalog/domain/product.dart';
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
  group('CartNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    Cart readCart() => container.read(cartProvider);
    CartNotifier notifier() => container.read(cartProvider.notifier);

    test('initial state is empty cart', () {
      expect(readCart().items, isEmpty);
      expect(readCart().paid, isNull);
    });

    test('addProduct creates new CartItem', () {
      notifier().addProduct(_product());

      expect(readCart().items, hasLength(1));
      expect(readCart().items.first.productName, 'Brownies');
      expect(readCart().items.first.qty, 1);
    });

    test('addProduct increments qty for same product', () {
      notifier().addProduct(_product());
      notifier().addProduct(_product());

      expect(readCart().items, hasLength(1));
      expect(readCart().items.first.qty, 2);
    });

    test('addProduct keeps separate items for different products', () {
      notifier().addProduct(_product(id: 'p1'));
      notifier().addProduct(_product(id: 'p2', name: 'Cookies', price: 5000));

      expect(readCart().items, hasLength(2));
    });

    test('removeItem removes the item', () {
      notifier().addProduct(_product());
      final itemId = readCart().items.first.id;

      notifier().removeItem(itemId);

      expect(readCart().items, isEmpty);
    });

    test('updateQty changes quantity', () {
      notifier().addProduct(_product());
      final itemId = readCart().items.first.id;

      notifier().updateQty(itemId, 5);

      expect(readCart().items.first.qty, 5);
    });

    test('updateQty with 0 removes item', () {
      notifier().addProduct(_product());
      final itemId = readCart().items.first.id;

      notifier().updateQty(itemId, 0);

      expect(readCart().items, isEmpty);
    });

    test('setPayment stores paid amount', () {
      notifier().setPayment(50000);

      expect(readCart().paid, 50000);
    });

    test('clearCart resets to empty state', () {
      notifier().addProduct(_product());
      notifier().setPayment(20000);

      notifier().clearCart();

      expect(readCart().items, isEmpty);
      expect(readCart().paid, isNull);
    });

    test('CartX.total sums line totals', () {
      notifier().addProduct(_product(price: 10000));
      notifier().addProduct(_product(id: 'p2', name: 'Cookies', price: 5000));
      notifier().updateQty(
        readCart().items.last.id,
        3,
      );

      // 1×10000 + 3×5000 = 25000
      expect(readCart().total, 25000);
    });

    test('CartX.change is paid minus total', () {
      notifier().addProduct(_product(price: 10000));
      notifier().setPayment(50000);

      expect(readCart().change, 40000);
    });

    test('CartX.canSave is true only when paid >= total and items not empty',
        () {
      expect(readCart().canSave, isFalse);

      notifier().addProduct(_product(price: 10000));
      expect(readCart().canSave, isFalse); // no paid yet

      notifier().setPayment(5000);
      expect(readCart().canSave, isFalse); // paid < total

      notifier().setPayment(10000);
      expect(readCart().canSave, isTrue);
    });

    test('CartItemX.lineTotal uses lineTotalOverride when set', () {
      final item = CartItem(
        id: 'i1',
        productId: 'p1',
        productName: 'Test',
        unitPrice: 10000,
        qty: 2,
        lineTotalOverride: 15000,
      );
      expect(item.lineTotal, 15000);
    });

    test('CartItemX.lineTotal uses unitPrice×qty when no override', () {
      final item = CartItem(
        id: 'i1',
        productId: 'p1',
        productName: 'Test',
        unitPrice: 10000,
        qty: 3,
      );
      expect(item.lineTotal, 30000);
    });
  });
}
