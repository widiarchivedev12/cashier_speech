import 'package:cashier_speech/core/database/app_database.dart';
import 'package:cashier_speech/features/reports/data/summary_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

const _storeId = 'store-1';
const _deviceId = 'dev-1';
const _uuid = Uuid();

Future<void> _insertTxn(
  AppDatabase db, {
  required DateTime createdAtUtc,
  required int total,
  String source = 'manual',
  List<({String name, int qty, int lineTotal})> items = const [],
}) async {
  final txnId = _uuid.v4();
  await db.into(db.transactions).insert(TransactionsCompanion.insert(
        id: txnId,
        storeId: _storeId,
        deviceId: _deviceId,
        receiptNo: 'TEST-001',
        total: total,
        paid: total,
        change: 0,
        source: source,
        createdAt: createdAtUtc,
        updatedAt: createdAtUtc,
        serverUpdatedAt: createdAtUtc,
      ));
  for (final item in items) {
    await db.into(db.transactionItems).insert(TransactionItemsCompanion.insert(
          id: _uuid.v4(),
          transactionId: txnId,
          productName: item.name,
          unitPrice: item.lineTotal ~/ item.qty,
          qty: item.qty,
          lineTotal: item.lineTotal,
        ));
  }
}

void main() {
  late AppDatabase db;
  late SummaryRepository repo;

  setUp(() {
    db = _makeDb();
    repo = SummaryRepository(db);
  });

  tearDown(() => db.close());

  // WIB date to test against; 12:00 WIB = 05:00 UTC
  final dateWib = DateTime(2025, 6, 15);
  final noon05UTC = DateTime.utc(2025, 6, 15, 5);  // 12:00 WIB
  final midnight05UTC = DateTime.utc(2025, 6, 14, 17); // 00:00 WIB
  final nextDayUTC = DateTime.utc(2025, 6, 15, 17); // 00:00 WIB next day (outside range)

  group('SummaryRepository.getDailyReport', () {
    test('returns empty report when no transactions', () async {
      final report = await repo.getDailyReport(_storeId, dateWib);
      expect(report.transactionCount, 0);
      expect(report.totalRevenue, 0);
      expect(report.topProducts, isEmpty);
    });

    test('counts transactions within WIB date range', () async {
      await _insertTxn(db, createdAtUtc: noon05UTC, total: 50000);
      await _insertTxn(db, createdAtUtc: midnight05UTC, total: 30000);
      // Outside range — next WIB day
      await _insertTxn(db, createdAtUtc: nextDayUTC, total: 20000);

      final report = await repo.getDailyReport(_storeId, dateWib);
      expect(report.transactionCount, 2);
      expect(report.totalRevenue, 80000);
    });

    test('calculates averageRevenue correctly', () async {
      await _insertTxn(db, createdAtUtc: noon05UTC, total: 30000);
      await _insertTxn(db, createdAtUtc: noon05UTC, total: 50000);

      final report = await repo.getDailyReport(_storeId, dateWib);
      expect(report.averageRevenue, 40000);
    });

    test('counts voice and mixed as voiceCount', () async {
      await _insertTxn(db, createdAtUtc: noon05UTC, total: 10000, source: 'voice');
      await _insertTxn(db, createdAtUtc: noon05UTC, total: 10000, source: 'mixed');
      await _insertTxn(db, createdAtUtc: noon05UTC, total: 10000, source: 'manual');

      final report = await repo.getDailyReport(_storeId, dateWib);
      expect(report.voiceCount, 2);
      expect(report.manualCount, 1);
    });

    test('aggregates top products by revenue, max 5', () async {
      for (var i = 1; i <= 6; i++) {
        await _insertTxn(
          db,
          createdAtUtc: noon05UTC,
          total: i * 10000,
          items: [
            (name: 'Produk $i', qty: i, lineTotal: i * 10000),
          ],
        );
      }

      final report = await repo.getDailyReport(_storeId, dateWib);
      expect(report.topProducts.length, 5);
      // Top product should be the highest revenue (Produk 6 = 60000)
      expect(report.topProducts.first.productName, 'Produk 6');
      expect(report.topProducts.first.totalRevenue, 60000);
    });

    test('excludes soft-deleted transactions', () async {
      final txnId = _uuid.v4();
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
            id: txnId,
            storeId: _storeId,
            deviceId: _deviceId,
            receiptNo: 'TEST-DEL',
            total: 50000,
            paid: 50000,
            change: 0,
            source: 'manual',
            createdAt: noon05UTC,
            updatedAt: noon05UTC,
            serverUpdatedAt: noon05UTC,
            deletedAt: Value(noon05UTC),
          ));

      final report = await repo.getDailyReport(_storeId, dateWib);
      expect(report.transactionCount, 0);
    });
  });
}
