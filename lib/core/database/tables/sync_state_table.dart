import 'package:drift/drift.dart';

@DataClassName('SyncStateEntry')
class SyncState extends Table {
  TextColumn get entity => text()();
  DateTimeColumn get lastPulledServerUpdatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {entity};
}
