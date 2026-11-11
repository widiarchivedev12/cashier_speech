import 'models.dart';

const String parserVersion = '0.1.0';

ParseResult parse(
  String transcript,
  List<CatalogEntry> catalog, {
  ParserConfig config = const ParserConfig(),
}) {
  if (transcript.trim().isEmpty) return const ParseResult();
  // TODO(M1): implementasi lengkap dengan TDD
  return const ParseResult();
}
