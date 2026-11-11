import 'package:cashier_speech/core/database/app_database.dart';
import 'package:cashier_speech/core/sync/sync_engine.dart';
import 'package:cashier_speech/core/sync/sync_remote.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

class _FakeSyncRemote implements SyncRemote {
  bool shouldFail = false;
  final List<String> pushedEntities = [];
  List<Map<String, dynamic>> productsToPull = [];
  List<Map<String, dynamic>> transactionsToPull = [];

  @override
  Future<void> pushProduct(Map<String, dynamic> payload) async {
    pushedEntities.add('products');
    if (shouldFail) throw Exception('network error');
  }

  @override
  Future<void> pushTransaction(Map<String, dynamic> payload) async {
    pushedEntities.add('transactions');
    if (shouldFail) throw Exception('network error');
  }

  @override
  Future<void> pushParseLog(Map<String, dynamic> payload) async {
    pushedEntities.add('parse_logs');
    if (shouldFail) throw Exception('network error');
  }

  @override
  Future<List<Map<String, dynamic>>> pullProducts(
          String storeId, DateTime since) async =>
      productsToPull;

  @override
  Future<List<Map<String, dynamic>>> pullTransactions(
          String storeId, DateTime since) async =>
      transactionsToPull;
}

void main() {
  late AppDatabase db;
  late _FakeSyncRemote remote;
  late SyncEngine engine;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remote = _FakeSyncRemote();
    engine = SyncEngine(db, remote);
  });

  tearDown(() => db.close());

  group('push', () {
    test('empty outbox does nothing', () async {
      await engine.sync(storeId: 'store1');
      expect(remote.pushedEntities, isEmpty);
    });

    test('pushes product and removes outbox entry on success', () async {
      await db.syncOutboxDao.getPending(); // ensure table exists
      final outboxId = uuid.v4();
      await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
            id: outboxId,
            entity: 'products',
            recordId: 'p1',
            op: 'upsert',
            payload: '{"id":"p1","store_id":"store1"}',
            createdAt: DateTime.now().toUtc(),
          ));

      await engine.sync(storeId: 'store1');

      expect(remote.pushedEntities, ['products']);
      final pending = await db.syncOutboxDao.getPending();
      expect(pending, isEmpty);
    });

    test('records failure when push throws', () async {
      remote.shouldFail = true;
      final outboxId = uuid.v4();
      await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
            id: outboxId,
            entity: 'products',
            recordId: 'p1',
            op: 'upsert',
            payload: '{"id":"p1"}',
            createdAt: DateTime.now().toUtc(),
          ));

      await engine.sync(storeId: 'store1');

      final pending = await db.syncOutboxDao.getPending();
      expect(pending.length, 1);
      expect(pending.first.attempts, 1);
      expect(pending.first.lastError, contains('network error'));
    });

    test('item with 5+ attempts is not retried', () async {
      final outboxId = uuid.v4();
      await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
            id: outboxId,
            entity: 'products',
            recordId: 'p1',
            op: 'upsert',
            payload: '{"id":"p1"}',
            createdAt: DateTime.now().toUtc(),
          ));
      // Simulate 5 previous failures
      for (var i = 0; i < 5; i++) {
        await db.syncOutboxDao.recordFailure(outboxId, 'error');
      }

      await engine.sync(storeId: 'store1');

      expect(remote.pushedEntities, isEmpty);
    });
  });

  group('pull products', () {
    final serverTs = '2024-06-01T00:00:00.000Z';

    setUp(() {
      remote.productsToPull = [
        {
          'id': 'p1',
          'store_id': 'store1',
          'name': 'Brownies',
          'price': 15000,
          'aliases': ['browni'],
          'is_active': true,
          'created_at': serverTs,
          'updated_at': serverTs,
          'server_updated_at': serverTs,
          'deleted_at': null,
        },
      ];
    });

    test('writes pulled product to local DB', () async {
      await engine.sync(storeId: 'store1');

      final products = await db.productDao.getAll('store1');
      expect(products.length, 1);
      expect(products.first.name, 'Brownies');
      expect(products.first.price, 15000);
    });

    test('updates sync cursor after pull', () async {
      await engine.sync(storeId: 'store1');

      final cursor = await db.syncStateDao.getCursor('products');
      expect(cursor, isNotNull);
      expect(cursor!.toUtc(), DateTime.parse(serverTs).toUtc());
    });

    test('does not update cursor when no rows pulled', () async {
      remote.productsToPull = [];
      await engine.sync(storeId: 'store1');

      final cursor = await db.syncStateDao.getCursor('products');
      expect(cursor, isNull);
    });
  });

  group('pull transactions', () {
    final serverTs = '2024-06-01T00:00:00.000Z';

    setUp(() {
      remote.transactionsToPull = [
        {
          'id': 'txn1',
          'store_id': 'store1',
          'device_id': 'device1',
          'receipt_no': '240601-001',
          'total': 15000,
          'paid': 20000,
          'change': 5000,
          'source': 'manual',
          'raw_transcript': null,
          'created_at': serverTs,
          'updated_at': serverTs,
          'server_updated_at': serverTs,
          'deleted_at': null,
          'transaction_items': [
            {
              'id': 'item1',
              'transaction_id': 'txn1',
              'product_id': null,
              'product_name': 'Brownies',
              'unit_price': 15000,
              'qty': 1,
              'line_total': 15000,
            },
          ],
        },
      ];
    });

    test('writes pulled transaction and items to local DB', () async {
      await engine.sync(storeId: 'store1');

      final txns = await db.transactionDao.watchRecent('store1').first;
      expect(txns.length, 1);
      expect(txns.first.id, 'txn1');
      expect(txns.first.total, 15000);

      final items = await db.transactionDao.getItemsFor('txn1');
      expect(items.length, 1);
      expect(items.first.productName, 'Brownies');
    });
  });
}
