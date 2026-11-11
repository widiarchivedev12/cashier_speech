import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/summary_repository.dart';
import '../../domain/daily_report.dart';

part 'reports_provider.g.dart';

@Riverpod(keepAlive: false)
SummaryRepository summaryRepository(Ref ref) =>
    SummaryRepository(ref.watch(appDatabaseProvider));

@riverpod
Future<DailyReport> dailyReport(Ref ref, DateTime dateWib) async {
  final storeId = ref.watch(storeIdProvider);
  return ref.watch(summaryRepositoryProvider).getDailyReport(storeId, dateWib);
}
