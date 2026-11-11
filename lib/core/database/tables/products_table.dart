import 'package:drift/drift.dart';

import '../converters.dart';

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  IntColumn get price => integer()();
  TextColumn get aliases => text()
      .withDefault(const Constant('[]'))
      .map(const StringListConverter())();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
