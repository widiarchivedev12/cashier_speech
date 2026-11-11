import 'package:test/test.dart';
import 'package:voice_parser/voice_parser.dart';

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
}
