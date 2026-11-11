import 'package:drift/drift.dart';

class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get entity =>
      text()(); // 'products' | 'transactions' | 'parse_logs'
  TextColumn get recordId => text()();
  TextColumn get op => text()(); // 'upsert' | 'delete'
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
