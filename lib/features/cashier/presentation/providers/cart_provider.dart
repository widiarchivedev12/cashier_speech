import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:voice_parser/voice_parser.dart';

import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/transaction_repository.dart';
import '../../../catalog/domain/product.dart';

part 'cart_provider.g.dart';

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) =>
    TransactionRepository(ref.watch(appDatabaseProvider));

@riverpod
class CartNotifier extends _$CartNotifier {
  static const _uuid = Uuid();

  @override
  Cart build() => const Cart();

  void addProduct(Product product) {
    final existing = state.items.indexWhere(
      (i) => i.productId == product.id,
    );
    if (existing >= 0) {
      final updated = state.items[existing];
      _updateItems(state.items.toList()
        ..[existing] = updated.copyWith(qty: updated.qty + 1));
    } else {
      _updateItems([
        ...state.items,
        CartItem(
          id: _uuid.v4(),
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
          qty: 1,
        ),
      ]);
    }
  }

  void removeItem(String itemId) {
    _updateItems(state.items.where((i) => i.id != itemId).toList());
  }

  void updateQty(String itemId, int qty) {
    if (qty <= 0) {
      removeItem(itemId);
      return;
    }
    final idx = state.items.indexWhere((i) => i.id == itemId);
    if (idx < 0) return;
    final updated = state.items.toList()
      ..[idx] = state.items[idx].copyWith(qty: qty);
    _updateItems(updated);
  }

  void setPayment(int? amount) {
    state = state.copyWith(paid: amount);
  }

  void setRawTranscript(String transcript) {
    state = state.copyWith(rawTranscript: transcript);
  }

  void applyParseResult(
    ParseResult result,
    List<CatalogEntry> catalog,
    String transcript,
  ) {
    final catalogMap = {for (final e in catalog) e.productId: e};
    var items = state.items.toList();
    int? newPaid = state.paid;

    for (final cmd in result.commands) {
      switch (cmd) {
        case AddItem():
          final entry = catalogMap[cmd.productId];
          if (entry == null) continue;
          final idx = items.indexWhere((i) => i.productId == cmd.productId);
          if (idx >= 0) {
            items[idx] = items[idx].copyWith(
              qty: items[idx].qty + cmd.qty,
              confidence: cmd.confidence,
              sourceText: cmd.sourceText,
              lineTotalOverride: cmd.lineTotalOverride,
            );
          } else {
            items.add(CartItem(
              id: _uuid.v4(),
              productId: cmd.productId,
              productName: entry.name,
              unitPrice: entry.price,
              qty: cmd.qty,
              lineTotalOverride: cmd.lineTotalOverride,
              confidence: cmd.confidence,
              sourceText: cmd.sourceText,
            ));
          }
        case RemoveItem():
          items.removeWhere((i) => i.productId == cmd.productId);
        case RemoveLast():
          if (items.isNotEmpty) items.removeLast();
        case ClearCart():
          items = [];
        case SetPayment():
          newPaid = cmd.amount;
        case Unknown():
          break;
      }
    }

    state = state.copyWith(
      items: items,
      paid: newPaid,
      rawTranscript: transcript,
    );
  }

  void clearCart() {
    state = const Cart();
  }

  Future<String> confirmTransaction({String source = 'manual'}) async {
    final repo = ref.read(transactionRepositoryProvider);
    final store = ref.read(storeIdProvider);
    final device = ref.read(deviceIdProvider);

    final txnId = await repo.save(
      cart: state,
      storeId: store,
      deviceId: device,
      source: source,
    );

    state = const Cart();
    return txnId;
  }

  void _updateItems(List<CartItem> items) {
    state = state.copyWith(items: items);
  }
}
