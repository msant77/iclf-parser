import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';
import './fixtures/directives_json.dart';

void main() {
  group('Validation', () {
    late IclfParser parser;
    setUp(() {
      parser = IclfParser(getTestJson());
    });
    test('014 handles regex from json (creation_date)', () {
      const content =
          '{title: Test}\n{key: C}\n{creation_date: 2025-04-28}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.globals['creation_date'], '2025-04-28');
    });
    test('015 invalid regex from json (creation_date)', () {
      const content =
          '{title: Test}\n{key: C}\n{creation_date: invalid}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.invalid);
      expect(
          result.errors
              .any((e) => e.contains('Invalid value for creation_date')),
          isTrue);
    });
    test('016 handles integer from json (tempo)', () {
      const content = '{title: Test}\n{key: C}\n{tempo: 80}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.globals['tempo'], '80');
    });
    test('017 invalid integer from json (tempo)', () {
      const content = '{title: Test}\n{key: C}\n{tempo: 10}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.invalid);
      expect(result.errors.any((e) => e.contains('Invalid integer for tempo')),
          isTrue);
    });
  });
}
