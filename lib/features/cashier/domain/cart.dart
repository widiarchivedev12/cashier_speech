import 'package:freezed_annotation/freezed_annotation.dart';

import 'cart_item.dart';

part 'cart.freezed.dart';

@freezed
sealed class Cart with _$Cart {
  const factory Cart({
    @Default([]) List<CartItem> items,
    int? paid,
    String? rawTranscript,
  }) = _Cart;
}

extension CartX on Cart {
  int get total => items.fold(0, (sum, item) => sum + item.lineTotal);
  int get change => (paid != null && paid! >= total) ? paid! - total : 0;
  bool get canSave => items.isNotEmpty && paid != null && paid! >= total;
}
