import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';
import './fixtures/directives_json.dart'; // Import the constant

void main() {
  group('Basic Parsing', () {
    late IclfParser parser;
    setUp(() {
      parser = IclfParser(getTestJson());
    });
    test('001 parses valid content', () {
      const content = '{title: Test}\n{key: C}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.title, 'Test');
      expect(result.song?.key, 'C');
    }, tags: ['tag1']);
    test('002 handles recoverable content (missing key)', () {
      const content = '{title: Test}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.recoverable);
      expect(result.warnings, contains('Added missing {key: C}'));
      expect(result.fixedContent, contains('{key: C}'));
      expect(result.song?.key, 'C');
    }, tags: ['tag1']);
    test('003 handles duplicate globals (keeps first)', () {
      const content = '{title: Test}\n{key: C}\n{key: Am}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.recoverable);
      expect(result.warnings,
          contains('Duplicate global directive {key: Am}; keeping first.'));
      expect(result.song?.key, 'C');
    }, tags: ['tag1']);
    test('004 handles late globals (warns but applies)', () {
      const content = '{title: Test}\n{section: Verse}\n[C]Lyric\n{key: C}';
      final result = parser.parse(content);

      // Add this line for debugging
      // debugging options
      // print(
      //     'Errors: ${result.errors.join('\n')}'); // Prints each error on a new line
      // print(
      //     'Warnings: ${result.warnings.join('\n')}'); // Optional: also print warnings

      expect(result.status, ParseStatus.recoverable);
      expect(result.warnings,
          contains('Late global directive {key: C}; applied song-wide.'));
      expect(result.song?.key, 'C');
    }, tags: ['tag1']);
    test('005 computes file hash', () {
      const content = '{title: Test}';
      final result = parser.parse(content, filePath: 'test.iclf');
      expect(result.fileHash, isNotNull);
    }, tags: ['tag1']);
  });
}
