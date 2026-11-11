// Normalisasi & tokenisasi teks input sebelum parsing
final _rp = RegExp(r'rp\.?\s*', caseSensitive: false);
final _rbK = RegExp(r'(\d+)\s*(rb|ribu|k\b)', caseSensitive: false);
final _juta = RegExp(r'(\d+)\s*(jt|juta)', caseSensitive: false);
final _punct = RegExp(r'[.,!?;]');

String normalize(String text) {
  var s = text.toLowerCase().trim();
  // Rp50.000 / Rp 50.000 → hilangkan Rp dan titik ribuan
  s = s.replaceAllMapped(_rbK, (m) {
    final n = int.parse(m[1]!);
    return '${n * 1000}';
  });
  s = s.replaceAllMapped(_juta, (m) {
    final n = int.parse(m[1]!);
    return '${n * 1000000}';
  });
  s = s.replaceAll(_rp, '');
  // Hilangkan titik di dalam angka (1.000 → 1000)
  s = s.replaceAllMapped(RegExp(r'(\d)\.(\d{3})'), (m) => '${m[1]}${m[2]}');
  // Ganti koma sebagai separator segment → TAB (agar tidak konflik)
  s = s.replaceAll(',', '\t');
  // Hapus tanda baca lain
  s = s.replaceAll(_punct, '');
  return s;
}

// Pemisah segment
final _segmentSep = RegExp(r'\t|\b(dan|sama|terus|lalu|plus)\b');

List<String> segment(String normalized) {
  return normalized
      .split(_segmentSep)
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

// Kata filler yang dihapus
const _fillers = {
  'jual',
  'tambah',
  'minta',
  'ya',
  'deh',
  'dong',
  'kak',
  'mbak',
  'mas',
  'bu',
  'pak',
  'aja',
  'tolong',
  'boleh',
  'mau',
};

String removeFiller(String segment) {
  final words = segment.split(RegExp(r'\s+'));
  return words.where((w) => !_fillers.contains(w)).join(' ').trim();
}
