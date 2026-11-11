// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeId)
final storeIdProvider = StoreIdProvider._();

final class StoreIdProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  StoreIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'storeIdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$storeIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return storeId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$storeIdHash() => r'd9858bc194e3efd1a26b4e9a60f8d2c82689df8c';

@ProviderFor(deviceId)
final deviceIdProvider = DeviceIdProvider._();

final class DeviceIdProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  DeviceIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deviceIdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deviceIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return deviceId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$deviceIdHash() => r'4df4c9548442074f0ca4b85e4c0e4e07a074fae8';
