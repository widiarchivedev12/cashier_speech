// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppStateNotifier)
final appStateProvider = AppStateNotifierProvider._();

final class AppStateNotifierProvider
    extends $AsyncNotifierProvider<AppStateNotifier, AppState> {
  AppStateNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appStateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appStateNotifierHash();

  @$internal
  @override
  AppStateNotifier create() => AppStateNotifier();
}

String _$appStateNotifierHash() => r'2b28479c5b7f87bd9409de3ce911a846831af6ba';

abstract class _$AppStateNotifier extends $AsyncNotifier<AppState> {
  FutureOr<AppState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppState>, AppState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AppState>, AppState>,
        AsyncValue<AppState>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

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

String _$storeIdHash() => r'b21aa0b67338e543cbabe3963c2b6faaf5ccb886';

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

String _$deviceIdHash() => r'49372f94b35b2c78288204b0f81c424276f1171a';
