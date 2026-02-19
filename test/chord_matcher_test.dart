import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';

import 'fixtures/directives_json.dart';

void main() {
  late ChordMatcher matcher;

  setUp(() {
    matcher = ChordMatcher();
  });

  group('isChord', () {
    test('matches basic major chords', () {
      for (final root in ['A', 'B', 'C', 'D', 'E', 'F', 'G']) {
        expect(matcher.isChord(root), isTrue, reason: root);
      }
    });

    test('matches chords with accidentals', () {
      expect(matcher.isChord('C#'), isTrue);
      expect(matcher.isChord('Bb'), isTrue);
      expect(matcher.isChord('F#'), isTrue);
      expect(matcher.isChord('Eb'), isTrue);
    });

    test('matches minor chords', () {
      expect(matcher.isChord('Am'), isTrue);
      expect(matcher.isChord('C#m'), isTrue);
      expect(matcher.isChord('Bbm'), isTrue);
      expect(matcher.isChord('Amin'), isTrue);
    });

    test('matches seventh chords', () {
      expect(matcher.isChord('C7'), isTrue);
      expect(matcher.isChord('Am7'), isTrue);
      expect(matcher.isChord('Cmaj7'), isTrue);
      expect(matcher.isChord('Bdim7'), isTrue);
    });

    test('matches Brazilian notation', () {
      expect(matcher.isChord('A7+'), isTrue, reason: 'A7+ (major 7th)');
      expect(matcher.isChord('C7M'), isTrue, reason: 'C7M (major 7th)');
      expect(matcher.isChord('D7/9'), isTrue, reason: 'D7/9 (compound interval)');
      expect(matcher.isChord('Am7(5-)'), isTrue, reason: 'Am7(5-)');
      expect(matcher.isChord('C(6/9)'), isTrue, reason: 'C(6/9)');
      expect(matcher.isChord('A7M(6/11+)'), isTrue, reason: 'A7M(6/11+)');
      expect(matcher.isChord('A6(9)'), isTrue, reason: 'A6(9)');
    });

    test('matches N.C. (no chord)', () {
      expect(matcher.isChord('N.C.'), isTrue);
    });

    test('matches slash chords', () {
      expect(matcher.isChord('C/G'), isTrue);
      expect(matcher.isChord('Am7/E'), isTrue);
      expect(matcher.isChord('Bb/Ab'), isTrue);
    });

    test('matches diminished symbols', () {
      expect(matcher.isChord('Cº'), isTrue);
      expect(matcher.isChord('C°'), isTrue);
      expect(matcher.isChord('Cø'), isTrue);
      expect(matcher.isChord('Cdim'), isTrue);
      expect(matcher.isChord('D#°'), isTrue, reason: 'sharp root + °');
      expect(matcher.isChord('G#º'), isTrue, reason: 'sharp root + º');
    });

    test('matches diminished with sharp root', () {
      expect(matcher.isChord('D#°'), isTrue, reason: 'D#° (sharp root + °)');
      expect(matcher.isChord('G#º'), isTrue, reason: 'G#º (sharp root + º)');
      expect(matcher.isChord('F#dim7'), isTrue, reason: 'F#dim7');
    });

    test('matches augmented chords', () {
      expect(matcher.isChord('C+'), isTrue);
      expect(matcher.isChord('Caug'), isTrue);
    });

    test('matches suspended chords', () {
      expect(matcher.isChord('Csus2'), isTrue);
      expect(matcher.isChord('Csus4'), isTrue);
      expect(matcher.isChord('C7sus4'), isTrue);
    });

    test('matches add chords', () {
      expect(matcher.isChord('Cadd9'), isTrue);
      expect(matcher.isChord('Cadd11'), isTrue);
      expect(matcher.isChord('Cadd13'), isTrue);
    });

    test('matches standard alterations', () {
      expect(matcher.isChord('C7b5'), isTrue);
      expect(matcher.isChord('C7#9'), isTrue);
      expect(matcher.isChord('C7b9'), isTrue);
    });

    test('rejects invalid input', () {
      expect(matcher.isChord(''), isFalse);
      expect(matcher.isChord('H'), isFalse);
      expect(matcher.isChord('hello'), isFalse);
      expect(matcher.isChord('123'), isFalse);
      expect(matcher.isChord('Verse'), isFalse);
      expect(matcher.isChord('Chorus'), isFalse);
      expect(matcher.isChord('(intro)'), isFalse);
      expect(matcher.isChord('(2x)'), isFalse);
    });
  });

  group('isAnnotation', () {
    test('matches keyword annotations', () {
      expect(matcher.isAnnotation('(intro)'), isTrue);
      expect(matcher.isAnnotation('(outro)'), isTrue);
      expect(matcher.isAnnotation('(solo)'), isTrue);
      expect(matcher.isAnnotation('(riff)'), isTrue);
      expect(matcher.isAnnotation('(break)'), isTrue);
      expect(matcher.isAnnotation('(interlude)'), isTrue);
      expect(matcher.isAnnotation('(bridge)'), isTrue);
      expect(matcher.isAnnotation('(verse)'), isTrue);
      expect(matcher.isAnnotation('(chorus)'), isTrue);
      expect(matcher.isAnnotation('(fade out)'), isTrue);
    });

    test('matches repeat annotations', () {
      expect(matcher.isAnnotation('(2x)'), isTrue);
      expect(matcher.isAnnotation('(3x)'), isTrue);
      expect(matcher.isAnnotation('(16x)'), isTrue);
    });

    test('matches keyword + repeat annotations', () {
      expect(matcher.isAnnotation('(intro 3x)'), isTrue);
      expect(matcher.isAnnotation('(solo 2x)'), isTrue);
      expect(matcher.isAnnotation('(riff 4x)'), isTrue);
    });

    test('is case insensitive', () {
      expect(matcher.isAnnotation('(Intro)'), isTrue);
      expect(matcher.isAnnotation('(INTRO)'), isTrue);
      expect(matcher.isAnnotation('(Intro 3x)'), isTrue);
    });

    test('rejects chord alterations', () {
      expect(matcher.isAnnotation('(5-)'), isFalse);
      expect(matcher.isAnnotation('(b9)'), isFalse);
      expect(matcher.isAnnotation('(6/9)'), isFalse);
      expect(matcher.isAnnotation('(#11)'), isFalse);
    });

    test('rejects chords', () {
      expect(matcher.isAnnotation('Am'), isFalse);
      expect(matcher.isAnnotation('C7'), isFalse);
    });

    test('rejects bare text', () {
      expect(matcher.isAnnotation('intro'), isFalse);
      expect(matcher.isAnnotation('hello'), isFalse);
    });
  });

  group('isChordOrAnnotation', () {
    test('returns true for chords', () {
      expect(matcher.isChordOrAnnotation('Am7'), isTrue);
    });

    test('returns true for annotations', () {
      expect(matcher.isChordOrAnnotation('(intro)'), isTrue);
    });

    test('returns false for non-chord non-annotation', () {
      expect(matcher.isChordOrAnnotation('hello'), isFalse);
    });
  });

  group('isChordOnlyLine', () {
    test('simple chord lines', () {
      expect(matcher.isChordOnlyLine('C  G  Am  F'), isTrue);
      expect(matcher.isChordOnlyLine('Am7  Dm7  G7  Cmaj7'), isTrue);
      expect(matcher.isChordOnlyLine('E'), isTrue);
    });

    test('Brazilian chord lines', () {
      expect(matcher.isChordOnlyLine('A7+  D7/9'), isTrue);
      expect(matcher.isChordOnlyLine('C7M  Am7(5-)'), isTrue);
      expect(matcher.isChordOnlyLine('A6(9)  D7/9  G7M'), isTrue);
    });

    test('mixed chord and annotation lines', () {
      expect(matcher.isChordOnlyLine('(intro 3x) A7+ D7/9'), isTrue);
      expect(matcher.isChordOnlyLine('Am G (2x)'), isTrue);
      expect(matcher.isChordOnlyLine('(solo) Em Bm'), isTrue);
    });

    test('annotation-only line is rejected (no chords)', () {
      expect(matcher.isChordOnlyLine('(intro)'), isFalse);
      expect(matcher.isChordOnlyLine('(2x)'), isFalse);
    });

    test('parenthesized chord lines', () {
      expect(matcher.isChordOnlyLine('( C#m7(5-)  F#7 )'), isTrue);
      expect(matcher.isChordOnlyLine('( Am  G )'), isTrue);
    });

    test('rejects lyric lines', () {
      expect(matcher.isChordOnlyLine('Hello world'), isFalse);
      expect(matcher.isChordOnlyLine('Let it be'), isFalse);
      expect(matcher.isChordOnlyLine(''), isFalse);
    });

    test('rejects mixed chord/lyric content', () {
      expect(matcher.isChordOnlyLine('C Hello G world'), isFalse);
    });

    test('handles leading/trailing whitespace', () {
      expect(matcher.isChordOnlyLine('   C   G   Am   '), isTrue);
    });
  });

  group('extractChords', () {
    test('extracts chords with column positions', () {
      final chords = matcher.extractChords('C     G     Am');
      expect(chords.length, 3);
      expect(chords[0].chord, 'C');
      expect(chords[0].column, 0);
      expect(chords[1].chord, 'G');
      expect(chords[1].column, 6);
      expect(chords[2].chord, 'Am');
      expect(chords[2].column, 12);
    });

    test('skips annotations', () {
      final chords = matcher.extractChords('(intro 3x) A7+ D7/9');
      expect(chords.length, 2);
      expect(chords[0].chord, 'A7+');
      expect(chords[1].chord, 'D7/9');
    });

    test('skips non-chord tokens', () {
      final chords = matcher.extractChords('Am hello G');
      expect(chords.length, 2);
      expect(chords[0].chord, 'Am');
      expect(chords[1].chord, 'G');
    });

    test('returns empty list for non-chord line', () {
      final chords = matcher.extractChords('Hello world');
      expect(chords, isEmpty);
    });

    test('handles Brazilian chords', () {
      final chords = matcher.extractChords('C7M  Am7(5-)  D7/9');
      expect(chords.length, 3);
      expect(chords[0].chord, 'C7M');
      expect(chords[1].chord, 'Am7(5-)');
      expect(chords[2].chord, 'D7/9');
    });
  });

  group('spec sync', () {
    test('default pattern matches fromJson pattern on sample chords', () {
      final defaultMatcher = ChordMatcher();
      final jsonMatcher = ChordMatcher.fromJson(getTestJson());

      const sampleChords = [
        'C', 'Am', 'F#m7', 'Bb', 'Cmaj7', 'Bdim7', 'Caug',
        'A7+', 'C7M', 'D7/9', 'Am7(5-)', 'C(6/9)', 'A7M(6/11+)',
        'N.C.', 'C/G', 'Csus4', 'Cadd9', 'C7b5', 'Cø7',
        'C°7', 'Cº7', 'C˚7',
      ];

      const sampleNonChords = [
        'Hello', 'Verse', '123', '', 'H7', 'Xm',
      ];

      for (final chord in sampleChords) {
        expect(
          defaultMatcher.isChord(chord),
          jsonMatcher.isChord(chord),
          reason: 'Mismatch on chord: $chord',
        );
      }

      for (final text in sampleNonChords) {
        expect(
          defaultMatcher.isChord(text),
          jsonMatcher.isChord(text),
          reason: 'Mismatch on non-chord: $text',
        );
      }
    });
  });
}
