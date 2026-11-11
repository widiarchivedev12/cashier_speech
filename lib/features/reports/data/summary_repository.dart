import '../../../core/database/app_database.dart';
import '../domain/daily_report.dart';

class SummaryRepository {
  SummaryRepository(this._db);

  final AppDatabase _db;

  Future<DailyReport> getDailyReport(String storeId, DateTime dateWib) async {
    // WIB = UTC+7; convert WIB midnight → UTC
    final startUtc = DateTime(dateWib.year, dateWib.month, dateWib.day)
        .subtract(const Duration(hours: 7));
    final endUtc = startUtc.add(const Duration(days: 1));

    final txns =
        await _db.transactionDao.getForDateRange(storeId, startUtc, endUtc);

    if (txns.isEmpty) {
      return DailyReport(
        date: dateWib,
        totalRevenue: 0,
        transactionCount: 0,
        voiceCount: 0,
        topProducts: [],
      );
    }

    final txnIds = txns.map((t) => t.id).toList();
    final items = await _db.transactionDao.getItemsForTransactions(txnIds);

    final productMap = <String, _Agg>{};
    for (final item in items) {
      final agg = productMap.putIfAbsent(item.productName, _Agg.new);
      agg.qty += item.qty;
      agg.revenue += item.lineTotal;
    }

    final topProducts = productMap.entries
        .map((e) => ProductSummary(
              productName: e.key,
              totalQty: e.value.qty,
              totalRevenue: e.value.revenue,
            ))
        .toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final voiceCount = txns
        .where((t) => t.source == 'voice' || t.source == 'mixed')
        .length;

    return DailyReport(
      date: dateWib,
      totalRevenue: txns.fold(0, (s, t) => s + t.total),
      transactionCount: txns.length,
      voiceCount: voiceCount,
      topProducts: topProducts.take(5).toList(),
    );
  }
}

class _Agg {
  int qty = 0;
  int revenue = 0;
}
