// Jaro-Winkler similarity untuk fuzzy matching produk
// Implementasi pure Dart, tidak ada dependensi eksternal

double jaroWinkler(String s1, String s2) {
  if (s1 == s2) return 1.0;
  if (s1.isEmpty || s2.isEmpty) return 0.0;

  final jaro = _jaro(s1, s2);
  final prefixLen = _commonPrefixLen(s1, s2, 4);
  return jaro + prefixLen * 0.1 * (1 - jaro);
}

double _jaro(String s1, String s2) {
  final len1 = s1.length;
  final len2 = s2.length;
  final matchDist = (([len1, len2].reduce((a, b) => a > b ? a : b) / 2) - 1)
      .floor()
      .clamp(0, 999);

  final s1Matches = List.filled(len1, false);
  final s2Matches = List.filled(len2, false);
  var matches = 0;
  var transpositions = 0;

  for (var i = 0; i < len1; i++) {
    final start = (i - matchDist).clamp(0, len2 - 1);
    final end = (i + matchDist + 1).clamp(0, len2);
    for (var j = start; j < end; j++) {
      if (s2Matches[j] || s1[i] != s2[j]) {
        continue;
      }
      s1Matches[i] = true;
      s2Matches[j] = true;
      matches++;
      break;
    }
  }

  if (matches == 0) return 0.0;

  var k = 0;
  for (var i = 0; i < len1; i++) {
    if (!s1Matches[i]) {
      continue;
    }
    while (!s2Matches[k]) {
      k++;
    }
    if (s1[i] != s2[k]) transpositions++;
    k++;
  }

  final m = matches.toDouble();
  return (m / len1 + m / len2 + (m - transpositions / 2) / m) / 3;
}

int _commonPrefixLen(String s1, String s2, int max) {
  var i = 0;
  while (i < max && i < s1.length && i < s2.length && s1[i] == s2[i]) {
    i++;
  }
  return i;
}
