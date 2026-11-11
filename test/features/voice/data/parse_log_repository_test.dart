import 'package:cashier_speech/core/database/app_database.dart';
import 'package:cashier_speech/features/voice/data/parse_log_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_parser/voice_parser.dart';

void main() {
  late AppDatabase db;
  late ParseLogRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ParseLogRepository(db);
  });

  tearDown(() => db.close());

  test('save inserts a row into parse_logs', () async {
    const result = ParseResult(
      commands: [
        AddItem(
          productId: 'p1',
          qty: 2,
          confidence: 0.95,
          sourceText: 'brownies dua',
        ),
      ],
    );

    await repo.save(
      storeId: 'store1',
      transactionId: 'txn1',
      transcript: 'brownies dua',
      parsed: result,
      parserVersion: '0.1.0',
    );

    final rows = await db.parseLogDao.watchRecent('store1').first;
    expect(rows.length, 1);
    expect(rows.first.storeId, 'store1');
    expect(rows.first.transactionId, 'txn1');
    expect(rows.first.transcript, 'brownies dua');
    expect(rows.first.parserVersion, '0.1.0');
    expect(rows.first.corrected, isNull);
  });

  test('save with corrected writes non-null corrected JSON', () async {
    const parsed = ParseResult(
      commands: [
        AddItem(
          productId: 'p1',
          qty: 1,
          confidence: 0.80,
          sourceText: 'bronis',
        ),
      ],
    );
    const corrected = ParseResult(
      commands: [
        AddItem(
          productId: 'p1',
          qty: 2,
          confidence: 1.0,
          sourceText: 'bronis',
        ),
      ],
    );

    await repo.save(
      storeId: 'store1',
      transactionId: 'txn1',
      transcript: 'bronis',
      parsed: parsed,
      corrected: corrected,
      parserVersion: '0.1.0',
    );

    final rows = await db.parseLogDao.watchRecent('store1').first;
    expect(rows.first.corrected, isNotNull);
  });

  test('save with null transactionId stores null', () async {
    await repo.save(
      storeId: 'store1',
      transactionId: null,
      transcript: 'test',
      parsed: const ParseResult(),
      parserVersion: '0.1.0',
    );

    final rows = await db.parseLogDao.watchRecent('store1').first;
    expect(rows.first.transactionId, isNull);
  });

  test('watchRecent filters by storeId', () async {
    await repo.save(
      storeId: 'store-a',
      transactionId: null,
      transcript: 'a',
      parsed: const ParseResult(),
      parserVersion: '0.1.0',
    );
    await repo.save(
      storeId: 'store-b',
      transactionId: null,
      transcript: 'b',
      parsed: const ParseResult(),
      parserVersion: '0.1.0',
    );

    final rows = await db.parseLogDao.watchRecent('store-a').first;
    expect(rows.length, 1);
    expect(rows.first.storeId, 'store-a');
  });
}
