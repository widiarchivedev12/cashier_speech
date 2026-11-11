import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/providers/app_state_provider.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/setup_store_page.dart';
import '../features/catalog/domain/product.dart';
import '../features/catalog/presentation/catalog_page.dart';
import '../features/catalog/presentation/product_form_page.dart';
import '../features/cashier/presentation/cashier_page.dart';
import '../features/voice/presentation/confirmation_page.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    refreshListenable: notifier,
    redirect: notifier.redirect,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const CashierPage()),
      GoRoute(
          path: '/confirmation', builder: (_, __) => const ConfirmationPage()),
      GoRoute(path: '/catalog', builder: (_, __) => const CatalogPage()),
      GoRoute(
          path: '/catalog/add', builder: (_, __) => const ProductFormPage()),
      GoRoute(
        path: '/catalog/edit',
        builder: (_, state) =>
            ProductFormPage(product: state.extra as Product?),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/setup-store', builder: (_, __) => const SetupStorePage()),
    ],
  );
}

class _RouterNotifier extends ChangeNotifier {
  AsyncValue<User?> _auth = const AsyncLoading();
  AsyncValue<AppState> _appState = const AsyncLoading();

  _RouterNotifier(Ref ref) {
    _auth = ref.read(authProvider);
    _appState = ref.read(appStateProvider);

    ref.listen<AsyncValue<User?>>(authProvider, (_, next) {
      _auth = next;
      notifyListeners();
    });
    ref.listen<AsyncValue<AppState>>(appStateProvider, (_, next) {
      _appState = next;
      notifyListeners();
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    if (_auth.isLoading || _appState.isLoading) return null;

    final user = _auth.value;
    final storeId = _appState.value?.storeId;
    final location = state.matchedLocation;

    if (user == null) {
      return location == '/login' ? null : '/login';
    }
    if (storeId == null) {
      return location == '/setup-store' ? null : '/setup-store';
    }
    if (location == '/login' || location == '/setup-store') return '/';
    return null;
  }
}
