import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/products_table.dart';
import '../tables/sync_outbox_table.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products, SyncOutbox])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  Stream<List<ProductRow>> watchActive(String storeId) => (select(products)
        ..where(
          (t) =>
              t.storeId.equals(storeId) &
              t.isActive.equals(true) &
              t.deletedAt.isNull(),
        )
        ..orderBy([(t) => OrderingTerm(expression: t.name)]))
      .watch();

  Future<List<ProductRow>> getAll(String storeId) => (select(products)
        ..where((t) => t.storeId.equals(storeId) & t.deletedAt.isNull()))
      .get();

  Future<ProductRow?> getById(String id) =>
      (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertWithOutbox(
    ProductsCompanion product,
    SyncOutboxCompanion outbox,
  ) =>
      transaction(() async {
        await into(products).insertOnConflictUpdate(product);
        await into(syncOutbox).insert(outbox);
      });
}
