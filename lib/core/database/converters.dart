import 'dart:convert';

import 'package:drift/drift.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return List<String>.from(json.decode(fromDb) as List<dynamic>);
  }

  @override
  String toSql(List<String> value) => json.encode(value);
}
