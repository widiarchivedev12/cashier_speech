import 'fuzzy.dart';
import 'models.dart';
import 'normalizer.dart';
import 'number_words.dart';

export 'models.dart';

const String parserVersion = '0.1.0';

ParseResult parse(
  String transcript,
  List<CatalogEntry> catalog, {
  ParserConfig config = const ParserConfig(),
}) {
  if (transcript.trim().isEmpty) return const ParseResult();

  final normalized = normalize(transcript);
  final segments = segment(normalized);

  final commands = <ParsedCommand>[];
  final issues = <ParseIssue>[];

  for (final seg in segments) {
    final clean = removeFiller(seg).trim();
    if (clean.isEmpty) continue;

    final result = _parseSegment(clean, catalog, config);
    commands.addAll(result.commands);
    issues.addAll(result.issues);
  }

  return ParseResult(commands: commands, issues: issues);
}

ParseResult _parseSegment(
  String seg,
  List<CatalogEntry> catalog,
  ParserConfig config,
) {
  // --- Intent: ClearCart ---
  if (_matchesClearCart(seg)) {
    return ParseResult(commands: [const ClearCart()]);
  }

  // --- Intent: RemoveLast ---
  if (_matchesRemoveLast(seg)) {
    return ParseResult(commands: [const RemoveLast()]);
  }

  // --- Intent: RemoveItem ---
  final removeResult = _tryRemoveItem(seg, catalog, config);
  if (removeResult != null) return removeResult;

  // --- Intent: SetPayment ---
  final paymentResult = _trySetPayment(seg);
  if (paymentResult != null) return paymentResult;

  // --- Intent: AddItem ---
  return _tryAddItem(seg, catalog, config);
}

// ----------------------------------------------------------------
// ClearCart patterns
// ----------------------------------------------------------------
final _clearCartPatterns = RegExp(
  r'\b(batal semua|batalkan semua|clear|kosongkan|mulai ulang|reset)\b',
);

bool _matchesClearCart(String seg) => _clearCartPatterns.hasMatch(seg);

// ----------------------------------------------------------------
// RemoveLast patterns
// ----------------------------------------------------------------
final _removeLast = RegExp(
  r'\b(hapus terakhir|batalkan terakhir|hapus yang terakhir|undo)\b',
);

bool _matchesRemoveLast(String seg) => _removeLast.hasMatch(seg);

// ----------------------------------------------------------------
// RemoveItem: "hapus <produk>" / "batalkan <produk>"
// ----------------------------------------------------------------
final _removePrefix = RegExp(r'^(hapus|batalkan|cancel)\s+');

ParseResult? _tryRemoveItem(
  String seg,
  List<CatalogEntry> catalog,
  ParserConfig config,
) {
  if (!_removePrefix.hasMatch(seg)) return null;
  final productPart = seg.replaceFirst(_removePrefix, '').trim();
  if (productPart.isEmpty) return null;

  // Pastikan bukan "hapus terakhir"
  if (RegExp(r'\bterakhir\b').hasMatch(productPart)) return null;

  final match = _bestMatch(productPart, catalog);
  if (match == null || match.$2 < config.suggestThreshold) return null;

  return ParseResult(
    commands: [RemoveItem(productId: match.$1.productId, sourceText: seg)],
  );
}

// ----------------------------------------------------------------
// SetPayment
// ----------------------------------------------------------------
final _paymentPrefix =
    RegExp(r'^(bayar|bayar dengan|pembayaran|terima|kasih)\s*');
final _exactPas = RegExp(r'\b(uang pas|pas|bayar pas|pas aja)\b');

ParseResult? _trySetPayment(String seg) {
  if (_exactPas.hasMatch(seg)) {
    return ParseResult(commands: [const SetPayment()]);
  }

  if (!_paymentPrefix.hasMatch(seg)) return null;
  final amountStr = seg.replaceFirst(_paymentPrefix, '').trim();
  if (amountStr.isEmpty) return ParseResult(commands: [const SetPayment()]);

  final amount = _parseAmount(amountStr);
  if (amount == null) return null;

  return ParseResult(commands: [SetPayment(amount: amount)]);
}

int? _parseAmount(String s) {
  // Sudah dinormalisasi — coba parse digit langsung
  final direct = int.tryParse(s);
  if (direct != null) return direct;

  // Coba angka kata
  final words = s.split(RegExp(r'\s+'));
  final res = parseNumberWords(words, 0);
  if (res != null && res.$2 == words.length) return res.$1;

  return null;
}

