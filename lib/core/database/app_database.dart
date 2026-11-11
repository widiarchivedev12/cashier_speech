import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'converters.dart';
import 'daos/parse_log_dao.dart';
import 'daos/product_dao.dart';
import 'daos/transaction_dao.dart';
import 'tables/parse_logs_table.dart';
import 'tables/products_table.dart';
import 'tables/sync_outbox_table.dart';
import 'tables/sync_state_table.dart';
import 'tables/transaction_items_table.dart';
import 'tables/transactions_table.dart';

export 'daos/parse_log_dao.dart';
export 'daos/product_dao.dart';
export 'daos/transaction_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Transactions,
    TransactionItems,
    ParseLogs,
    SyncOutbox,
    SyncState,
  ],
  daos: [ProductDao, TransactionDao, ParseLogDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'kasir_suara',
      native: DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
