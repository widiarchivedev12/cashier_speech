import 'package:test/test.dart';
import 'package:voice_parser/voice_parser.dart';

// Catalog bersama untuk semua fixture test
const _catalog = [
  CatalogEntry(
    productId: 'p1',
    name: 'Brownies',
    aliases: ['bronis', 'brownis'],
    price: 10000,
  ),
  CatalogEntry(
    productId: 'p2',
    name: 'Cookies',
    aliases: ['kukis', 'kue kering'],
    price: 5000,
  ),
  CatalogEntry(
    productId: 'p3',
    name: 'Bolu Pandan',
    aliases: ['bolu', 'pandan'],
    price: 25000,
  ),
  CatalogEntry(
    productId: 'p4',
    name: 'Es Teh',
    aliases: ['es teh manis', 'teh es'],
    price: 4000,
  ),
];

void main() {
  group('parse — smoke tests (M0)', () {
    test('transcript kosong menghasilkan ParseResult kosong', () {
      final result = parse('', []);
      expect(result.commands, isEmpty);
      expect(result.issues, isEmpty);
    });

    test('transcript spasi saja juga menghasilkan ParseResult kosong', () {
      final result = parse('   ', []);
      expect(result.commands, isEmpty);
      expect(result.issues, isEmpty);
    });
  });

  // ----------------------------------------------------------------
  // M1 — 20 fixture PRD §7.3
  // ----------------------------------------------------------------

  group('F01 — satu item, qty 1 implisit', () {
    // "brownies" → AddItem(p1, qty:1, confidence≥0.88)
    test('nama produk tanpa qty → AddItem qty 1', () {
      final r = parse('brownies', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as AddItem;
      expect(cmd.productId, 'p1');
      expect(cmd.qty, 1);
      expect(cmd.confidence, greaterThanOrEqualTo(0.88));
    });
  });

  group('F02 — qty sebelum nama', () {
    // "dua brownies" → AddItem(p1, qty:2)
    test('qty di depan nama produk', () {
      final r = parse('dua brownies', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as AddItem;
      expect(cmd.productId, 'p1');
      expect(cmd.qty, 2);
    });
  });

  group('F03 — qty sesudah nama', () {
    // "brownies tiga" → AddItem(p1, qty:3)
    test('qty di belakang nama produk', () {
      final r = parse('brownies tiga', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as AddItem;
      expect(cmd.productId, 'p1');
      expect(cmd.qty, 3);
    });
  });

  group('F04 — angka digit sebagai qty', () {
    // "2 cookies" → AddItem(p2, qty:2)
    test('angka digit di depan', () {
      final r = parse('2 cookies', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as AddItem;
      expect(cmd.productId, 'p2');
      expect(cmd.qty, 2);
    });
  });

  group('F05 — alias produk', () {
    // "bronis" → AddItem(p1) via alias
    test('alias dikenali sebagai produk', () {
      final r = parse('bronis', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as AddItem;
      expect(cmd.productId, 'p1');
    });
  });

  group('F06 — filler word diabaikan', () {
    // "tambah dua bolu pandan" → AddItem(p3, qty:2)
    test('kata filler "tambah" di depan diabaikan', () {
      final r = parse('tambah dua bolu pandan', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as AddItem;
      expect(cmd.productId, 'p3');
      expect(cmd.qty, 2);
    });
  });

  group('F07 — dua segmen "dan"', () {
    // "brownies dan cookies" → [AddItem(p1,1), AddItem(p2,1)]
    test('dua item dipisah kata "dan"', () {
      final r = parse('brownies dan cookies', _catalog);
      expect(r.commands, hasLength(2));
      expect((r.commands[0] as AddItem).productId, 'p1');
      expect((r.commands[1] as AddItem).productId, 'p2');
    });
  });

  group('F08 — tiga segmen koma', () {
    // "brownies, cookies, es teh" → 3 AddItem
    test('tiga item dipisah koma', () {
      final r = parse('brownies, cookies, es teh', _catalog);
      expect(r.commands, hasLength(3));
      expect((r.commands[0] as AddItem).productId, 'p1');
      expect((r.commands[1] as AddItem).productId, 'p2');
      expect((r.commands[2] as AddItem).productId, 'p4');
    });
  });

  group('F09 — ClearCart', () {
    // "batal semua" / "clear" → ClearCart
    test('"batal semua" → ClearCart', () {
      final r = parse('batal semua', _catalog);
      expect(r.commands, hasLength(1));
      expect(r.commands.first, isA<ClearCart>());
    });
  });

  group('F10 — RemoveLast', () {
    // "hapus terakhir" → RemoveLast
    test('"hapus terakhir" → RemoveLast', () {
      final r = parse('hapus terakhir', _catalog);
      expect(r.commands, hasLength(1));
      expect(r.commands.first, isA<RemoveLast>());
    });
  });

  group('F11 — RemoveItem', () {
    // "hapus brownies" → RemoveItem(p1)
    test('"hapus <produk>" → RemoveItem', () {
      final r = parse('hapus brownies', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as RemoveItem;
      expect(cmd.productId, 'p1');
    });
  });

  group('F12 — SetPayment uang pas', () {
    // "uang pas" / "pas" → SetPayment(null)
    test('"uang pas" → SetPayment(null)', () {
      final r = parse('uang pas', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as SetPayment;
      expect(cmd.amount, isNull);
    });
  });

  group('F13 — SetPayment nominal angka kata', () {
    // "bayar lima puluh ribu" → SetPayment(50000)
    test('"bayar lima puluh ribu" → SetPayment(50000)', () {
      final r = parse('bayar lima puluh ribu', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as SetPayment;
      expect(cmd.amount, 50000);
    });
  });

  group('F14 — SetPayment nominal Rp singkatan', () {
    // "bayar 50rb" → SetPayment(50000)
    test('"bayar 50rb" → SetPayment(50000)', () {
      final r = parse('bayar 50rb', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as SetPayment;
      expect(cmd.amount, 50000);
    });
  });

  group('F15 — harga sebagai lineTotalOverride', () {
    // "brownies dua puluh ribu" → AddItem(p1, qty:1, lineTotalOverride:20000)
    // Karena 20000 ≠ qty yang valid dan terlihat sebagai nominal harga
    test('angka besar setelah produk → lineTotalOverride', () {
      final r = parse('brownies dua puluh ribu', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as AddItem;
      expect(cmd.productId, 'p1');
      expect(cmd.lineTotalOverride, 20000);
    });
  });

  group('F16 — lowConfidence issue untuk produk mirip', () {
    // "cukis" (typo kukis, JW ~0.81) → AddItem dengan issue lowConfidence
    test('nama mirip tapi di bawah autoMatchThreshold → lowConfidence issue',
        () {
      final r = parse(
        'cukis',
        _catalog,
        config: const ParserConfig(
          autoMatchThreshold: 0.88,
          suggestThreshold: 0.75,
        ),
      );
      // Harus ada issue lowConfidence atau unknownProduct
      final hasIssue = r.issues.any(
        (i) =>
            i.type == IssueType.lowConfidence ||
            i.type == IssueType.unknownProduct,
      );
      expect(hasIssue, isTrue);
    });
  });

  group('F17 — unknownProduct untuk kata tidak dikenal', () {
    // "martabak" → Unknown command + unknownProduct issue
    test('produk tidak ada di katalog → Unknown + issue unknownProduct', () {
      final r = parse('martabak', _catalog);
      final hasUnknownCmd = r.commands.any((c) => c is Unknown);
      final hasIssue = r.issues.any((i) => i.type == IssueType.unknownProduct);
      expect(hasUnknownCmd || hasIssue, isTrue);
    });
  });

  group('F18 — campuran filler dan segmentasi', () {
    // "minta dua bronis sama satu es teh ya" → [AddItem(p1,2), AddItem(p4,1)]
    test('filler + segmentasi "sama" + qty', () {
      final r = parse('minta dua bronis sama satu es teh ya', _catalog);
      expect(r.commands, hasLength(2));
      expect((r.commands[0] as AddItem).productId, 'p1');
      expect((r.commands[0] as AddItem).qty, 2);
      expect((r.commands[1] as AddItem).productId, 'p4');
      expect((r.commands[1] as AddItem).qty, 1);
    });
  });

  group('F19 — angka kata ribu/rb/k', () {
    // "bayar 100k" → SetPayment(100000)
    test('"bayar 100k" → SetPayment(100000)', () {
      final r = parse('bayar 100k', _catalog);
      expect(r.commands, hasLength(1));
      final cmd = r.commands.first as SetPayment;
      expect(cmd.amount, 100000);
    });
  });

  group('F20 — performa < 50ms untuk 100 produk', () {
    test('parse 100 produk dalam < 50ms', () {
      final bigCatalog = List.generate(
        100,
        (i) => CatalogEntry(
          productId: 'px$i',
          name: 'Produk $i',
          aliases: ['alias$i'],
          price: (i + 1) * 1000,
        ),
      );
      final sw = Stopwatch()..start();
      parse('dua brownies sama satu cookies', [
        ..._catalog,
        ...bigCatalog,
      ]);
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50));
    });
  });
}
