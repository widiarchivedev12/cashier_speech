import 'package:go_router/go_router.dart';

import '../features/catalog/domain/product.dart';
import '../features/catalog/presentation/catalog_page.dart';
import '../features/catalog/presentation/product_form_page.dart';
import '../features/cashier/presentation/cashier_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CashierPage(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const CatalogPage(),
    ),
    GoRoute(
      path: '/catalog/add',
      builder: (context, state) => const ProductFormPage(),
    ),
    GoRoute(
      path: '/catalog/edit',
      builder: (context, state) =>
          ProductFormPage(product: state.extra as Product?),
    ),
  ],
);
