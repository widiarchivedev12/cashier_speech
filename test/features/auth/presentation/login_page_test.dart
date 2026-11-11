import 'package:cashier_speech/features/auth/presentation/login_page.dart';
import 'package:cashier_speech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Fake notifier — extends the public AuthNotifier class (not the generated _$).
class _SuccessAuthNotifier extends AuthNotifier {
  @override
  Future<User?> build() async => null;

  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> signUp(String email, String password) async {}

  @override
  Future<void> signOut() async {}
}

class _FailAuthNotifier extends AuthNotifier {
  @override
  Future<User?> build() async => null;

  @override
  Future<void> signIn(String email, String password) async {
    throw const AuthException('Email atau kata sandi salah');
  }

  @override
  Future<void> signUp(String email, String password) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  group('LoginPage', () {
    testWidgets('shows email and password fields', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [authProvider.overrideWith(() => _SuccessAuthNotifier())],
        child: const MaterialApp(home: LoginPage()),
      ));
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byKey(const Key('btn_sign_in')), findsOneWidget);
      expect(find.byKey(const Key('btn_sign_up')), findsOneWidget);
    });

    testWidgets('validates empty email', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [authProvider.overrideWith(() => _SuccessAuthNotifier())],
        child: const MaterialApp(home: LoginPage()),
      ));
      await tester.pump();

      await tester.tap(find.byKey(const Key('btn_sign_in')));
      await tester.pump();

      expect(find.text('Wajib diisi'), findsOneWidget);
    });

    testWidgets('validates short password', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [authProvider.overrideWith(() => _SuccessAuthNotifier())],
        child: const MaterialApp(home: LoginPage()),
      ));
      await tester.pump();

      await tester.enterText(
          find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(find.byType(TextFormField).last, '12345');
      await tester.tap(find.byKey(const Key('btn_sign_in')));
      await tester.pump();

      expect(find.text('Min. 6 karakter'), findsOneWidget);
    });

    testWidgets('shows error on sign in failure', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [authProvider.overrideWith(() => _FailAuthNotifier())],
        child: const MaterialApp(home: LoginPage()),
      ));
      await tester.pump();

      await tester.enterText(
          find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byKey(const Key('btn_sign_in')));
      await tester.pumpAndSettle();

      expect(find.text('Email atau kata sandi salah'), findsOneWidget);
    });

    testWidgets('no error shown after successful sign in', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [authProvider.overrideWith(() => _SuccessAuthNotifier())],
        child: const MaterialApp(home: LoginPage()),
      ));
      await tester.pump();

      await tester.enterText(
          find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byKey(const Key('btn_sign_in')));
      await tester.pumpAndSettle();

      expect(find.text('Email atau kata sandi salah'), findsNothing);
      expect(find.text('Wajib diisi'), findsNothing);
    });
  });
}
