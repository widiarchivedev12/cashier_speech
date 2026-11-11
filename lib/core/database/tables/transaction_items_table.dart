import 'package:drift/drift.dart';

class TransactionItems extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text()();
  TextColumn get productId => text().nullable()();
  TextColumn get productName => text()(); // snapshot
  IntColumn get unitPrice => integer()(); // snapshot (rupiah)
  IntColumn get qty => integer()();
  IntColumn get lineTotal => integer()(); // rupiah

  @override
  Set<Column> get primaryKey => {id};
}
