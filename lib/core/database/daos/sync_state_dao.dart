import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_state_table.dart';

part 'sync_state_dao.g.dart';

@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  Future<DateTime?> getCursor(String entity) async {
    final row = await (select(syncState)..where((t) => t.entity.equals(entity)))
        .getSingleOrNull();
    return row?.lastPulledServerUpdatedAt;
  }

  Future<void> setCursor(String entity, DateTime cursor) =>
      into(syncState).insertOnConflictUpdate(
        SyncStateCompanion.insert(
          entity: entity,
          lastPulledServerUpdatedAt: Value(cursor),
        ),
      );
}
