import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';
import './fixtures/directives_json.dart'; // Import the constant

void main() {
  group('Error Handling', () {
    late IclfParser parser;
    setUp(() {
      parser = IclfParser(getTestJson());
    });
    test('006 handles invalid content (missing title)', () {
      const content = '{key: C}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.invalid);
      expect(
          result.errors, contains('Missing required directives: {title: ...}'));
    });
    test('007 handles invalid chord', () {
      const content = '{title: Test}\n{key: C}\n[Invalid]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.invalid);
      expect(result.errors, contains('Invalid chord: Invalid'));
    });
    test('008 handles invalid directive value', () {
      const content = '{title: Test}\n{key: InvalidKey}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.invalid);
      expect(result.errors.any((e) => e.contains('Invalid value for key')),
          isTrue);
    });
  });
}
