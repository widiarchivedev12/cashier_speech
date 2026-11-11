import 'package:drift/drift.dart';

@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get deviceId => text()();
  TextColumn get receiptNo => text()();
  IntColumn get total => integer()();
  IntColumn get paid => integer()();
  IntColumn get change => integer()();
  TextColumn get source => text()(); // 'voice' | 'manual' | 'mixed'
  TextColumn get rawTranscript => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
