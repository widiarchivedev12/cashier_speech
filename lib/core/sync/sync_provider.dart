import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/app_state_provider.dart';
import '../providers/database_provider.dart';
import 'supabase_sync_remote.dart';
import 'sync_engine.dart';

part 'sync_provider.g.dart';

@Riverpod(keepAlive: true)
SyncEngine syncEngine(Ref ref) => SyncEngine(
      ref.watch(appDatabaseProvider),
      SupabaseSyncRemote(Supabase.instance.client),
    );

enum SyncStatus { idle, syncing, error }

@Riverpod(keepAlive: true)
class SyncNotifier extends _$SyncNotifier {
  @override
  SyncStatus build() => SyncStatus.idle;

  Future<void> sync() async {
    final storeId = ref.read(storeIdProvider);
    if (storeId == kPlaceholderStoreId) return;
    if (state == SyncStatus.syncing) return;
    state = SyncStatus.syncing;
    try {
      await ref.read(syncEngineProvider).sync(storeId: storeId);
      state = SyncStatus.idle;
    } catch (_) {
      state = SyncStatus.error;
    }
  }
}