// ----------------------------------------------------------------
// AddItem
// ----------------------------------------------------------------
ParseResult _tryAddItem(
  String seg,
  List<CatalogEntry> catalog,
  ParserConfig config,
) {
  final words = seg.split(RegExp(r'\s+'));

  // Coba ekstrak qty dan token produk
  int? qty;
  int? lineTotalOverride;
  List<String> productTokens = [];

  // Coba "qty <produk>" — qty di depan
  var qtyResult = _tryParseQtyAtStart(words);
  if (qtyResult != null) {
    qty = qtyResult.$1;
    productTokens = words.sublist(qtyResult.$2);
  } else {
    // Coba "<produk> qty" — qty di belakang
    var qtyEnd = _tryParseQtyAtEnd(words);
    if (qtyEnd != null) {
      qty = qtyEnd.$1;
      productTokens = words.sublist(0, qtyEnd.$2);
    } else {
      productTokens = words;
    }
  }

  if (productTokens.isEmpty) {
    return ParseResult(
      commands: [Unknown(sourceText: seg)],
      issues: [ParseIssue(type: IssueType.unknownProduct, sourceText: seg)],
    );
  }

  final productQuery = productTokens.join(' ');

  // Periksa apakah ada angka besar di productTokens yang bukan qty melainkan harga
  // (angka > 999 yang tidak memiliki satuan qty di dekatnya)
  final largeNum = _extractLargeNumber(productTokens);
  if (largeNum != null) {
    // Angka besar → lineTotalOverride, sisanya adalah nama produk
    lineTotalOverride = largeNum.$1;
    final remaining = productTokens.where((w) => w != largeNum.$2).toList();
    final productOnly = remaining.join(' ').trim();
    final match = _bestMatch(productOnly, catalog);

    if (match == null || match.$2 < config.suggestThreshold) {
      return _unknownWithIssue(seg, catalog, config);
    }
    if (match.$2 < config.autoMatchThreshold) {
      return ParseResult(
        commands: [
          AddItem(
            productId: match.$1.productId,
            qty: qty ?? 1,
            lineTotalOverride: lineTotalOverride,
            confidence: match.$2,
            sourceText: seg,
          ),
        ],
        issues: [
          ParseIssue(
            type: IssueType.lowConfidence,
            sourceText: seg,
            suggestions: [match.$1.name],
          ),
        ],
      );
    }
    return ParseResult(
      commands: [
        AddItem(
          productId: match.$1.productId,
          qty: qty ?? 1,
          lineTotalOverride: lineTotalOverride,
          confidence: match.$2,
          sourceText: seg,
        ),
      ],
    );
  }

  final match = _bestMatch(productQuery, catalog);

  if (match == null || match.$2 < config.suggestThreshold) {
    return _unknownWithIssue(seg, catalog, config);
  }

  if (match.$2 < config.autoMatchThreshold) {
    return ParseResult(
      commands: [
        AddItem(
          productId: match.$1.productId,
          qty: qty ?? 1,
          confidence: match.$2,
          sourceText: seg,
        ),
      ],
      issues: [
        ParseIssue(
          type: IssueType.lowConfidence,
          sourceText: seg,
          suggestions: [match.$1.name],
        ),
      ],
    );
  }

  return ParseResult(
    commands: [
      AddItem(
        productId: match.$1.productId,
        qty: qty ?? 1,
        confidence: match.$2,
        sourceText: seg,
      ),
    ],
  );
}

ParseResult _unknownWithIssue(
  String seg,
  List<CatalogEntry> catalog,
  ParserConfig config,
) {
  // Cari saran terdekat
  final suggestions = catalog
      .map((e) => (e, jaroWinkler(seg, e.name.toLowerCase())))
      .where((p) => p.$2 >= 0.5)
      .toList()
    ..sort((a, b) => b.$2.compareTo(a.$2));

  return ParseResult(
    commands: [Unknown(sourceText: seg)],
    issues: [
      ParseIssue(
        type: IssueType.unknownProduct,
        sourceText: seg,
        suggestions: suggestions.take(3).map((p) => p.$1.name).toList(),
      ),
    ],
  );
}

// ----------------------------------------------------------------
// Qty parsing helpers
// ----------------------------------------------------------------

(int, int)? _tryParseQtyAtStart(List<String> words) {
  if (words.isEmpty) return null;
  // Angka digit
  final d = int.tryParse(words[0]);
  if (d != null && d > 0 && d < 1000) return (d, 1);
  // Angka kata
  final nw = parseNumberWords(words, 0);
  if (nw != null && nw.$1 > 0 && nw.$1 < 1000) return (nw.$1, nw.$2);
  return null;
}

(int, int)? _tryParseQtyAtEnd(List<String> words) {
  if (words.isEmpty) return null;
  // Angka digit di akhir
  final last = words.last;
  final d = int.tryParse(last);
  if (d != null && d > 0 && d < 1000) return (d, words.length - 1);
  // Angka kata di akhir (maks 4 kata)
  for (var len = 4; len >= 1; len--) {
    final start = words.length - len;
    if (start < 0) continue;
    final res = parseNumberWords(words, start);
    if (res != null && res.$2 == words.length && res.$1 > 0 && res.$1 < 1000) {
      return (res.$1, start);
    }
  }
  return null;
}

// Deteksi angka besar (≥ 1000) dalam token — kemungkinan harga bukan qty
(int, String)? _extractLargeNumber(List<String> tokens) {
  for (final t in tokens) {
    final v = int.tryParse(t);
    if (v != null && v >= 1000) return (v, t);
  }
  // Coba angka kata yang ≥ 1000
  final words = tokens;
  for (var start = 0; start < words.length; start++) {
    for (var len = 4; len >= 2; len--) {
      if (start + len > words.length) continue;
      final phrase = words.sublist(start, start + len).join(' ');
      // Hanya frasa yang mengandung ribu/juta/ratus
      if (!RegExp(r'\b(ribu|rebu|ewu|ratus|juta)\b').hasMatch(phrase)) {
        continue;
      }
      final res = parseNumberWords(words, start);
      if (res != null && res.$1 >= 1000 && res.$2 == start + len) {
        // Kembalikan token-token yang membentuk angka ini sebagai string gabungan
        return (res.$1, words.sublist(start, res.$2).join(' '));
      }
    }
  }
  return null;
}

// ----------------------------------------------------------------
// Fuzzy matching
// ----------------------------------------------------------------

(CatalogEntry, double)? _bestMatch(
  String query,
  List<CatalogEntry> catalog,
) {
  if (query.isEmpty || catalog.isEmpty) return null;

  (CatalogEntry, double)? best;
  for (final entry in catalog) {
    final candidates = [
      entry.name.toLowerCase(),
      ...entry.aliases.map((a) => a.toLowerCase()),
    ];
    for (final candidate in candidates) {
      final score = jaroWinkler(query, candidate);
      if (best == null || score > best.$2) {
        best = (entry, score);
      }
    }
  }
  return best;
}
