import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:voice_parser/voice_parser.dart';

import '../../cashier/domain/cart.dart';
import '../../cashier/domain/cart_item.dart';
import '../../cashier/presentation/providers/cart_provider.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/presentation/providers/product_providers.dart';
import '../../../core/providers/app_state_provider.dart';
import 'providers/voice_provider.dart';

final _currency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class ConfirmationPage extends ConsumerStatefulWidget {
  const ConfirmationPage({super.key});

  @override
  ConsumerState<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends ConsumerState<ConfirmationPage> {
  final _payCtrl = TextEditingController();
  final _dismissedUnknowns = <String>{};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final paid = ref.read(cartProvider).paid;
    if (paid != null) _payCtrl.text = paid.toString();
  }

  @override
  void dispose() {
    _payCtrl.dispose();
    super.dispose();
  }

  List<ParseIssue> _pendingUnknowns(List<ParseIssue> issues) => issues
      .where((i) =>
          i.type == IssueType.unknownProduct &&
          !_dismissedUnknowns.contains(i.sourceText))
      .toList();

  Future<void> _save(Cart cart) async {
    setState(() => _saving = true);
    try {
      final voiceState = ref.read(voiceProvider);
      final txnId = await ref
          .read(cartProvider.notifier)
          .confirmTransaction(source: 'voice');

      if (voiceState.parseResult != null) {
        final storeId = ref.read(storeIdProvider);
        await ref.read(parseLogRepositoryProvider).save(
              storeId: storeId,
              transactionId: txnId,
              transcript: voiceState.transcript,
              parsed: voiceState.parseResult!,
              parserVersion: parserVersion,
            );
      }

      ref.read(voiceProvider.notifier).reset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi tersimpan #$txnId'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
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

  Future<void> _pickProduct(
    BuildContext context,
    ParseIssue issue,
    List<Product> catalog,
  ) async {
    final picked = await showDialog<Product>(
      context: context,
      builder: (ctx) => _ProductPickerDialog(
        sourceText: issue.sourceText,
        suggestions: issue.suggestions,
        catalog: catalog,
      ),
    );
    if (picked != null && mounted) {
      ref.read(cartProvider.notifier).addProduct(picked);
      setState(() => _dismissedUnknowns.add(issue.sourceText));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final voiceState = ref.watch(voiceProvider);
    final productsAsync = ref.watch(activeProductsProvider);
    final issues = voiceState.parseResult?.issues ?? [];
    final unknowns = _pendingUnknowns(issues);
    final canSave = cart.canSave && unknowns.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(voiceProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (voiceState.transcript.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '"${voiceState.transcript}"',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          if (unknowns.isNotEmpty) ...[
            _SectionHeader(
              label: 'Tidak Dikenal',
              color: Theme.of(context).colorScheme.error,
            ),
            ...unknowns.map((issue) => productsAsync.maybeWhen(
                  data: (catalog) => _UnknownItemTile(
                    issue: issue,
                    onPick: () => _pickProduct(context, issue, catalog),
                    onDismiss: () => setState(
                        () => _dismissedUnknowns.add(issue.sourceText)),
                  ),
                  orElse: () => const SizedBox.shrink(),
                )),
            const SizedBox(height: 8),
          ],
          if (cart.items.isNotEmpty) ...[
            _SectionHeader(label: 'Item'),
            ...cart.items.map((item) => _ConfirmItemRow(item: item)),
            const Divider(),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Belum ada item di keranjang.'),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total'),
              Text(
                _currency.format(cart.total),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
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
              if (cart.paid != null) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Kembalian',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      _currency.format(cart.change),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: cart.change >= 0
                                ? Colors.green
                                : Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('btn_confirm_save'),
              onPressed: (canSave && !_saving) ? () => _save(cart) : null,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(unknowns.isNotEmpty
                  ? 'Selesaikan item tidak dikenal dulu'
                  : 'Simpan Transaksi'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color ?? Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ConfirmItemRow extends ConsumerWidget {
  const _ConfirmItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLowConfidence = item.confidence != null && item.confidence! < 0.88;
    final notifier = ref.read(cartProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName),
                if (isLowConfidence)
                  Text(
                    'Cocok rendah dari "${item.sourceText}"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () => notifier.updateQty(item.id, item.qty - 1),
            tooltip: 'Kurangi',
          ),
          Text('${item.qty}'),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _UnknownItemTile extends StatelessWidget {
  const _UnknownItemTile({
    required this.issue,
    required this.onPick,
    required this.onDismiss,
  });

  final ParseIssue issue;
  final VoidCallback onPick;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        dense: true,
        title: Text(
          'Tidak dikenal: "${issue.sourceText}"',
          style:
              TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
        subtitle: issue.suggestions.isNotEmpty
            ? Text(
                'Mungkin: ${issue.suggestions.take(3).join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: onPick, child: const Text('Pilih')),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              tooltip: 'Abaikan',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPickerDialog extends StatefulWidget {
  const _ProductPickerDialog({
    required this.sourceText,
    required this.suggestions,
    required this.catalog,
  });

  final String sourceText;
  final List<String> suggestions;
  final List<Product> catalog;

  @override
  State<_ProductPickerDialog> createState() => _ProductPickerDialogState();
}

class _ProductPickerDialogState extends State<_ProductPickerDialog> {
  String _query = '';

  List<Product> get _filtered {
    if (_query.isEmpty) {
      final suggestLower =
          widget.suggestions.map((s) => s.toLowerCase()).toSet();
      final top = widget.catalog
          .where((p) => suggestLower.contains(p.name.toLowerCase()))
          .toList();
      if (top.isNotEmpty) return top;
    }
    return widget.catalog
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pilih produk untuk "${widget.sourceText}"'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filtered.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(_filtered[i].name),
                  subtitle: Text(_currency.format(_filtered[i].price)),
                  onTap: () => Navigator.of(context).pop(_filtered[i]),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
