import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_outbox_table.dart';
import '../tables/transaction_items_table.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, TransactionItems, SyncOutbox])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Stream<List<TransactionRow>> watchRecent(String storeId, {int limit = 50}) =>
      (select(transactions)
            ..where(
              (t) => t.storeId.equals(storeId) & t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .watch();

  Future<List<TransactionItemRow>> getItemsFor(String transactionId) =>
      (select(transactionItems)
            ..where((t) => t.transactionId.equals(transactionId)))
          .get();

  Future<String> nextReceiptNo(
    String deviceId,
    String datePrefix,
  ) async {
    final rows = await (select(transactions)
          ..where((t) => t.receiptNo.like('$datePrefix-%')))
        .get();
    final seq = rows.length + 1;
    return '$datePrefix-${seq.toString().padLeft(3, '0')}';
  }

  Future<void> saveWithOutbox(
    TransactionsCompanion txn,
    List<TransactionItemsCompanion> items,
    SyncOutboxCompanion outbox,
  ) =>
      transaction(() async {
        await into(transactions).insert(txn);
        for (final item in items) {
          await into(transactionItems).insert(item);
        }
        await into(syncOutbox).insert(outbox);
      });

  Future<TransactionRow?> getById(String id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<TransactionRow>> getForDateRange(
    String storeId,
    DateTime startUtc,
    DateTime endUtc,
  ) =>
      (select(transactions)
            ..where((t) =>
                t.storeId.equals(storeId) &
                t.deletedAt.isNull() &
                t.createdAt.isBiggerOrEqualValue(startUtc) &
                t.createdAt.isSmallerThanValue(endUtc)))
          .get();

  Future<List<TransactionItemRow>> getItemsForTransactions(
    List<String> txnIds,
  ) =>
      (select(transactionItems)
            ..where((t) => t.transactionId.isIn(txnIds)))
          .get();

  Future<void> softDelete(String id, DateTime updatedAt) =>
      (update(transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          deletedAt: Value(updatedAt),
          updatedAt: Value(updatedAt),
        ),
      );

  Future<void> softDeleteWithOutbox(
    String id,
    DateTime updatedAt,
    SyncOutboxCompanion outbox,
  ) =>
      transaction(() async {
        await (update(transactions)..where((t) => t.id.equals(id))).write(
          TransactionsCompanion(
            deletedAt: Value(updatedAt),
            updatedAt: Value(updatedAt),
          ),
        );
        await into(syncOutbox).insert(outbox);
      });

  Future<void> upsertTxnFromSync(
    TransactionsCompanion txn,
    List<TransactionItemsCompanion> items,
  ) =>
      transaction(() async {
        await into(transactions).insertOnConflictUpdate(txn);
        await (delete(transactionItems)
              ..where((t) => t.transactionId.equals(txn.id.value)))
            .go();
        for (final item in items) {
          await into(transactionItems).insert(item);
        }
      });
}
