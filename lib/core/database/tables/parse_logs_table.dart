import 'package:drift/drift.dart';

@DataClassName('ParseLogRow')
class ParseLogs extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get transactionId => text().nullable()();
  TextColumn get transcript => text()();
  TextColumn get parsed => text()(); // JSON
  TextColumn get corrected => text().nullable()(); // JSON
  TextColumn get parserVersion => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
