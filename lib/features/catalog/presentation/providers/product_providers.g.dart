// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productRepository)
final productRepositoryProvider = ProductRepositoryProvider._();

final class ProductRepositoryProvider extends $FunctionalProvider<
    ProductRepository,
    ProductRepository,
    ProductRepository> with $Provider<ProductRepository> {
  ProductRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'productRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'60ca8e5ef4e837dbb2b5725d0061c70981e82194';

@ProviderFor(activeProducts)
final activeProductsProvider = ActiveProductsProvider._();

final class ActiveProductsProvider extends $FunctionalProvider<
        AsyncValue<List<Product>>, List<Product>, Stream<List<Product>>>
    with $FutureModifier<List<Product>>, $StreamProvider<List<Product>> {
  ActiveProductsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeProductsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeProductsHash();

  @$internal
  @override
  $StreamProviderElement<List<Product>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Product>> create(Ref ref) {
    return activeProducts(ref);
  }
}

String _$activeProductsHash() => r'e0fd3507b5b9526d3cc1d1cd699e8d8a7920019f';
