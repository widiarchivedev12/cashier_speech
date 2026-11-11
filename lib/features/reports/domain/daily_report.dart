import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_report.freezed.dart';

@freezed
abstract class DailyReport with _$DailyReport {
  const factory DailyReport({
    required DateTime date,
    required int totalRevenue,
    required int transactionCount,
    required int voiceCount,
    required List<ProductSummary> topProducts,
  }) = _DailyReport;

  const DailyReport._();

  int get manualCount => transactionCount - voiceCount;
  int get averageRevenue =>
      transactionCount == 0 ? 0 : totalRevenue ~/ transactionCount;
}

@freezed
abstract class ProductSummary with _$ProductSummary {
  const factory ProductSummary({
    required String productName,
    required int totalQty,
    required int totalRevenue,
  }) = _ProductSummary;
}
