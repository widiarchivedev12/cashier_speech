import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_outbox_table.dart';

part 'sync_outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutbox])
class SyncOutboxDao extends DatabaseAccessor<AppDatabase>
    with _$SyncOutboxDaoMixin {
  SyncOutboxDao(super.db);

  Future<List<SyncOutboxData>> getPending({int limit = 50}) =>
      (select(syncOutbox)
            ..where((t) => t.attempts.isSmallerThanValue(5))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(limit))
          .get();

  Future<void> deleteById(String id) =>
      (delete(syncOutbox)..where((t) => t.id.equals(id))).go();

  Future<void> recordFailure(String id, String error) => customUpdate(
        'UPDATE sync_outbox SET attempts = attempts + 1, last_error = ? WHERE id = ?',
        variables: [Variable.withString(error), Variable.withString(id)],
        updates: {syncOutbox},
      );

  Stream<int> watchPendingCount() => (selectOnly(syncOutbox)
        ..addColumns([syncOutbox.id.count()])
        ..where(syncOutbox.attempts.isSmallerThanValue(5)))
      .map((row) => row.read(syncOutbox.id.count()) ?? 0)
      .watchSingle();
}
