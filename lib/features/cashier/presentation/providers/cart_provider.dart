import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

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
