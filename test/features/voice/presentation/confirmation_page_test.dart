import 'package:cashier_speech/features/cashier/domain/cart.dart';
import 'package:cashier_speech/features/cashier/domain/cart_item.dart';
import 'package:cashier_speech/features/cashier/presentation/providers/cart_provider.dart';
import 'package:cashier_speech/features/catalog/domain/product.dart';
import 'package:cashier_speech/features/catalog/presentation/providers/product_providers.dart';
import 'package:cashier_speech/features/voice/presentation/confirmation_page.dart';
import 'package:cashier_speech/features/voice/presentation/providers/voice_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_parser/voice_parser.dart';

final _now = DateTime(2026, 11, 12, 10).toUtc();

Product _product(
        {String id = 'p1', String name = 'Brownies', int price = 10000}) =>
    Product(
      id: id,
      storeId: 'store1',
      name: name,
      price: price,
      createdAt: _now,
      updatedAt: _now,
      serverUpdatedAt: _now,
    );

Cart _cartWith(List<CartItem> items, {int? paid}) =>
    Cart(items: items, paid: paid);

class _FilledCartNotifier extends CartNotifier {
  _FilledCartNotifier(this._cart);
  final Cart _cart;
  @override
  Cart build() => _cart;
}

class _VoiceNotifierWithResult extends VoiceNotifier {
  _VoiceNotifierWithResult(this._state);
  final VoiceState _state;
  @override
  VoiceState build() => _state;
}

Widget _wrap({
  required Widget child,
  Cart? cart,
  VoiceState? voiceState,
  List<Product>? products,
}) {
  return ProviderScope(
    overrides: [
      activeProductsProvider.overrideWith(
        (_) => Stream.value(products ?? [_product()]),
      ),
      if (cart != null)
        cartProvider.overrideWith(() => _FilledCartNotifier(cart)),
      if (voiceState != null)
        voiceProvider.overrideWith(() => _VoiceNotifierWithResult(voiceState)),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('ConfirmationPage', () {
    testWidgets('shows transcript when available', (tester) async {
      const voice = VoiceState(
        status: VoiceStatus.done,
        transcript: 'brownies dua',
      );

      await tester.pumpWidget(_wrap(
        voiceState: voice,
        child: const ConfirmationPage(),
      ));
      await tester.pump();

      expect(find.textContaining('brownies dua'), findsOneWidget);
    });

    testWidgets('shows cart items with product name', (tester) async {
      final cart = _cartWith([
        CartItem(
          id: 'ci1',
          productId: 'p1',
          productName: 'Brownies',
          unitPrice: 10000,
          qty: 2,
        ),
      ]);

      await tester
          .pumpWidget(_wrap(cart: cart, child: const ConfirmationPage()));
      await tester.pump();

      expect(find.text('Brownies'), findsOneWidget);
    });

    testWidgets('shows unknown item from voice issues', (tester) async {
      const voice = VoiceState(
        status: VoiceStatus.done,
        transcript: 'xyz',
        parseResult: ParseResult(
          issues: [
            ParseIssue(type: IssueType.unknownProduct, sourceText: 'xyz'),
          ],
        ),
      );

      await tester.pumpWidget(_wrap(
        voiceState: voice,
        child: const ConfirmationPage(),
      ));
      await tester.pump();

      expect(find.textContaining('xyz'), findsWidgets);
    });

    testWidgets('save button disabled when no items and no payment',
        (tester) async {
      await tester.pumpWidget(_wrap(child: const ConfirmationPage()));
      await tester.pump();

      final btn = find.byKey(const Key('btn_confirm_save'));
      expect(tester.widget<FilledButton>(btn).onPressed, isNull);
    });

    testWidgets('save button disabled when unknown items pending',
        (tester) async {
      const voice = VoiceState(
        status: VoiceStatus.done,
        transcript: 'xyz',
        parseResult: ParseResult(
          issues: [
            ParseIssue(type: IssueType.unknownProduct, sourceText: 'xyz'),
          ],
        ),
      );
      final cart = _cartWith(
        [
          CartItem(
            id: 'ci1',
            productId: 'p1',
            productName: 'Brownies',
            unitPrice: 10000,
            qty: 1,
          ),
        ],
        paid: 10000,
      );

      await tester.pumpWidget(_wrap(
        cart: cart,
        voiceState: voice,
        child: const ConfirmationPage(),
      ));
      await tester.pump();

      final btn = find.byKey(const Key('btn_confirm_save'));
      expect(tester.widget<FilledButton>(btn).onPressed, isNull);
    });

    testWidgets('dismiss unknown item removes the warning tile',
        (tester) async {
      const voice = VoiceState(
        status: VoiceStatus.done,
        transcript: 'xyz',
        parseResult: ParseResult(
          issues: [
            ParseIssue(type: IssueType.unknownProduct, sourceText: 'xyz'),
          ],
        ),
      );

      await tester.pumpWidget(_wrap(
        voiceState: voice,
        child: const ConfirmationPage(),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.textContaining('Tidak dikenal'), findsNothing);
    });
  });
}
