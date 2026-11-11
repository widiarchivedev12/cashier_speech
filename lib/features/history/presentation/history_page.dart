import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../cashier/presentation/providers/cart_provider.dart';
import 'providers/history_provider.dart';

final _currency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final _dateTime = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

// WIB display helper
DateTime _toWib(DateTime utc) => utc.toUtc().add(const Duration(hours: 7));

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnsAsync = ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: txnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (txns) => txns.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada transaksi.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: txns.length,
                itemBuilder: (_, i) => _TransactionTile(txn: txns[i]),
              ),
      ),
    );
  }
}

class _TransactionTile extends ConsumerStatefulWidget {
  const _TransactionTile({required this.txn});

  final TransactionRow txn;

  @override
  ConsumerState<_TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends ConsumerState<_TransactionTile> {
  bool _expanded = false;
  bool _cancelling = false;

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Transaksi?'),
        content: Text(
          'Transaksi ${widget.txn.receiptNo} akan dibatalkan dan tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = true);
    try {
      await ref
          .read(transactionRepositoryProvider)
          .cancelTransaction(widget.txn.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membatalkan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txn = widget.txn;
    final wibTime = _toWib(txn.createdAt);
    final sourceIcon = txn.source == 'voice'
        ? Icons.mic
        : txn.source == 'mixed'
            ? Icons.mic_none
            : Icons.touch_app;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Icon(sourceIcon, size: 20),
            title: Text(
              txn.receiptNo,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(_dateTime.format(wibTime)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currency.format(txn.total),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                  tooltip: _expanded ? 'Tutup' : 'Lihat item',
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            _ItemsList(transactionId: txn.id),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Text(
                    'Bayar: ${_currency.format(txn.paid)}  '
                    'Kembalian: ${_currency.format(txn.change)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  _cancelling
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton.icon(
                          onPressed: _cancel,
                          icon: Icon(
                            Icons.cancel_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          label: Text(
                            'Batalkan',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemsList extends ConsumerWidget {
  const _ItemsList({required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(transactionRepositoryProvider);

    return FutureBuilder(
      future: repo.getItemsFor(transactionId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(),
          );
        }
        final items = snap.data!;
        return Column(
          children: items
              .map((item) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.productName)),
                        Text('${item.qty}×'),
                        const SizedBox(width: 8),
                        Text(_currency.format(item.lineTotal)),
                      ],
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
