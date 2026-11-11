import 'package:cashier_speech/core/database/app_database.dart';
import 'package:cashier_speech/features/cashier/data/transaction_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

Cart _cart({int paid = 20000}) => Cart(
      items: [
        CartItem(
          id: 'ci1',
          productId: 'p1',
          productName: 'Brownies',
          unitPrice: 10000,
          qty: 2,
        ),
      ],
      paid: paid,
    );

void main() {
  group('TransactionRepository', () {
    late AppDatabase db;
    late TransactionRepository repo;

    setUp(() {
      db = _makeDb();
      repo = TransactionRepository(db);
    });

    tearDown(() => db.close());

    test('save inserts transaction row', () async {
      await repo.save(
        cart: _cart(),
        storeId: 'store1',
        deviceId: 'dev1',
      );

      final rows = await db.select(db.transactions).get();
      expect(rows, hasLength(1));
      expect(rows.first.total, 20000);
      expect(rows.first.paid, 20000);
      expect(rows.first.change, 0);
      expect(rows.first.source, 'manual');
      expect(rows.first.storeId, 'store1');
    });

    test('save inserts transaction_items as snapshots', () async {
      await repo.save(
        cart: _cart(),
        storeId: 'store1',
        deviceId: 'dev1',
      );

      final items = await db.select(db.transactionItems).get();
      expect(items, hasLength(1));
      expect(items.first.productName, 'Brownies');
      expect(items.first.unitPrice, 10000);
      expect(items.first.qty, 2);
      expect(items.first.lineTotal, 20000);
    });

    test('save writes sync_outbox row', () async {
      await repo.save(
        cart: _cart(),
        storeId: 'store1',
        deviceId: 'dev1',
      );

      final outbox = await db.select(db.syncOutbox).get();
      expect(outbox, hasLength(1));
      expect(outbox.first.entity, 'transactions');
      expect(outbox.first.op, 'upsert');
    });

    test('receipt numbers increment per device per day', () async {
      await repo.save(cart: _cart(), storeId: 's', deviceId: 'dev1');
      await repo.save(cart: _cart(), storeId: 's', deviceId: 'dev1');

      final rows = await db.select(db.transactions).get()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final r1 = rows[0].receiptNo;
      final r2 = rows[1].receiptNo;
      expect(r1.endsWith('-001'), isTrue, reason: 'first receipt is -001');
      expect(r2.endsWith('-002'), isTrue, reason: 'second receipt is -002');
    });

    test('save calculates correct change', () async {
      await repo.save(
        cart: _cart(paid: 50000),
        storeId: 'store1',
        deviceId: 'dev1',
      );

      final rows = await db.select(db.transactions).get();
      expect(rows.first.change, 30000);
    });
  });
}
