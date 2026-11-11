// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionRepository)
final transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider extends $FunctionalProvider<
    TransactionRepository,
    TransactionRepository,
    TransactionRepository> with $Provider<TransactionRepository> {
  TransactionRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'3aa8ec799ae327e93274d19afe4e5b474c10cee7';

@ProviderFor(CartNotifier)
final cartProvider = CartNotifierProvider._();

final class CartNotifierProvider extends $NotifierProvider<CartNotifier, Cart> {
  CartNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cartProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cartNotifierHash();

  @$internal
  @override
  CartNotifier create() => CartNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Cart value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Cart>(value),
    );
  }
}

String _$cartNotifierHash() => r'fa1dc93c95307772f20f5b128a635189ced64437';

abstract class _$CartNotifier extends $Notifier<Cart> {
  Cart build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Cart, Cart>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Cart, Cart>, Cart, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
