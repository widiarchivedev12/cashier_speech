import 'package:cashier_speech/app/router.dart';
import 'package:cashier_speech/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );
  runApp(const ProviderScope(child: KasirSuaraApp()));
}

class KasirSuaraApp extends StatelessWidget {
  const KasirSuaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kasir Suara',
      theme: appTheme,
      routerConfig: router,
    );
  }
}
