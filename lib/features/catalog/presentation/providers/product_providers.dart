import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/product_repository.dart';

part 'product_providers.g.dart';

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) =>
    ProductRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<List<Product>> activeProducts(Ref ref) {
  final repo = ref.watch(productRepositoryProvider);
  final store = ref.watch(storeIdProvider);
  return repo.watchActive(store);
}
