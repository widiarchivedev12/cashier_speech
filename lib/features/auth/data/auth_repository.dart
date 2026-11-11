import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<void> signIn(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signUp(String email, String password) =>
      _client.auth.signUp(email: email, password: password);

  Future<void> signOut() => _client.auth.signOut();

  Future<String?> getMyStoreId() async {
    final row = await _client
        .from('store_members')
        .select('store_id')
        .limit(1)
        .maybeSingle();
    return row?['store_id'] as String?;
  }

  Future<String> createStore(String name) async {
    final result = await _client.rpc(
      'create_store',
      params: {'store_name': name},
    );
    return result as String;
  }
}
