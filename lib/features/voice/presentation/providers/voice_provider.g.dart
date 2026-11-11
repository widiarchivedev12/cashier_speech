// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(parseLogRepository)
final parseLogRepositoryProvider = ParseLogRepositoryProvider._();

final class ParseLogRepositoryProvider extends $FunctionalProvider<
    ParseLogRepository,
    ParseLogRepository,
    ParseLogRepository> with $Provider<ParseLogRepository> {
  ParseLogRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'parseLogRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$parseLogRepositoryHash();

  @$internal
  @override
  $ProviderElement<ParseLogRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ParseLogRepository create(Ref ref) {
    return parseLogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParseLogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParseLogRepository>(value),
    );
  }
}

String _$parseLogRepositoryHash() =>
    r'f8d775dfe89a97f3af828532d6f3b9f1f2472e23';

@ProviderFor(VoiceNotifier)
final voiceProvider = VoiceNotifierProvider._();

final class VoiceNotifierProvider
    extends $NotifierProvider<VoiceNotifier, VoiceState> {
  VoiceNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'voiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$voiceNotifierHash();

  @$internal
  @override
  VoiceNotifier create() => VoiceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoiceState>(value),
    );
  }
}

String _$voiceNotifierHash() => r'29f4848209c681cb403f9d54d4d94dd1f2c4c266';

abstract class _$VoiceNotifier extends $Notifier<VoiceState> {
  VoiceState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VoiceState, VoiceState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<VoiceState, VoiceState>, VoiceState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
