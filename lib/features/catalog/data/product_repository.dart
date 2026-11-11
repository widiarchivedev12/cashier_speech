import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/product.dart';

export '../domain/product.dart';

class ProductRepository {
  ProductRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Product>> watchActive(String storeId) =>
      _db.productDao.watchActive(storeId).map(_mapRows);

  Future<List<Product>> getAll(String storeId) async =>
      _mapRows(await _db.productDao.getAll(storeId));

  Future<Product?> getById(String id) async {
    final row = await _db.productDao.getById(id);
    return row == null ? null : _mapRow(row);
  }

  Future<Product> save(Product product) async {
    final companion = ProductsCompanion(
      id: Value(product.id),
      storeId: Value(product.storeId),
      name: Value(product.name),
      price: Value(product.price),
      aliases: Value(product.aliases),
      isActive: Value(product.isActive),
      createdAt: Value(product.createdAt),
      updatedAt: Value(product.updatedAt),
      serverUpdatedAt: Value(product.serverUpdatedAt),
      deletedAt: Value(product.deletedAt),
    );

    final outbox = SyncOutboxCompanion.insert(
      id: _uuid.v4(),
      entity: 'products',
      recordId: product.id,
      op: 'upsert',
      payload: jsonEncode(_productToJson(product)),
      createdAt: DateTime.now().toUtc(),
    );

    await _db.productDao.upsertWithOutbox(companion, outbox);
    return product;
  }

  Future<Product> softDelete(Product product) async {
    final now = DateTime.now().toUtc();
    final deleted = product.copyWith(deletedAt: now, updatedAt: now);
    return save(deleted);
  }

  static List<Product> _mapRows(List<ProductRow> rows) =>
      rows.map(_mapRow).toList();

  static Product _mapRow(ProductRow r) => Product(
        id: r.id,
        storeId: r.storeId,
        name: r.name,
        price: r.price,
        aliases: r.aliases,
        isActive: r.isActive,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        serverUpdatedAt: r.serverUpdatedAt,
        deletedAt: r.deletedAt,
      );

  static Map<String, dynamic> _productToJson(Product p) => {
        'id': p.id,
        'store_id': p.storeId,
        'name': p.name,
        'price': p.price,
        'aliases': p.aliases,
        'is_active': p.isActive,
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
        'deleted_at': p.deletedAt?.toIso8601String(),
      };
}
