import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';
import './fixtures/directives_json.dart'; // Import the constant

void main() {
  group('Notes and Attributes', () {
    late IclfParser parser;
    setUp(() {
      parser = IclfParser(getTestJson());
    });
    test('009 handles non-reserved directives as notes', () {
      const content = '{title: Test}\n{key: C}\n{mood: Romantic}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(
          result.song?.globalNotes
              .any((note) => note.content == '{mood: Romantic}'),
          isTrue);
    });
    test('010 handles # notes', () {
      const content = '{title: Test}\n{key: C}\n# Strum gently\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(
          result.song?.globalNotes
              .any((note) => note.content == 'Strum gently' && note.isHashNote),
          isTrue);
    });
    test('011 handles chord attributes', () {
      const content = '{title: Test}\n{key: C}\n[C:inversion,1]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.first.attributes['inversion'],
          '1');
    });
  });
}
