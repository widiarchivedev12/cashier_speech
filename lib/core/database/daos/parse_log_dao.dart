import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/parse_logs_table.dart';

part 'parse_log_dao.g.dart';

@DriftAccessor(tables: [ParseLogs])
class ParseLogDao extends DatabaseAccessor<AppDatabase>
    with _$ParseLogDaoMixin {
  ParseLogDao(super.db);

  Future<void> insert(ParseLogsCompanion log) => into(parseLogs).insert(log);

  Stream<List<ParseLogRow>> watchRecent(String storeId, {int limit = 50}) =>
      (select(parseLogs)
            ..where((t) => t.storeId.equals(storeId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .watch();
}
