import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:voice_parser/voice_parser.dart';

import '../../../core/sync/sync_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../catalog/presentation/providers/product_providers.dart';
import '../../voice/presentation/providers/voice_provider.dart';
import '../domain/cart.dart';
import '../domain/cart_item.dart';
import '../presentation/providers/cart_provider.dart';

final _currency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class CashierPage extends ConsumerStatefulWidget {
  const CashierPage({super.key});

  @override
  ConsumerState<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends ConsumerState<CashierPage> {
  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final productsAsync = ref.watch(activeProductsProvider);
    final voiceState = ref.watch(voiceProvider);

    ref.listen<VoiceState>(voiceProvider, (prev, next) {
      if (next.isDone && next.parseResult != null) {
        final catalog = productsAsync.value ?? [];
        final entries = catalog
            .map((p) => CatalogEntry(
                  productId: p.id,
                  name: p.name,
                  aliases: p.aliases,
                  price: p.price,
                ))
            .toList();
        ref
            .read(cartProvider.notifier)
            .applyParseResult(next.parseResult!, entries, next.transcript);
        context.push('/confirmation');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir Suara'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton.icon(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Bersihkan'),
            ),
          const _SyncButton(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Kasir Suara')),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Kasir'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Katalog Produk'),
              onTap: () {
                Navigator.pop(context);
                context.go('/catalog');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Keluar'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _MicButton(voiceState: voiceState),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (products) => products.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada produk aktif.\nTambah produk di menu Katalog.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) => _ProductCard(
                        product: products[i],
                        onTap: () => ref
                            .read(cartProvider.notifier)
                            .addProduct(products[i]),
                      ),
                    ),
            ),
          ),
          const Divider(height: 1),
          _CartSummary(cart: cart),
        ],
      ),
    );
  }
}

class _MicButton extends ConsumerWidget {
  const _MicButton({required this.voiceState});

  final VoiceState voiceState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isListening = voiceState.isListening;
    final notifier = ref.read(voiceProvider.notifier);

    return FloatingActionButton(
      key: const Key('btn_mic'),
      onPressed: isListening ? notifier.stopListening : notifier.startListening,
      backgroundColor: isListening ? Theme.of(context).colorScheme.error : null,
      tooltip: isListening ? 'Hentikan' : 'Rekam suara',
      child: Icon(isListening ? Icons.stop : Icons.mic),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final dynamic product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.name as String,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _currency.format(product.price as int),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartSummary extends ConsumerStatefulWidget {
  const _CartSummary({required this.cart});

  final Cart cart;

  @override
  ConsumerState<_CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends ConsumerState<_CartSummary> {
  final _payCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _payCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final txnId = await ref.read(cartProvider.notifier).confirmTransaction();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi tersimpan #$txnId'),
            backgroundColor: Colors.green,
          ),
        );
        _payCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cart.items.isNotEmpty) ...[
            SizedBox(
              height: 140,
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (_, i) => _CartItemRow(item: cart.items[i]),
              ),
            ),
            const Divider(),
          ],
          Row(
            children: [
              const Text('Total:'),
              const Spacer(),
              Text(
                _currency.format(cart.total),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _payCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dibayar (Rp)',
                    prefixText: 'Rp ',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    ref.read(cartProvider.notifier).setPayment(n);
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (cart.paid != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Kembalian', style: theme.textTheme.bodySmall),
                    Text(
                      _currency.format(cart.change),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cart.change >= 0
                            ? Colors.green
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('btn_save_transaction'),
              onPressed: (!cart.canSave || _saving) ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Simpan Transaksi'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncButton extends ConsumerWidget {
  const _SyncButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncProvider);
    return IconButton(
      tooltip: 'Sinkronisasi',
      onPressed: status == SyncStatus.syncing
          ? null
          : () => ref.read(syncProvider.notifier).sync(),
      icon: status == SyncStatus.syncing
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              status == SyncStatus.error ? Icons.sync_problem : Icons.sync,
              color: status == SyncStatus.error
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
    );
  }
}

class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);
    return Row(
      children: [
        Expanded(
          child: Text(item.productName,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: () => notifier.updateQty(item.id, item.qty - 1),
          tooltip: 'Kurangi',
        ),
        Text('${item.qty}', style: Theme.of(context).textTheme.titleSmall),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: () => notifier.updateQty(item.id, item.qty + 1),
          tooltip: 'Tambah',
        ),
        SizedBox(
          width: 90,
          child: Text(
            _currency.format(item.lineTotal),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
