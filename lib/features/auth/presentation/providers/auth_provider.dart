import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/app_state_provider.dart';
import '../../data/auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(Supabase.instance.client);

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  late AuthRepository _repo;

  @override
  Future<User?> build() async {
    _repo = ref.read(authRepositoryProvider);

    final sub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) async {
        final user = data.session?.user;
        state = AsyncData(user);
        if (data.event == AuthChangeEvent.signedIn) {
          await _syncStoreId(user);
        }
      },
    );
    ref.onDispose(sub.cancel);

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) await _syncStoreId(user);
    return user;
  }

  Future<void> _syncStoreId(User? user) async {
    if (user == null) return;
    final appState = await ref.read(appStateProvider.future);
    if (appState.storeId != null) return;
    final storeId = await _repo.getMyStoreId();
    if (storeId != null) {
      await ref.read(appStateProvider.notifier).setStoreId(storeId);
    }
  }

  Future<void> signIn(String email, String password) =>
      _repo.signIn(email, password);

  Future<void> signUp(String email, String password) =>
      _repo.signUp(email, password);

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(null);
  }
}
