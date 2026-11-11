import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../cashier/presentation/providers/cart_provider.dart';

// StreamProvider manual — riverpod_generator tidak bisa resolve tipe Drift
// yang didefinisikan di part file (.g.dart).
final recentTransactionsProvider =
    StreamProvider.autoDispose<List<TransactionRow>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final storeId = ref.watch(storeIdProvider);
  return repo.watchRecent(storeId);
});
