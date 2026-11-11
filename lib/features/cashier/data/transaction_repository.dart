import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/cart.dart';
import '../domain/cart_item.dart';

export '../domain/cart.dart';
export '../domain/cart_item.dart';

// Keeps WIB (UTC+7) offset; Indonesia has no DST.
DateTime _wib() => DateTime.now().toUtc().add(const Duration(hours: 7));

class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<TransactionRow>> watchRecent(String storeId) =>
      _db.transactionDao.watchRecent(storeId);

  Future<List<TransactionItemRow>> getItemsFor(String transactionId) =>
      _db.transactionDao.getItemsFor(transactionId);

  Future<String> save({
    required Cart cart,
    required String storeId,
    required String deviceId,
    String source = 'manual',
  }) async {
    final now = DateTime.now().toUtc();
    final wibNow = _wib();
    final datePrefix = DateFormat('yyMMdd').format(wibNow);
    final receiptNo =
        await _db.transactionDao.nextReceiptNo(deviceId, datePrefix);

    final txnId = _uuid.v4();
    final total = cart.total;
    final paid = cart.paid ?? total;
    final change = paid - total;

    final txnCompanion = TransactionsCompanion.insert(
      id: txnId,
      storeId: storeId,
      deviceId: deviceId,
      receiptNo: receiptNo,
      total: total,
      paid: paid,
      change: change,
      source: source,
      rawTranscript: Value(cart.rawTranscript),
      createdAt: now,
      updatedAt: now,
      serverUpdatedAt: now,
      deletedAt: const Value(null),
    );

    final itemCompanions = cart.items.map((item) {
      return TransactionItemsCompanion.insert(
        id: _uuid.v4(),
        transactionId: txnId,
        productId: Value(item.productId),
        productName: item.productName,
        unitPrice: item.unitPrice,
        qty: item.qty,
        lineTotal: item.lineTotal,
      );
    }).toList();

    final outbox = SyncOutboxCompanion.insert(
      id: _uuid.v4(),
      entity: 'transactions',
      recordId: txnId,
      op: 'upsert',
      payload: jsonEncode(_buildTxnPayload(
        txnId: txnId,
        storeId: storeId,
        deviceId: deviceId,
        receiptNo: receiptNo,
        total: total,
        paid: paid,
        change: change,
        source: source,
        rawTranscript: cart.rawTranscript,
        createdAt: now,
        updatedAt: now,
        items: cart.items,
      )),
      createdAt: now,
    );

    await _db.transactionDao
        .saveWithOutbox(txnCompanion, itemCompanions, outbox);
    return txnId;
  }

  static Map<String, dynamic> _buildTxnPayload({
    required String txnId,
    required String storeId,
    required String deviceId,
    required String receiptNo,
    required int total,
    required int paid,
    required int change,
    required String source,
    required String? rawTranscript,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<CartItem> items,
  }) =>
      {
        'transaction': {
          'id': txnId,
          'store_id': storeId,
          'device_id': deviceId,
          'receipt_no': receiptNo,
          'total': total,
          'paid': paid,
          'change': change,
          'source': source,
          'raw_transcript': rawTranscript,
          'created_at': createdAt.toIso8601String(),
          'updated_at': updatedAt.toIso8601String(),
          'deleted_at': null,
        },
        'items': items
            .map((i) => {
                  'id': const Uuid().v4(),
                  'product_id': i.productId,
                  'product_name': i.productName,
                  'unit_price': i.unitPrice,
                  'qty': i.qty,
                  'line_total': i.lineTotal,
                })
            .toList(),
      };
}
