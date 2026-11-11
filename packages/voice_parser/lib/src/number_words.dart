// Konversi angka kata Bahasa Indonesia → int
// Contoh: "dua puluh ribu" → 20000, "seratus lima puluh" → 150

const _singles = {
  'nol': 0,
  'satu': 1,
  'dua': 2,
  'tiga': 3,
  'empat': 4,
  'lima': 5,
  'enam': 6,
  'tujuh': 7,
  'delapan': 8,
  'sembilan': 9,
  'sepuluh': 10,
  'sebelas': 11,
};

const _teens = {
  'dua belas': 12,
  'tiga belas': 13,
  'empat belas': 14,
  'lima belas': 15,
  'enam belas': 16,
  'tujuh belas': 17,
  'delapan belas': 18,
  'sembilan belas': 19,
};

const _tens = {
  'dua puluh': 20,
  'tiga puluh': 30,
  'empat puluh': 40,
  'lima puluh': 50,
  'enam puluh': 60,
  'tujuh puluh': 70,
  'delapan puluh': 80,
  'sembilan puluh': 90,
};

/// Mencoba parse angka kata dari [words] mulai indeks [start].
/// Mengembalikan (nilai, indeks setelah kata terakhir yang terpakai) atau null.
(int, int)? parseNumberWords(List<String> words, int start) {
  if (start >= words.length) return null;

  // Coba multi-word patterns dulu (longest-match)
  for (var len = 4; len >= 1; len--) {
    if (start + len > words.length) continue;
    final phrase = words.sublist(start, start + len).join(' ');
    final v = _parsePhrase(phrase);
    if (v != null) return (v, start + len);
  }
  return null;
}

int? _parsePhrase(String phrase) {
  // Exact singles
  if (_singles.containsKey(phrase)) return _singles[phrase];

  // X belas (dua belas ... sembilan belas)
  if (_teens.containsKey(phrase)) return _teens[phrase];

  // X puluh
  if (_tens.containsKey(phrase)) return _tens[phrase];

  // X puluh Y (dua puluh lima)
  for (final entry in _tens.entries) {
    if (phrase.startsWith('${entry.key} ')) {
      final rest = phrase.substring(entry.key.length + 1);
      final single = _singles[rest];
      if (single != null) return entry.value + single;
    }
  }

  // seratus / X ratus
  if (phrase == 'seratus') return 100;
  final ratusMatch = RegExp(r'^(.+) ratus$').firstMatch(phrase);
  if (ratusMatch != null) {
    final v = _parsePhrase(ratusMatch.group(1)!);
    if (v != null) return v * 100;
  }
  final ratusRest = RegExp(r'^(.+) ratus (.+)$').firstMatch(phrase);
  if (ratusRest != null) {
    final a = _parsePhrase(ratusRest.group(1)!);
    final b = _parsePhrase(ratusRest.group(2)!);
    if (a != null && b != null) return a * 100 + b;
  }

  // seribu / X ribu / X rebu / X ewu
  if (phrase == 'seribu' || phrase == 'se ribu') return 1000;
  final ribuMatch = RegExp(r'^(.+)\s+(ribu|rebu|ewu)$').firstMatch(phrase);
  if (ribuMatch != null) {
    final v = _parsePhrase(ribuMatch.group(1)!);
    if (v != null) return v * 1000;
  }
  final ribuRest =
      RegExp(r'^(.+)\s+(ribu|rebu|ewu)\s+(.+)$').firstMatch(phrase);
  if (ribuRest != null) {
    final a = _parsePhrase(ribuRest.group(1)!);
    final b = _parsePhrase(ribuRest.group(3)!);
    if (a != null && b != null) return a * 1000 + b;
  }

  // sejuta / X juta
  if (phrase == 'sejuta') return 1000000;
  final jutaMatch = RegExp(r'^(.+)\s+juta$').firstMatch(phrase);
  if (jutaMatch != null) {
    final v = _parsePhrase(jutaMatch.group(1)!);
    if (v != null) return v * 1000000;
  }

  return null;
}

/// Parse single angka digit dari string token.
int? parseDigit(String token) => int.tryParse(token);
