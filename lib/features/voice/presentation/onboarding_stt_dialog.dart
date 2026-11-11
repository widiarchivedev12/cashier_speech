import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

const _kPrefKey = 'stt_onboarding_shown';

/// Checks once per install whether the Indonesian STT locale is available.
/// If not, shows a dialog guiding the user to download the language pack.
/// Safe to call every time the page loads — skips silently if already shown.
Future<void> checkSttOnboarding(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_kPrefKey) == true) return;

  final stt = SpeechToText();
  final available = await stt.initialize();
  bool hasIndonesian = false;

  if (available) {
    final locales = await stt.locales();
    hasIndonesian = locales.any(
      (l) => l.localeId.startsWith('id'),
    );
  }

  await prefs.setBool(_kPrefKey, true);

  if (!context.mounted) return;

  if (!hasIndonesian) {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SttOnboardingDialog(),
    );
  }
}

class _SttOnboardingDialog extends StatelessWidget {
  const _SttOnboardingDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aktifkan Suara Bahasa Indonesia'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paket bahasa Indonesia untuk pengenalan suara belum terpasang '
              'di perangkat ini.',
            ),
            SizedBox(height: 12),
            Text(
              'Cara mengaktifkan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text('1. Buka Pengaturan → Manajemen Umum → Bahasa & Input'),
            Text('2. Pilih Pengenalan Suara Google'),
            Text('3. Unduh paket "Indonesia"'),
            SizedBox(height: 12),
            Text(
              'Tanpa paket ini, input suara tidak tersedia. '
              'Input manual tetap bisa digunakan.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Mengerti'),
        ),
      ],
    );
  }
}
