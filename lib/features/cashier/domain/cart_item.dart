import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';

@freezed
sealed class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required String productId,
    required String productName,
    required int unitPrice,
    required int qty,
    int? lineTotalOverride,
    double? confidence,
    String? sourceText,
  }) = _CartItem;
}

extension CartItemX on CartItem {
  int get lineTotal => lineTotalOverride ?? (unitPrice * qty);
}
