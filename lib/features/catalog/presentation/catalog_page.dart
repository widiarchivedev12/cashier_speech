import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/product.dart';
import '../presentation/providers/product_providers.dart';
import 'product_form_page.dart';

final _currency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(activeProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Produk')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        tooltip: 'Tambah produk',
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (products) => products.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada produk.\nKetuk + untuk menambah.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) => _ProductTile(product: products[i]),
              ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref,
      [Product? product]) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(product: product),
      ),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(product.name),
      subtitle: product.aliases.isNotEmpty
          ? Text(product.aliases.join(', '),
              style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: Text(
        _currency.format(product.price),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductFormPage(product: product),
        ),
      ),
      onLongPress: () => _confirmDeactivate(context, ref),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product.isActive
            ? 'Nonaktifkan ${product.name}?'
            : 'Aktifkan ${product.name}?'),
        content: Text(product.isActive
            ? 'Produk tidak akan muncul di kasir.'
            : 'Produk akan muncul kembali di kasir.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya')),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(productRepositoryProvider);
      final now = DateTime.now().toUtc();
      await repo
          .save(product.copyWith(isActive: !product.isActive, updatedAt: now));
    }
  }
}
