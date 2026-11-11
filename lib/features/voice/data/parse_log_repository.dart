import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:voice_parser/voice_parser.dart';

import '../../../core/database/app_database.dart';

class ParseLogRepository {
  ParseLogRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<void> save({
    required String storeId,
    required String? transactionId,
    required String transcript,
    required ParseResult parsed,
    ParseResult? corrected,
    required String parserVersion,
  }) async {
    final companion = ParseLogsCompanion.insert(
      id: _uuid.v4(),
      storeId: storeId,
      transactionId: Value(transactionId),
      transcript: transcript,
      parsed: jsonEncode(_resultToJson(parsed)),
      corrected: Value(
          corrected != null ? jsonEncode(_resultToJson(corrected)) : null),
      parserVersion: parserVersion,
      createdAt: DateTime.now().toUtc(),
    );
    await _db.parseLogDao.insert(companion);
  }

  static Map<String, dynamic> _resultToJson(ParseResult result) => {
        'commands': result.commands.map(_commandToJson).toList(),
        'issues': result.issues.map(_issueToJson).toList(),
      };

  static Map<String, dynamic> _commandToJson(ParsedCommand cmd) =>
      switch (cmd) {
        AddItem() => {
            'type': 'add',
            'productId': cmd.productId,
            'qty': cmd.qty,
            'lineTotalOverride': cmd.lineTotalOverride,
            'confidence': cmd.confidence,
            'sourceText': cmd.sourceText,
          },
        RemoveItem() => {
            'type': 'remove',
            'productId': cmd.productId,
            'sourceText': cmd.sourceText,
          },
        RemoveLast() => {'type': 'removeLast'},
        ClearCart() => {'type': 'clear'},
        SetPayment() => {'type': 'payment', 'amount': cmd.amount},
        Unknown() => {'type': 'unknown', 'sourceText': cmd.sourceText},
      };

  static Map<String, dynamic> _issueToJson(ParseIssue issue) => {
        'type': issue.type.name,
        'sourceText': issue.sourceText,
        'suggestions': issue.suggestions,
      };
}
