import 'package:supabase_flutter/supabase_flutter.dart';

import 'sync_remote.dart';

class SupabaseSyncRemote implements SyncRemote {
  SupabaseSyncRemote(this._client);

  final SupabaseClient _client;

  @override
  Future<void> pushProduct(Map<String, dynamic> payload) =>
      _client.from('products').upsert(payload);

  @override
  Future<void> pushTransaction(Map<String, dynamic> payload) =>
      _client.rpc('upsert_transaction', params: {'payload': payload});

  @override
  Future<void> pushParseLog(Map<String, dynamic> payload) =>
      _client.from('parse_logs').insert(payload);

  @override
  Future<List<Map<String, dynamic>>> pullProducts(
    String storeId,
    DateTime since,
  ) async {
    final rows = await _client
        .from('products')
        .select()
        .eq('store_id', storeId)
        .gt('server_updated_at', since.toIso8601String())
        .order('server_updated_at');
    return (rows as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> pullTransactions(
    String storeId,
    DateTime since,
  ) async {
    final rows = await _client
        .from('transactions')
        .select('*, transaction_items(*)')
        .eq('store_id', storeId)
        .gt('server_updated_at', since.toIso8601String())
        .order('server_updated_at');
    return (rows as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
