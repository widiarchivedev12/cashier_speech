import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
sealed class Product with _$Product {
  const factory Product({
    required String id,
    required String storeId,
    required String name,
    required int price,
    @Default([]) List<String> aliases,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime serverUpdatedAt,
    DateTime? deletedAt,
  }) = _Product;
}
