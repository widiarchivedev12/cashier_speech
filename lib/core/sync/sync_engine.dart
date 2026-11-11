import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'sync_remote.dart';

class SyncEngine {
  SyncEngine(this._db, this._remote);

  final AppDatabase _db;
  final SyncRemote _remote;

  Future<void> sync({required String storeId}) async {
    await _push();
    await _pullProducts(storeId);
    await _pullTransactions(storeId);
  }

  Future<void> _push() async {
    final pending = await _db.syncOutboxDao.getPending();
    for (final entry in pending) {
      try {
        final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
        switch (entry.entity) {
          case 'products':
            await _remote.pushProduct(payload);
          case 'transactions':
            await _remote.pushTransaction(payload);
          case 'parse_logs':
            await _remote.pushParseLog(payload);
        }
        await _db.syncOutboxDao.deleteById(entry.id);
      } catch (e) {
        await _db.syncOutboxDao.recordFailure(entry.id, e.toString());
      }
    }
  }

  Future<void> _pullProducts(String storeId) async {
    final cursor = await _db.syncStateDao.getCursor('products');
    final since = cursor ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    final rows = await _remote.pullProducts(storeId, since);

    DateTime? latestCursor;
    for (final m in rows) {
      final companion = ProductsCompanion(
        id: Value(m['id'] as String),
        storeId: Value(m['store_id'] as String),
        name: Value(m['name'] as String),
        price: Value(m['price'] as int),
        aliases: Value((m['aliases'] as List<dynamic>).cast<String>()),
        isActive: Value(m['is_active'] as bool),
        createdAt: Value(_parseUtc(m['created_at'] as String)),
        updatedAt: Value(_parseUtc(m['updated_at'] as String)),
        serverUpdatedAt: Value(_parseUtc(m['server_updated_at'] as String)),
        deletedAt: m['deleted_at'] != null
            ? Value(_parseUtc(m['deleted_at'] as String))
            : const Value(null),
      );
      await _db.productDao.upsertFromSync(companion);
      latestCursor = _parseUtc(m['server_updated_at'] as String);
    }
    if (latestCursor != null) {
      await _db.syncStateDao.setCursor('products', latestCursor);
    }
  }

  Future<void> _pullTransactions(String storeId) async {
    final cursor = await _db.syncStateDao.getCursor('transactions');
    final since = cursor ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    final rows = await _remote.pullTransactions(storeId, since);

    DateTime? latestCursor;
    for (final m in rows) {
      final txn = TransactionsCompanion(
        id: Value(m['id'] as String),
        storeId: Value(m['store_id'] as String),
        deviceId: Value(m['device_id'] as String),
        receiptNo: Value(m['receipt_no'] as String),
        total: Value(m['total'] as int),
        paid: Value(m['paid'] as int),
        change: Value(m['change'] as int),
        source: Value(m['source'] as String),
        rawTranscript: Value(m['raw_transcript'] as String?),
        createdAt: Value(_parseUtc(m['created_at'] as String)),
        updatedAt: Value(_parseUtc(m['updated_at'] as String)),
        serverUpdatedAt: Value(_parseUtc(m['server_updated_at'] as String)),
        deletedAt: m['deleted_at'] != null
            ? Value(_parseUtc(m['deleted_at'] as String))
            : const Value(null),
      );

      final items = (m['transaction_items'] as List<dynamic>).map((e) {
        final i = e as Map<String, dynamic>;
        return TransactionItemsCompanion(
          id: Value(i['id'] as String),
          transactionId: Value(i['transaction_id'] as String),
          productId: Value(i['product_id'] as String?),
          productName: Value(i['product_name'] as String),
          unitPrice: Value(i['unit_price'] as int),
          qty: Value(i['qty'] as int),
          lineTotal: Value(i['line_total'] as int),
        );
      }).toList();

      await _db.transactionDao.upsertTxnFromSync(txn, items);
      latestCursor = _parseUtc(m['server_updated_at'] as String);
    }
    if (latestCursor != null) {
      await _db.syncStateDao.setCursor('transactions', latestCursor);
    }
  }

  static DateTime _parseUtc(String s) => DateTime.parse(s).toUtc();
}
