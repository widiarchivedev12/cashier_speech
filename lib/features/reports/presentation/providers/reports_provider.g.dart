// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(summaryRepository)
final summaryRepositoryProvider = SummaryRepositoryProvider._();

final class SummaryRepositoryProvider extends $FunctionalProvider<
    SummaryRepository,
    SummaryRepository,
    SummaryRepository> with $Provider<SummaryRepository> {
  SummaryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'summaryRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$summaryRepositoryHash();

  @$internal
  @override
  $ProviderElement<SummaryRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SummaryRepository create(Ref ref) {
    return summaryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SummaryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SummaryRepository>(value),
    );
  }
}

String _$summaryRepositoryHash() => r'd8650ec36438c92e16e27f193013d5f8c4c31796';

@ProviderFor(dailyReport)
final dailyReportProvider = DailyReportFamily._();

final class DailyReportProvider extends $FunctionalProvider<
        AsyncValue<DailyReport>, DailyReport, FutureOr<DailyReport>>
    with $FutureModifier<DailyReport>, $FutureProvider<DailyReport> {
  DailyReportProvider._(
      {required DailyReportFamily super.from, required DateTime super.argument})
      : super(
          retry: null,
          name: r'dailyReportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dailyReportHash();

  @override
  String toString() {
    return r'dailyReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DailyReport> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DailyReport> create(Ref ref) {
    final argument = this.argument as DateTime;
    return dailyReport(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DailyReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailyReportHash() => r'53b40d4c1390e701debebb2c78c6c296c034f10d';

final class DailyReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DailyReport>, DateTime> {
  DailyReportFamily._()
      : super(
          retry: null,
          name: r'dailyReportProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  DailyReportProvider call(
    DateTime dateWib,
  ) =>
      DailyReportProvider._(argument: dateWib, from: this);

  @override
  String toString() => r'dailyReportProvider';
}
