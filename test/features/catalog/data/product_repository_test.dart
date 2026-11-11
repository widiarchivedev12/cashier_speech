import 'package:cashier_speech/core/database/app_database.dart';
import 'package:cashier_speech/features/catalog/data/product_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

Product _product({
  String id = 'p1',
  String storeId = 'store1',
  String name = 'Brownies',
  int price = 10000,
  List<String> aliases = const ['bronis'],
  bool isActive = true,
}) {
  final now = DateTime(2026, 11, 11, 10).toUtc();
  return Product(
    id: id,
    storeId: storeId,
    name: name,
    price: price,
    aliases: aliases,
    isActive: isActive,
    createdAt: now,
    updatedAt: now,
    serverUpdatedAt: now,
  );
}

void main() {
  group('ProductRepository', () {
    late AppDatabase db;
    late ProductRepository repo;

    setUp(() {
      db = _makeDb();
      repo = ProductRepository(db);
    });

    tearDown(() => db.close());

    test('save inserts product row', () async {
      final p = _product();
      await repo.save(p);

      final rows = await db.select(db.products).get();
      expect(rows, hasLength(1));
      expect(rows.first.name, 'Brownies');
      expect(rows.first.price, 10000);
      expect(rows.first.aliases, ['bronis']);
    });

    test('save writes sync_outbox row in same transaction', () async {
      final p = _product();
      await repo.save(p);

      final outbox = await db.select(db.syncOutbox).get();
      expect(outbox, hasLength(1));
      expect(outbox.first.entity, 'products');
      expect(outbox.first.recordId, 'p1');
      expect(outbox.first.op, 'upsert');
    });

    test('save upserts — second save updates existing row', () async {
      final p = _product();
      await repo.save(p);
      await repo.save(p.copyWith(name: 'Brownies Special', price: 12000));

      final rows = await db.select(db.products).get();
      expect(rows, hasLength(1));
      expect(rows.first.name, 'Brownies Special');
      expect(rows.first.price, 12000);

      final outbox = await db.select(db.syncOutbox).get();
      expect(outbox, hasLength(2));
    });

    test('softDelete sets deletedAt and writes outbox', () async {
      final p = _product();
      await repo.save(p);

      final deleted = await repo.softDelete(p);

      final rows = await db.select(db.products).get();
      expect(rows.first.deletedAt, isNotNull);
      expect(deleted.deletedAt, isNotNull);

      final outbox = await db.select(db.syncOutbox).get();
      expect(outbox, hasLength(2)); // insert + delete
    });

    test('watchActive emits only active non-deleted products for storeId',
        () async {
      await repo.save(_product(id: 'p1', storeId: 'store1'));
      await repo.save(_product(id: 'p2', storeId: 'store1', isActive: false));
      await repo.save(_product(id: 'p3', storeId: 'store2'));

      final first = await repo.watchActive('store1').first;
      expect(first.map((p) => p.id), ['p1']);
    });

    test('getAll returns all non-deleted products for storeId', () async {
      await repo.save(_product(id: 'p1', storeId: 'store1'));
      await repo.save(_product(id: 'p2', storeId: 'store2'));

      final all = await repo.getAll('store1');
      expect(all.map((p) => p.id), ['p1']);
    });
  });
}
